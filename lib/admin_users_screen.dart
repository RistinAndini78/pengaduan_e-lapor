import 'package:flutter/material.dart';
import 'api_service.dart';
import 'widgets/app_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String _adminName = 'Admin Sistem';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
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

  Future<void> _fetchUsers() async {
    try {
      final users = await _apiService.getUsers();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data pengguna.')));
      }
    }
  }

  void _filterUsers() {
    final term = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final name = (u['name'] ?? '').toString().toLowerCase();
        final email = (u['email'] ?? '').toString().toLowerCase();
        return name.contains(term) || email.contains(term);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('MANAJEMEN PENGGUNA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF64748B), letterSpacing: 1.2)),
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
            onRefresh: _fetchUsers,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Manajemen Pengguna', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                          const SizedBox(height: 4),
                          const Text('Kelola hak akses dan profil administrator serta masyarakat.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {}, // Add logic later
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah Pengguna Baru', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // MAIN TABLE CARD
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Daftar Seluruh Pengguna', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Cari nama atau email...',
                                      hintStyle: TextStyle(fontSize: 11),
                                      prefixIcon: Icon(Icons.search, size: 16),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // TABLE HEADER
                        Container(
                          color: const Color(0xFFEEF2FF),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Row(
                            children: const [
                              Expanded(flex: 3, child: Text('PROFIL PENGGUNA', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)))),
                              Expanded(flex: 2, child: Text('HAK AKSES', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)))),
                              Expanded(flex: 2, child: Text('TERDAFTAR', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF4F46E5)))),
                            ],
                          ),
                        ),

                        _filteredUsers.isEmpty
                          ? const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Tidak ada pengguna.')))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserRow(_filteredUsers[index]);
                              },
                            ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }

  Widget _buildUserRow(dynamic user) {
    final String name = user['name'] ?? 'No Name';
    final String email = user['email'] ?? '-';
    final String role = (user['role'] ?? 'masyarakat').toString().toLowerCase();
    final String date = user['created_at']?.toString().substring(0, 10) ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          // Profil & Email
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFEEF2FF),
                  child: Text(name[0].toUpperCase(), style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF1E293B))),
                      Text(email, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Role Badge
          Expanded(
            flex: 2,
            child: UnconstrainedBox(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: role == 'admin' ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role.toUpperCase(), 
                  style: TextStyle(color: role == 'admin' ? Colors.white : Colors.grey.shade600, fontSize: 8, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),

          // Date & Actions
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
