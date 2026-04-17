import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(30)),
      ),
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          final userData = snapshot.data;
          final isLoggedIn = userData != null;
          final String role = userData?['role'] ?? 'user';
          final String name = userData?['name'] ?? 'Guest';
          final String initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

          return Column(
            children: [
              // Premium Header with Background Image
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  image: DecorationImage(
                    image: AssetImage('assets/images/hero-city.png'),
                    fit: BoxFit.cover,
                    opacity: 0.15, // Subtle background effect
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 34),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0F172A).withOpacity(0.95), 
                        const Color(0xFF1E293B).withOpacity(0.85)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: isLoggedIn ? const Color(0xFF38BDF8) : Colors.grey.shade400,
                          backgroundImage: userData?['foto'] != null 
                            ? NetworkImage('${ApiService.imgBaseUrl}/${userData!['foto']}') 
                            : null,
                          child: userData?['foto'] == null 
                            ? Text(
                                initial,
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: role == 'admin' ? const Color(0xFF818CF8) : Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu Items List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  children: [
                    _buildSectionTitle('NAVIGASI UTAMA'),
                    _buildMenuItem(context, Icons.home_rounded, 'Beranda', '/'),
                    _buildMenuItem(context, Icons.view_list_rounded, 'Semua Pengaduan', '/daftar-pengaduan'),
                    
                    if (isLoggedIn && role == 'admin') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('MANAJEMEN ADMIN'),
                      _buildMenuItem(
                        context, Icons.admin_panel_settings_rounded, 'Panel Admin', '/dashboard/admin',
                        isHighlight: true,
                      ),
                      _buildMenuItem(
                        context, Icons.people_alt_rounded, 'Data Pengguna', '/dashboard/admin/users',
                        isHighlight: true,
                      ),
                    ],

                    if (isLoggedIn && role == 'user') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('AREA PENGGUNA'),
                      _buildMenuItem(
                        context, Icons.dashboard_customize_rounded, 'Dasbor Saya', '/dashboard',
                        isHighlight: true,
                      ),
                    ],

                    if (role != 'admin') ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('INFORMASI'),
                      _buildMenuItem(context, Icons.info_rounded, 'Tentang Kami', '/tentang'),
                      _buildMenuItem(context, Icons.help_center_rounded, 'Cara Melapor', '/cara-melapor'),
                    ],

                    if (!isLoggedIn) ...[
                      const SizedBox(height: 16),
                      _buildSectionTitle('AKUN'),
                      _buildMenuItem(context, Icons.login_rounded, 'Masuk', '/login'),
                      _buildMenuItem(context, Icons.person_add_rounded, 'Daftar Akun', '/register'),
                    ],
                  ],
                ),
              ),

              // Logout Button Area
              if (isLoggedIn)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService().logout();
                      if (context.mounted) Navigator.pushReplacementNamed(context, '/');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEF2F2),
                      foregroundColor: const Color(0xFFEF4444),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('Keluar dari Akun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, 
    IconData icon, 
    String title, 
    String route, {
    bool isHighlight = false,
  }) {
    final String? currentRoute = ModalRoute.of(context)?.settings.name;
    final bool isActive = currentRoute == route;

    final Color activeColor = isHighlight ? const Color(0xFF4F46E5) : const Color(0xFF0EA5E9);
    final Color defaultColor = const Color(0xFF475569);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? activeColor.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: Icon(
          icon,
          color: isActive ? activeColor : defaultColor.withOpacity(0.7),
          size: 22,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? activeColor : defaultColor,
          ),
        ),
        onTap: () {
          Navigator.pop(context); // Close drawer
          if (!isActive) {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
