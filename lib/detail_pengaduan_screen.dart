import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/pengaduan.dart';
import '../api_service.dart';

class DetailPengaduanScreen extends StatelessWidget {
  final Pengaduan pengaduan;

  const DetailPengaduanScreen({super.key, required this.pengaduan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header dengan Image & Hero Animation
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'img-${pengaduan.id}',
                child: pengaduan.foto != null
                    ? Image.network(
                        '${ApiService.imgBaseUrl}/${pengaduan.foto}',
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 50)),
              ),
            ),
          ),

          // Konten Detail
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori & Tanggal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pengaduan.kategori ?? 'Kategori Umum',
                            style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Text(
                          pengaduan.tanggal?.substring(0, 10) ?? '-',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ).animate().fadeIn().slideX(),

                    const SizedBox(height: 20),
                    
                    Text(
                      pengaduan.judul,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.blue),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pengaduan.lokasi,
                            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                    const Divider(height: 48),

                    const Text(
                      'DESKRIPSI LAPORAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pengaduan.deskripsi,
                      style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155)),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 40),

                    // TRACKING TIMELINE SECTION (FITUR KREATIF)
                    const Text(
                      'STATUS PENANGANAN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    _buildTimeline(pengaduan.status),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    bool isPending = true;
    bool isProcessed = currentStatus == 'diproses' || currentStatus == 'selesai';
    bool isFinished = currentStatus == 'selesai';

    return Column(
      children: [
        _timelineStep('Laporan Dikonfirmasi', 'Laporan Anda sudah masuk ke sistem.', isPending),
        _timelineConnector(isProcessed),
        _timelineStep('Sedang Ditinjau', 'Petugas sedang meninjau lokasi kejadian.', isProcessed),
        _timelineConnector(isFinished),
        _timelineStep('Kasus Selesai', 'Masalah telah diselesaikan oleh petugas.', isFinished),
      ],
    );
  }

  Widget _timelineStep(String title, String desc, bool active) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: active ? Colors.blue : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: active ? [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10)] : [],
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: active ? const Color(0xFF0F172A) : Colors.grey)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    ).animate(target: active ? 1 : 0).fadeIn().shimmer();
  }

  Widget _timelineConnector(bool active) {
    return Container(
      margin: const EdgeInsets.only(left: 7),
      height: 30,
      width: 2,
      color: active ? Colors.blue : Colors.grey.shade200,
    );
  }
}
