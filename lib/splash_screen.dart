import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // TIMER 3 DETIK (BIAR GAK TERLALU SEBENTAR)
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient Subtle
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animasi
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 100,
                    color: Color(0xFF0EA5E9),
                  ),
                ).animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .shimmer(delay: 1.seconds, duration: 2.seconds),
                
                const SizedBox(height: 24),
                
                // Judul Aplikasi
                const Text(
                  'E-LAPOR',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: Color(0xFF0F172A),
                  ),
                ).animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.5, end: 0),
                  
                const SizedBox(height: 8),
                
                const Text(
                  'Layanan Aspirasi & Pengaduan Online',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ).animate()
                  .fadeIn(delay: 1.seconds),
              ],
            ),
          ),
          
          // Bagian Bawah (Versi / Branding)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: const Column(
              children: [
                CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0EA5E9)),
                SizedBox(height: 20),
                Text(
                  'Dikelola oleh Pemerintah Kota',
                  style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ).animate().fadeIn(delay: 1500.ms),
          ),
        ],
      ),
    );
  }
}
