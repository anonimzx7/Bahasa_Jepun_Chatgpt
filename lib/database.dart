import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class DatabaseHelper {
  static Database? _database;

  /// Mengembalikan instance database, memastikan hanya satu yang dibuat.
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi database dari assets jika belum ada
  static Future<Database> _initDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, "data.db");

      // Cek apakah database sudah ada di perangkat
      if (!await File(path).exists()) {
        ByteData data = await rootBundle.load("assets/database/data.db");
        List<int> bytes = data.buffer.asUint8List();
        await File(path).writeAsBytes(bytes, flush: true);
      }

      return await openDatabase(path);
    } catch (e) {
      throw Exception("Gagal menginisialisasi database: ${e.toString()}");
    }
  }

  /// Mengecek apakah database terhubung dan menampilkan jumlah tabel serta kolom
  static Future<String> ujiKoneksi() async {
    try {
      final db = await database;

      // Menghitung jumlah tabel
      List<Map<String, dynamic>> tabelResult = await db.rawQuery(
        "SELECT COUNT(*) as jumlahTabel FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      int jumlahTabel =
          tabelResult.isNotEmpty ? tabelResult.first['jumlahTabel'] ?? 0 : 0;

      // Menghitung jumlah total kolom dalam semua tabel
      int jumlahKolom = 0;
      List<Map<String, dynamic>> daftarTabel = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      for (var tabel in daftarTabel) {
        String namaTabel = tabel['name'] as String;
        List<Map<String, dynamic>> kolomResult = await db.rawQuery(
          "PRAGMA table_info($namaTabel)",
        );
        jumlahKolom +=
            kolomResult.length; // Menambahkan jumlah kolom untuk tabel ini
      }

      return "Database terhubung!\nJumlah tabel: $jumlahTabel\nJumlah kolom: $jumlahKolom";
    } catch (e) {
      return "Gagal menghubungkan ke database: ${e.toString()}";
    }
  }

  /// Mendapatkan data dari tabel sesuai pilihan pengguna (Hiragana atau Katakana)
  // Di dalam class DatabaseHelper
  static Future<List<Map<String, dynamic>>> getData({
    required String tabel,
    bool acak = false,
    required String kategori, // Menambahkan kategori
  }) async {
    try {
      final db = await database;
      String query = "SELECT * FROM $tabel WHERE kategori = ?";
      if (acak) query += " ORDER BY RANDOM()";
      return await db.rawQuery(query, [kategori]);
    } catch (e) {
      throw Exception("Gagal mengambil data dari $tabel: ${e.toString()}");
    }
  }
}
