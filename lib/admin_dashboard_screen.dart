import 'package:flutter/material.dart';
import 'api_service.dart';
import 'widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _allReports = [];
  List<dynamic> _filteredReports = [];
  bool _isLoading = true;
  String _adminName = 'Admin Sistem';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _fetchReports();
    _searchController.addListener(_filterReports);
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final user = jsonDecode(userStr);
      setState(() {
        _adminName = user['name'] ?? 'Admin Sistem';
      });
    }
  }

  Future<void> _fetchReports() async {
    try {
      final reports = await _apiService.getAdminReports();
      setState(() {
        _allReports = reports;
        _filteredReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data laporan.')));
      }
    }
  }

  void _filterReports() {
    final term = _searchController.text.toLowerCase();
    setState(() {
      _filteredReports = _allReports.where((r) {
        final title = (r['judul_pengaduan'] ?? '').toString().toLowerCase();
        final name = (r['user']?['name'] ?? '').toString().toLowerCase();
        return title.contains(term) || name.contains(term);
      }).toList();
    });
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await _apiService.updateReportStatus(id, newStatus);
      _fetchReports(); // Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status berhasil diperbarui!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui status.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _allReports.length;
    int pending = _allReports.where((r) => r['status_laporan'] == 'menunggu').length;
    int selesai = _allReports.where((r) => r['status_laporan'] == 'selesai').length;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('PUSAT KENDALI OPERASIONAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_adminName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const Text('ADMINISTRATOR UTAMA', style: TextStyle(fontSize: 8, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.red.shade400,
                  child: const Text('AD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _fetchReports,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatCards(total, pending, selesai),
                  const SizedBox(height: 32),
                  
                  // MAIN CONTENT CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Manajemen Alur Kerja Pengaduan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                        const SizedBox(height: 4),
                        const Text('Memonitor dan mengubah status laporan masyarakat.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari pelapor atau judul...',
                            hintStyle: const TextStyle(fontSize: 13),
                            prefixIcon: const Icon(Icons.search, size: 20),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _filteredReports.isEmpty
                          ? const Center(child: Text('Tidak ada laporan.'))
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredReports.length,
                              separatorBuilder: (c, i) => const Divider(height: 40),
                              itemBuilder: (context, index) {
                                return _buildReportItem(_filteredReports[index]);
                              },
                            ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildStatCards(int total, int pending, int selesai) {
    return Column(
      children: [
        _statCard('VOLUME DATABASE', total.toString(), 'Total aduan terdaftar di sistem', const Color(0xFF6366F1), Icons.add),
        const SizedBox(height: 12),
        _statCard('MENUNGGU VERIFIKASI', pending.toString(), 'Menunggu tindakan verifikasi', const Color(0xFFF59E0B), Icons.priority_high),
        const SizedBox(height: 12),
        _statCard('INSIDEN TERSELESAIKAN', selesai.toString(), 'Kasus tuntas dalam pengawasan', const Color(0xFF10B981), Icons.check),
      ],
    );
  }

  Widget _statCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.grey.withOpacity(0.2), size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(dynamic r) {
    final photo = r['foto_bukti'];
    final status = (r['status_laporan'] ?? 'menunggu');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(r['id'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r['user']?['name'] ?? 'Anonim', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  Text(r['user']?['email'] ?? '-', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            _statusBadge(status),
          ],
        ),
        const SizedBox(height: 16),
        const Text('SUBJEK ADUAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
        const SizedBox(height: 4),
        Text(r['judul_pengaduan'] ?? '-', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        const Text('LOKASI KEJADIAN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
        const SizedBox(height: 4),
        Text(r['lokasi_kejadian'] ?? '-', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 20),
        
        // FOTO BESAR SESUAI PERMINTAAN
        const Text('DATA FOTO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF6366F1))),
        const SizedBox(height: 8),
        if (photo != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              '${ApiService.imgBaseUrl}/$photo',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(height: 100, color: Colors.grey.shade100, child: const Icon(Icons.broken_image)),
            ),
          )
        else
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
            child: const Center(child: Text('Tidak ada foto', style: TextStyle(color: Colors.grey, fontSize: 12))),
          ),
        
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showStatusPicker(r['id'], status),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEEF2FF),
              foregroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('TANDAI: ${status.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color = status == 'selesai' ? Colors.green : (status == 'diproses' ? Colors.orange : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  void _showStatusPicker(int id, String currentStatus) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ubah Status Laporan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _statusOption(id, 'menunggu', Colors.blue),
              _statusOption(id, 'diproses', Colors.orange),
              _statusOption(id, 'selesai', Colors.green),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statusOption(int id, String val, Color color) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 16),
      title: Text(val.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      onTap: () {
        Navigator.pop(context);
        _updateStatus(id, val);
      },
    );
  }
}
