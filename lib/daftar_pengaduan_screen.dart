import 'package:flutter/material.dart';
import 'api_service.dart';
import 'widgets/app_drawer.dart';

class DaftarPengaduanScreen extends StatefulWidget {
  const DaftarPengaduanScreen({super.key});

  @override
  State<DaftarPengaduanScreen> createState() => _DaftarPengaduanScreenState();
}

class _DaftarPengaduanScreenState extends State<DaftarPengaduanScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pengaduanList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    try {
      final data = await _apiService.getPengaduanPublik();
      setState(() {
        _pengaduanList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Gagal memuat data pengaduan: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Daftar Pengaduan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0EA5E9)))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0EA5E9), foregroundColor: Colors.white),
                        onPressed: () {
                          setState(() => _isLoading = true);
                          _fetchPengaduan();
                        },
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPengaduan,
                  color: const Color(0xFF0EA5E9),
                  child: _pengaduanList.isEmpty
                      ? const Center(child: Text('Belum ada pengaduan.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _pengaduanList.length,
                          itemBuilder: (context, index) {
                            final item = _pengaduanList[index];
                            return _buildPengaduanCard(item);
                          },
                        ),
                ),
    );
  }

  Widget _buildPengaduanCard(dynamic item) {
    final title = item['judul_pengaduan'] ?? 'Tanpa Judul';
    final desc = item['deskripsi_masalah'] ?? 'Tidak ada deskripsi';
    final status = (item['status_laporan'] ?? 'menunggu').toString().toLowerCase();
    final location = item['lokasi_kejadian'] ?? 'Lokasi tidak disebutkan';
    final photo = item['foto_bukti'];

    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'SELESAI';
        break;
      case 'diproses':
        statusColor = Colors.orange;
        statusText = 'DIPROSES';
        break;
      case 'menunggu':
      default:
        statusColor = Colors.blue;
        statusText = 'MENUNGGU';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area if exists
          if (photo != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                '${ApiService.imgBaseUrl}/$photo',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade50,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                    ),
                    Text(
                      item['created_at']?.toString().substring(0, 10) ?? '-',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF0EA5E9)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  desc,
                  style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
