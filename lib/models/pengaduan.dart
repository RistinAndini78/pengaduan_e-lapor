class Pengaduan {
  final int? id;
  final String judul;
  final String deskripsi;
  final String lokasi;
  final String? foto;
  final String status;
  final String? tanggal;
  final String? kategori;

  Pengaduan({
    this.id,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    this.foto,
    required this.status,
    this.tanggal,
    this.kategori,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'],
      judul: json['judul_pengaduan'] ?? '',
      deskripsi: json['deskripsi_masalah'] ?? '',
      lokasi: json['lokasi_kejadian'] ?? '',
      foto: json['foto_bukti'],
      status: json['status_laporan'] ?? 'menunggu',
      tanggal: json['created_at'],
      kategori: json['category'] != null ? json['category']['judul'] : (json['category_id']?.toString() ?? ''),
    );
  }
}
