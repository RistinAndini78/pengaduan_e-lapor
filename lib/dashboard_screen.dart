import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pengaduan_provider.dart';
import 'widgets/app_drawer.dart';
import 'api_service.dart';
import 'detail_pengaduan_screen.dart';
import 'models/pengaduan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'widgets/shimmer_loading.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _judulController = TextEditingController();
  final _isiLaporanController = TextEditingController();
  final _lokasiController = TextEditingController();
  
  bool _isLoading = false;
  bool _isFetchingHistory = true;
  String _userName = '';
  int? _selectedCategory;
  
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  
  List<dynamic> _myReports = [];

  // Data kategori dari seeder
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Fasilitas Publik'},
    {'id': 2, 'name': 'Sanitasi'},
    {'id': 3, 'name': 'Kesehatan'},
    {'id': 4, 'name': 'Sosial'},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadUser();
    if (mounted) {
      context.read<PengaduanProvider>().fetchPengaduans();
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      setState(() {
        _userName = user['name'] ?? 'Pengguna';
      });
    }
  }

  // _fetchMyReports dihapus karena digantikan oleh Provider

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = image;
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_judulController.text.isEmpty || 
        _selectedCategory == null || 
        _lokasiController.text.isEmpty || 
        _isiLaporanController.text.isEmpty || 
        _selectedImage == null) {
      _showSnackbar('Harap lengkapi seluruh formulir termasuk foto.', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final request = http.MultipartRequest('POST', Uri.parse('${ApiService.baseUrl}/pengaduan'));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      request.fields['judul_pengaduan'] = _judulController.text;
      request.fields['deskripsi_masalah'] = _isiLaporanController.text;
      request.fields['lokasi_kejadian'] = _lokasiController.text;
      request.fields['category_id'] = _selectedCategory.toString();

      request.files.add(http.MultipartFile.fromBytes(
        'foto_bukti',
        _imageBytes!,
        filename: _selectedImage!.name,
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        _showSnackbar('Berhasil mengirim pengaduan!', Colors.green);
        _clearForm();
        if (mounted) context.read<PengaduanProvider>().fetchPengaduans();
      } else {
        throw Exception('Gagal: ${response.body}');
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearForm() {
    _judulController.clear();
    _isiLaporanController.clear();
    _lokasiController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedImage = null;
      _imageBytes = null;
    });
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF1F5F9), // Slightly grayish background like web
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WELCOME BANNER PREMIUM (BIAR GAK KOSONG)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0EA5E9).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 32),
                      IconButton(
                        onPressed: () => Navigator.pushNamed(context, '/profile'),
                        icon: const Icon(Icons.account_circle, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'E-Lapor Mobile',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  Text(
                    'Halo, $_userName!',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Suara Anda adalah langkah awal perubahan. Laporkan masalah di sekitar Anda sekarang.',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form SECTION (Buat Pengaduan)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.add, color: Color(0xFF0EA5E9), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Buat Pengaduan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _fieldLabel('JUDUL LAPORAN'),
                  TextField(
                    controller: _judulController,
                    decoration: _inputDecoration('Contoh: Jalan Berlubang'),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('KATEGORI'),
                  DropdownButtonFormField<int>(
                    value: _selectedCategory,
                    decoration: _inputDecoration('Pilih Kategori'),
                    items: _categories.map((c) => DropdownMenuItem<int>(
                      value: c['id'],
                      child: Text(c['name']),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('LOKASI KEJADIAN'),
                  TextField(
                    controller: _lokasiController,
                    decoration: _inputDecoration('Alamat lengkap'),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('FOTO BUKTI'),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(10)),
                            child: const Text('Upload Foto', style: TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedImage == null ? 'Pilih bukti kejadian...' : _selectedImage!.name,
                              style: TextStyle(color: _selectedImage == null ? Colors.grey : Colors.green, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _fieldLabel('DESKRIPSI MASALAH'),
                  TextField(
                    controller: _isiLaporanController,
                    maxLines: 4,
                    decoration: _inputDecoration('Jelaskan secara detail...'),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Kirim Pengaduan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // History SECTION (Riwayat Laporan Saya)
             Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Riwayat Laporan Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Consumer<PengaduanProvider>(
                    builder: (context, provider, child) {
                      if (provider.state == PengaduanState.loading) {
                        return const ShimmerLoading();
                      }
                      
                      if (provider.state == PengaduanState.error) {
                        return Center(child: Text('Gagal: ${provider.errorMessage}', style: const TextStyle(color: Colors.red, fontSize: 12)));
                      }

                      if (provider.pengaduans.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.inbox_outlined, size: 80, color: Colors.blue.withOpacity(0.1)),
                              const SizedBox(height: 16),
                              const Text('Belum ada laporan yang dibuat.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                              const SizedBox(height: 40),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.pengaduans.length,
                        separatorBuilder: (c, i) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final r = provider.pengaduans[index];
                          return _buildReportItemFromModel(r);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItemFromModel(Pengaduan p) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPengaduanScreen(pengaduan: p)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            if (p.foto != null)
              Hero(
                tag: 'img-${p.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network('${ApiService.imgBaseUrl}/${p.foto}', width: 60, height: 60, fit: BoxFit.cover),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(p.tanggal?.substring(0, 10) ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            if (p.status == 'menunggu')
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: () => _confirmDelete(p.id!),
              ),
            _statusBadge(p.status),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Laporan?'),
        content: const Text('Laporan yang dihapus tidak bisa dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<PengaduanProvider>().deleteReport(id);
                _showSnackbar('Laporan berhasil dihapus', Colors.green);
              } catch (e) {
                _showSnackbar('Gagal menghapus: $e', Colors.red);
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color statusColor = status == 'selesai' ? Colors.green : (status == 'diproses' ? Colors.orange : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildReportItem(dynamic r) {
    // Fungsi ini tidak dipakai lagi karena diganti _buildReportItemFromModel
    return const SizedBox.shrink();
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5)),
    );
  }
}
