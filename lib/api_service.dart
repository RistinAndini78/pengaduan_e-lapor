import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // HARDCODED URL UNTUK MEMASTIKAN TIDAK ADA ERROR CACHE
  static const String baseUrl = 'https://e-lapor-production.up.railway.app/api';
  static const String imgBaseUrl = 'https://e-lapor-production.up.railway.app/storage';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _handleResponse(response);
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final data = _handleResponse(response);
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
         },
      );
    }
    await prefs.clear();
  }

  Future<List<dynamic>> getPengaduanPublik() async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan-publik'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<dynamic>.from(data);
      } else if (data is Map && data.containsKey('data')) {
        return List<dynamic>.from(data['data']);
      }
      return [];
    }
    throw Exception('Gagal memuat data publik.');
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal: ${response.statusCode}');
    }
  }

  Future<void> saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
    await prefs.setString('user', jsonEncode(user));
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<List<dynamic>> getAdminReports() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data.containsKey('data')) return List<dynamic>.from(data['data']);
      return [];
    }
    return [];
  }

  Future<List<dynamic>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return List<dynamic>.from(data);
      return [];
    }
    return [];
  }

  static Future<List<dynamic>> getPengaduanSaya() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data.containsKey('data')) return List<dynamic>.from(data['data']);
      return [];
    }
    throw Exception('Gagal memuat aduan Anda.');
  }

  static Future<List<dynamic>> getAllPengaduan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      if (data is List) return List<dynamic>.from(data);
      if (data is Map && data.containsKey('data')) return List<dynamic>.from(data['data']);
      return [];
    }
    throw Exception('Gagal memuat semua aduan.');
  }

  Future<void> updateReportStatus(int id, String newStatus) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    await http.patch(
      Uri.parse('$baseUrl/pengaduan/$id/status'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'status_laporan': newStatus}),
    );
  }

  static Future<void> deletePengaduan(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/pengaduan/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode >= 300) {
      throw Exception('Gagal menghapus laporan.');
    }
  }
}
