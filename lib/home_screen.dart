import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoggedIn = false;
  String _userName = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await _apiService.isLoggedIn();
    if (loggedIn) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn = true;
        _userName = 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFF),
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.95),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            const Text(
              'E-Lapor',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          if (_isLoggedIn) ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/dashboard');
              },
              child: const Text(
                'Buat Laporan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0EA5E9)),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _apiService.logout();
                setState(() {
                  _isLoggedIn = false;
                });
              },
              child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ] else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Masuk', style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withOpacity(0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildFiturSection(),
            _buildLangkahSection(),
            _buildStatistikSection(),
            _buildCTASection(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFFF0F9FF), Colors.white],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _pulseAnimation,
                  child: const Icon(Icons.circle, color: Color(0xFF0EA5E9), size: 10),
                ),
                const SizedBox(width: 8),
                const Text(
                  'PLATFORM LAPORAN DIGITAL TERPERCAYA',
                  style: TextStyle(
                    color: Color(0xFF0284C7),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                height: 1.2,
                fontFamily: 'Plus Jakarta Sans',
              ),
              children: [
                TextSpan(text: 'Wujudkan Kota yang\n'),
                TextSpan(text: 'Lebih Baik', style: TextStyle(color: Color(0xFF38BDF8))),
                TextSpan(text: ' Melalui\nSuara Anda.'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'E-Lapor hadir sebagai jembatan masa kini antara aspirasi warga dan aksi nyata pemerintah. Laporkan berbagai isu lingkungan secara transparan, aman, dan cepat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Buat Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/daftar-pengaduan');
                },
                child: const Text('Lihat Pengaduan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Image.asset(
            'assets/images/hero-city.png',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildFiturSection() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          const Text(
            'Fitur Utama Sistem',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Kami memberikan kenyamanan dan keamanan dalam setiap laporan Anda.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _featureCard(Icons.phone_android, 'Kemudahan Melapor', 'Laporkan masalah cukup menggunakan ponsel Anda, lampirkan foto dan lokasi secara real-time.'),
          const SizedBox(height: 20),
          _featureCard(Icons.verified_user, 'Transparansi Proses', 'Pantau setiap tahapan tindak lanjut laporan Anda secara transparan hingga status selesai.'),
          const SizedBox(height: 20),
          _featureCard(Icons.access_time, 'Akses Online 24 Jam', 'Kami mendengarkan kapan saja. Layanan digital kami siap menerima aduan Anda 24/7 tanpa antre.'),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC).withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF0EA5E9), size: 28),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLangkahSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFC), Colors.white],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Column(
        children: [
          const Text(
            '4 Langkah Mudah Melapor',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Alur pengaduan yang ringkas dan efektif bagi seluruh warga.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          _stepItem('1', 'Daftar Akun', 'Buat akun untuk melacak dan mengelola laporan Anda secara personal.'),
          const SizedBox(height: 32),
          _stepItem('2', 'Isi Formulir', 'Jelaskan detail masalah, unggah foto, dan tentukan lokasi.'),
          const SizedBox(height: 32),
          _stepItem('3', 'Kirim Laporan', 'Laporan Anda akan diverifikasi oleh sistem dan administrator.'),
          const SizedBox(height: 32),
          _stepItem('4', 'Pantau Status', 'Dapatkan notifikasi perubahan status hingga masalah teratasi.'),
        ],
      ),
    );
  }

  Widget _stepItem(String number, String title, String desc) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0F2FE)),
          ),
          child: Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Center(
                child: Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildStatistikSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          _statItem('1,240+', 'Total Laporan'),
          const SizedBox(height: 16),
          _statItem('85', 'Sedang Diproses'),
          const SizedBox(height: 16),
          _statItem('1,155+', 'Laporan Selesai'),
        ],
      ),
    );
  }

  Widget _statItem(String number, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0F9FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE0F2FE)),
      ),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0EA5E9))),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8), letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildCTASection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8), Color(0xFF7DD3FC)],
          ),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Mari bangun kota yang lebih baik bersama-sama.',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Kontribusi kecil Anda dengan melapor dapat mencegah dampak besar bagi masyarakat sekitar.',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0EA5E9),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () {
                  if (_isLoggedIn) {
                    Navigator.pushNamed(context, '/dashboard');
                  } else {
                    Navigator.pushNamed(context, '/register');
                  }
                },
                child: const Text('Mulai Lapor Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('E-Lapor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          const Text(
            'Platform resmi laporan masyarakat untuk mewujudkan lingkungan yang lebih baik, transparan, dan teratur.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          const Text('Tautan Penting', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text('Syarat & Ketentuan', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Kebijakan Privasi', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Kontak Kami', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14)),
          const SizedBox(height: 32),
          const Text('Hubungi Kami', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          Text('"Suara Anda adalah langkah awal perubahan."', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          const Text('support@elapor.go.id', style: TextStyle(color: Color(0xFF475569), fontSize: 14)),
          const SizedBox(height: 40),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '© 2026 E-Lapor Sistem Pengaduan Masyarakat. All rights reserved.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
