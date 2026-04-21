import 'package:flutter/material.dart';
import '../models/pengaduan.dart';
import '../api_service.dart';

enum PengaduanState { loading, error, success }

class PengaduanProvider with ChangeNotifier {
  List<Pengaduan> _pengaduans = [];
  PengaduanState _state = PengaduanState.loading;
  String _errorMessage = '';

  List<Pengaduan> get pengaduans => _pengaduans;
  PengaduanState get state => _state;
  String get errorMessage => _errorMessage;

  Future<void> fetchPengaduans() async {
    _state = PengaduanState.loading;
    notifyListeners();

    try {
      final List<dynamic> data = await ApiService.getPengaduanSaya();
      _pengaduans = data.map((json) => Pengaduan.fromJson(json)).toList();
      _state = PengaduanState.success;
    } catch (e) {
      _state = PengaduanState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchSemuaPengaduan() async {
    _state = PengaduanState.loading;
    notifyListeners();

    try {
      final List<dynamic> data = await ApiService.getAllPengaduan();
      _pengaduans = data.map((json) => Pengaduan.fromJson(json)).toList();
      _state = PengaduanState.success;
    } catch (e) {
      _state = PengaduanState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteReport(int id) async {
    try {
      await ApiService.deletePengaduan(id);
      _pengaduans.removeWhere((p) => p.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
