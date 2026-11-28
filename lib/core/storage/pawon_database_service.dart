import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Service Local Storage berbasis SQLite (sqflite)
/// Digunakan untuk menyimpan cache data panen, lahan, dan aktivitas secara offline,
/// serta antrean sinkronisasi (Offline Sync Queue) saat perangkat tidak terhubung ke internet.
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
    try {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _database = await _initDB('pawontani_local.db');
      return _database;
    } catch (e) {
      debugPrint('Error initializing local SQLite database: $e');
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabel Cache Panen Lokal
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_panen (
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

    // 2. Tabel Cache Lahan Lokal
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_lahan (
        id TEXT PRIMARY KEY,
        nama_lahan TEXT,
        luas_m2 REAL,
        alamat TEXT,
        komoditas TEXT,
        status_penguasaan TEXT,
        status_verifikasi TEXT,
        latitude REAL,
        longitude REAL,
        foto_lahan TEXT,
        synced_at TEXT
      )
    ''');

    // 3. Tabel Cache Aktivitas Tanam Lokal
    await db.execute('''
      CREATE TABLE IF NOT EXISTS local_aktivitas (
        id TEXT PRIMARY KEY,
        judul TEXT,
        komoditas TEXT,
        kategori TEXT,
        kondisi TEXT,
        tanggal TEXT,
        waktu TEXT,
        lokasi TEXT,
        blok TEXT,
        catatan TEXT,
        lahan_id TEXT,
        biaya REAL,
        foto_url TEXT,
        synced_at TEXT
      )
    ''');

    // 4. Tabel Antrean Sinkronisasi Offline (Draft/Pending Changes)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS offline_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipe TEXT NOT NULL,
        aksi TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        local_files TEXT,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL,
        error_message TEXT
      )
    ''');
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createDB(db, newVersion);
    }
  }

  // ==================== CRUD CACHE PANEN ====================

  /// Simpan atau update kumpulan data panen dari server ke SQLite
  Future<void> cachePanenList(List<Map<String, dynamic>> panenList) async {
    try {
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
    } catch (e) {
      debugPrint('Error caching panen list: $e');
    }
  }

  /// Ambil data panen tersimpan di SQLite lokal saat offline
  Future<List<Map<String, dynamic>>> getLocalPanenList() async {
    try {
      final db = await database;
      if (db == null) return [];

      return await db.query(
        'local_panen',
        orderBy: 'tanggal_panen DESC',
      );
    } catch (e) {
      debugPrint('Error getting local panen: $e');
      return [];
    }
  }

  // ==================== CRUD CACHE LAHAN ====================

  /// Simpan daftar lahan dari server ke SQLite
  Future<void> cacheLahanList(List<Map<String, dynamic>> lahanList) async {
    try {
      final db = await database;
      if (db == null) return;

      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      for (final item in lahanList) {
        batch.insert(
          'local_lahan',
          {
            'id': item['id']?.toString() ?? '',
            'nama_lahan': item['nama']?.toString() ?? '',
            'luas_m2': (item['luas'] as num?)?.toDouble() ?? 0.0,
            'alamat': item['lokasi']?.toString() ?? '',
            'komoditas': item['komoditas']?.toString() ?? '',
            'status_penguasaan': item['status_penguasaan']?.toString() ?? 'Milik Sendiri',
            'status_verifikasi': item['status_verifikasi']?.toString() ?? 'menunggu_verifikasi',
            'latitude': (item['latitude'] as num?)?.toDouble(),
            'longitude': (item['longitude'] as num?)?.toDouble(),
            'foto_lahan': item['foto_lahan']?.toString() ?? '',
            'synced_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error caching lahan list: $e');
    }
  }

  /// Ambil daftar lahan tersimpan di SQLite lokal saat offline
  Future<List<Map<String, dynamic>>> getLocalLahanList() async {
    try {
      final db = await database;
      if (db == null) return [];

      return await db.query(
        'local_lahan',
        orderBy: 'nama_lahan ASC',
      );
    } catch (e) {
      debugPrint('Error getting local lahan: $e');
      return [];
    }
  }

  // ==================== CRUD CACHE AKTIVITAS ====================

  /// Simpan daftar aktivitas ke SQLite
  Future<void> cacheAktivitasList(List<Map<String, dynamic>> aktivitasList) async {
    try {
      final db = await database;
      if (db == null) return;

      final batch = db.batch();
      final now = DateTime.now().toIso8601String();

      for (final item in aktivitasList) {
        batch.insert(
          'local_aktivitas',
          {
            'id': item['id']?.toString() ?? '',
            'judul': item['title']?.toString() ?? '',
            'komoditas': item['crop_name']?.toString() ?? '',
            'kategori': item['category']?.toString() ?? 'Pemupukan',
            'kondisi': item['condition']?.toString() ?? 'Sehat',
            'tanggal': item['date']?.toString() ?? '',
            'waktu': item['time']?.toString() ?? '',
            'lokasi': item['location']?.toString() ?? '',
            'blok': item['block_area']?.toString() ?? '',
            'catatan': item['notes']?.toString() ?? '',
            'lahan_id': item['lahan_id']?.toString() ?? '',
            'biaya': (item['biaya'] as num?)?.toDouble() ?? 0.0,
            'foto_url': item['image_url']?.toString() ?? '',
            'synced_at': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      debugPrint('Error caching aktivitas list: $e');
    }
  }

  /// Ambil daftar aktivitas tersimpan di SQLite lokal saat offline
  Future<List<Map<String, dynamic>>> getLocalAktivitasList() async {
    try {
      final db = await database;
      if (db == null) return [];

      return await db.query(
        'local_aktivitas',
        orderBy: 'tanggal DESC, waktu DESC',
      );
    } catch (e) {
      debugPrint('Error getting local aktivitas: $e');
      return [];
    }
  }

  // ==================== OFFLINE SYNC QUEUE ====================

  /// Masukkan aksi pembuatan/perubahan data ke antrean sinkronisasi
  Future<int> enqueueOffline({
    required String tipe,
    required String aksi,
    required Map<String, dynamic> payload,
    List<String>? localFiles,
  }) async {
    try {
      final db = await database;
      if (db == null) return -1;

      return await db.insert(
        'offline_sync_queue',
        {
          'tipe': tipe,
          'aksi': aksi,
          'payload_json': jsonEncode(payload),
          'local_files': localFiles != null ? jsonEncode(localFiles) : null,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'pending',
          'error_message': null,
        },
      );
    } catch (e) {
      debugPrint('Error enqueuing offline: $e');
      return -1;
    }
  }

  /// Ambil semua antrean yang berstatus 'pending' atau 'failed'
  Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    try {
      final db = await database;
      if (db == null) return [];

      return await db.query(
        'offline_sync_queue',
        where: 'status IN (?, ?)',
        whereArgs: ['pending', 'failed'],
        orderBy: 'id ASC',
      );
    } catch (e) {
      debugPrint('Error getting pending queue: $e');
      return [];
    }
  }

  /// Hitung total antrean yang belum tersinkronisasi
  Future<int> getPendingQueueCount() async {
    try {
      final db = await database;
      if (db == null) return 0;

      final count = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM offline_sync_queue WHERE status IN (?, ?)',
        ['pending', 'failed'],
      ));

      return count ?? 0;
    } catch (e) {
      debugPrint('Error getting pending queue count: $e');
      return 0;
    }
  }

  /// Tandai antrean sebagai berhasil dan hapus dari database
  Future<void> removeQueueItem(int id) async {
    final db = await database;
    if (db == null) return;

    await db.delete(
      'offline_sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Perbarui status antrean (misal saat sedang diproses atau gagal)
  Future<void> updateQueueStatus(int id, String status, {String? errorMessage}) async {
    final db = await database;
    if (db == null) return;

    await db.update(
      'offline_sync_queue',
      {
        'status': status,
        'error_message': errorMessage,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Hapus seluruh cache dan antrean saat logout
  Future<void> clearAllCache() async {
    final db = await database;
    if (db == null) return;
    await db.delete('local_panen');
    await db.delete('local_lahan');
    await db.delete('local_aktivitas');
    await db.delete('offline_sync_queue');
  }
}
