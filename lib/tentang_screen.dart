import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Tentang Kami', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF89CFF0), Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                      children: [
                        TextSpan(text: 'TENTANG '),
                        TextSpan(text: 'E-LAPOR', style: TextStyle(color: Color(0xFF89CFF0))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'E-Lapor adalah inisiatif teknologi sipil yang dirancang untuk menjembatani aspirasi masyarakat dengan transparansi tata kelola pemerintahan. Kami percaya bahwa setiap masalah lingkungan—mulai dari infrastruktur yang rusak hingga sanitasi yang buruk—adalah prioritas yang layak mendapatkan perhatian cepat.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade50,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Visi Kami', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightBlue)),
                              SizedBox(height: 8),
                              Text('Mewujudkan lingkungan masyarakat yang teratur, bersih, dan aman melalui partisipasi aktif warga berbasis digital.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Misi Kami', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              SizedBox(height: 8),
                              Text('Menyediakan platform pelaporan yang mudah digunakan, transparan, dan dapat dipertanggungjawabkan secara real-time.', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Sistem ini terintegrasi langsung dengan panel administrator yang memverifikasi setiap laporan. Dengan teknologi enkripsi dan validasi data, kami memastikan identitas pelapor terlindungi sementara suara mereka tetap terdengar nyaring di pusat kendali layanan publik.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF89CFF0),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(
                      children: [
                        const Text('Mulai Langkah Anda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        const Text('Jadilah bagian dari solusi untuk kota kita.', style: TextStyle(fontSize: 14, color: Colors.white70)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.lightBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
