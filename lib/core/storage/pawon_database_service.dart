import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Service Local Storage berbasis SQLite (sqflite)
/// Digunakan untuk menyimpan cache data panen, lahan, dan aktivitas secara offline.
class PawonDatabaseService {
  static final PawonDatabaseService instance = PawonDatabaseService._init();
  static Database? _database;

  PawonDatabaseService._init();

  Future<Database?> get database async {
    if (kIsWeb) {
      // sqflite default tidak berjalan langsung di web standar tanpa FFI
      return null;
    }
    if (_database != null) return _database!;
    _database = await _initDB('pawontani_local.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Cache Panen Lokal
    await db.execute('''
      CREATE TABLE local_panen (
        id TEXT PRIMARY KEY,
        kode_panen TEXT,
        komoditas_nama TEXT,
        varietas TEXT,
        jumlah_berat REAL,
        satuan_berat TEXT,
        tanggal_panen TEXT,
        status TEXT,
        catatan TEXT,
        synced_at TEXT
      )
    ''');

    // Tabel Cache Ringkasan Lahan Lokal
    await db.execute('''
      CREATE TABLE local_lahan (
        id TEXT PRIMARY KEY,
        nama_lahan TEXT,
        luas_m2 REAL,
        alamat TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT,
        synced_at TEXT
      )
    ''');
  }

  // ==================== CRUD CACHE PANEN ====================

  /// Simpan atau update kumpulan data panen dari server ke SQLite
  Future<void> cachePanenList(List<Map<String, dynamic>> panenList) async {
    final db = await database;
    if (db == null) return;

    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    for (final item in panenList) {
      batch.insert(
        'local_panen',
        {
          'id': item['id']?.toString() ?? '',
          'kode_panen': item['kode_panen']?.toString() ?? '',
          'komoditas_nama': item['komoditas_nama']?.toString() ?? '',
          'varietas': item['varietas']?.toString() ?? '',
          'jumlah_berat': (item['jumlah_berat'] as num?)?.toDouble() ?? 0.0,
          'satuan_berat': item['satuan_berat']?.toString() ?? 'kg',
          'tanggal_panen': item['tanggal_panen']?.toString() ?? '',
          'status': item['status']?.toString() ?? 'menunggu',
          'catatan': item['catatan']?.toString() ?? '',
          'synced_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// Ambil data panen tersimpan di SQLite lokal saat offline
  Future<List<Map<String, dynamic>>> getLocalPanenList() async {
    final db = await database;
    if (db == null) return [];

    return await db.query(
      'local_panen',
      orderBy: 'tanggal_panen DESC',
    );
  }

  /// Hapus seluruh cache saat logout
  Future<void> clearAllCache() async {
    final db = await database;
    if (db == null) return;
    await db.delete('local_panen');
    await db.delete('local_lahan');
  }
}
