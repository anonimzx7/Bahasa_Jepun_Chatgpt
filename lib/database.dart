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

  /// Inisialisasi database dari assets
  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "data.db");

    // Cek apakah database sudah ada, jika belum, salin dari assets
    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load("assets/database/data.db");
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(path);
  }

  /// Mendapatkan data dari tabel sesuai pilihan pengguna (Hiragana atau Katakana)
  static Future<List<Map<String, dynamic>>> getData(
      {required String tabel, bool acak = false}) async {
    final db = await database;
    String query = "SELECT * FROM $tabel";
    if (acak) query += " ORDER BY RANDOM()";
    return await db.rawQuery(query);
  }
}
