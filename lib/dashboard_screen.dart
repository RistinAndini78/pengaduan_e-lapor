import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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
    await _fetchMyReports();
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

  Future<void> _fetchMyReports() async {
    setState(() => _isFetchingHistory = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/pengaduan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _myReports = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      setState(() => _isFetchingHistory = false);
    }
  }

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
        _fetchMyReports();
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
            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pusat Laporan Warga',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                        children: [
                          const TextSpan(text: 'Halo '),
                          TextSpan(text: _userName, style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                          const TextSpan(text: ', kelola aduan Anda di sini.'),
                        ],
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    await ApiService().logout();
                    if (mounted) Navigator.pushReplacementNamed(context, '/');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
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
                  if (_isFetchingHistory)
                    const Center(child: CircularProgressIndicator())
                  else if (_myReports.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.blue.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          const Text('Belum ada laporan yang dibuat.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _myReports.length,
                      separatorBuilder: (c, i) => const Divider(height: 32),
                      itemBuilder: (context, index) {
                        final r = _myReports[index];
                        return _buildReportItem(r);
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

  Widget _buildReportItem(dynamic r) {
    String status = (r['status_laporan'] ?? 'menunggu');
    Color statusColor = status == 'selesai' ? Colors.green : (status == 'diproses' ? Colors.orange : Colors.blue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(r['judul_pengaduan'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(r['created_at']?.toString().substring(0, 10) ?? '-', style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 8),
        Text(r['deskripsi_masalah'] ?? '-', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
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
