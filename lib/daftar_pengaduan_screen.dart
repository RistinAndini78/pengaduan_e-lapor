import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/pengaduan_provider.dart';
import 'widgets/app_drawer.dart';
import 'api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'detail_pengaduan_screen.dart';
import 'models/pengaduan.dart';
import 'widgets/shimmer_loading.dart';

class DaftarPengaduanScreen extends StatefulWidget {
  const DaftarPengaduanScreen({super.key});

  @override
  State<DaftarPengaduanScreen> createState() => _DaftarPengaduanScreenState();
}

class _DaftarPengaduanScreenState extends State<DaftarPengaduanScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PengaduanProvider>().fetchSemuaPengaduan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pusat Informasi Laporan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Column(
        children: [
          // BARIS PENCARIAN & FILTER (KREATIVITAS)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari laporan warga...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Semua', 'Menunggu', 'Diproses', 'Selesai'].map((status) {
                      bool isSelected = _selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status, style: TextStyle(color: isSelected ? Colors.white : Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                          selected: isSelected,
                          selectedColor: Colors.blue,
                          backgroundColor: Colors.blue.withOpacity(0.05),
                          onSelected: (val) => setState(() => _selectedStatus = status),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          showCheckmark: false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<PengaduanProvider>(
              builder: (context, provider, child) {
                if (provider.state == PengaduanState.loading) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: ShimmerLoading(),
                  );
                }

                if (provider.state == PengaduanState.error) {
                  return Center(child: Text('Gagal: ${provider.errorMessage}'));
                }

                // LOGIKA FILTERING (SEARCH + STATUS)
                final filtered = provider.pengaduans.where((p) {
                  final matchesSearch = p.judul.toLowerCase().contains(_searchController.text.toLowerCase());
                  final matchesStatus = _selectedStatus == 'Semua' || p.status.toLowerCase() == _selectedStatus.toLowerCase();
                  return matchesSearch && matchesStatus;
                }).toList();

                return RefreshIndicator(
                  onRefresh: () => provider.fetchSemuaPengaduan(),
                  child: filtered.isEmpty
                      ? const Center(child: Text('Tidak ada laporan yang cocok.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _buildPengaduanCardFromModel(item)
                                .animate()
                                .fadeIn(duration: 400.ms, delay: (index * 50).ms)
                                .scaleXY(begin: 0.9, end: 1.0);
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPengaduanCardFromModel(Pengaduan p) {
    // Kita langsung modifikasi card di sini agar bisa navigasi
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPengaduanScreen(pengaduan: p)),
      ),
      child: _buildPengaduanCard({
        'id': p.id,
        'judul_pengaduan': p.judul,
        'deskripsi_masalah': p.deskripsi,
        'status_laporan': p.status,
        'lokasi_kejadian': p.lokasi,
        'foto_bukti': p.foto,
        'created_at': p.tanggal ?? DateTime.now().toString(),
      }),
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
              child: Hero(
                tag: 'img-${item['id']}',
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
