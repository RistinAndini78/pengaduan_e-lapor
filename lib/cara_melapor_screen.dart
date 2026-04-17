import 'package:flutter/material.dart';
import 'widgets/app_drawer.dart';

class CaraMelaporScreen extends StatelessWidget {
  const CaraMelaporScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      appBar: AppBar(
        title: const Text('Cara Kerja E-Lapor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
                children: [
                  TextSpan(text: 'Cara Kerja '),
                  TextSpan(text: 'E-LAPOR', style: TextStyle(color: Color(0xFF89CFF0))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ikuti panduan sederhana berikut untuk mengirimkan pengaduan Anda dengan benar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 48),
            _buildStepCard(
              context,
              number: '1',
              title: 'Registrasi & Login',
              description: 'Buat akun menggunakan email aktif Anda di halaman Daftar. Setelah memiliki akun, silakan masuk ke dashboard untuk memulai pelaporan.',
            ),
            _buildStepCard(
              context,
              number: '2',
              title: 'Isi Formulir Laporan',
              description: 'Pilih kategori masalah (contoh: Sanitasi), masukkan judul pengaduan yang jelas, deskripsikan masalah secara mendetail, dan cantumkan alamat lokasi kejadian seakurat mungkin.',
            ),
            _buildStepCard(
              context,
              number: '3',
              title: 'Unggah Bukti Foto',
              description: 'Lampirkan foto pendukung yang menunjukkan kondisi asli di lapangan. Foto yang jelas akan sangat membantu administrator dalam memverifikasi dan mempercepat tindak lanjut.',
            ),
            _buildStepCard(
              context,
              number: '4',
              title: 'Pantau Progres',
              description: 'Setelah dikirim, Anda dapat melihat status laporan Anda di dashboard. Status akan berubah dari Menunggu ke Diproses, hingga Selesai.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, {required String number, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.lightBlue),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
