import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/utils/waktu_relatif_util.dart';
import 'package:pawon_mobile/features/notifikasi/models/item_notifikasi.dart';
import 'package:pawon_mobile/features/notifikasi/repositories/notifikasi_repository.dart';
import 'package:pawon_mobile/features/notifikasi/services/notifikasi_api_service.dart';

class MockNotifikasiApiService extends NotifikasiApiService {
  bool shouldFail = false;
  int unreadCountToReturn = 5;
  List<ItemNotifikasi> itemsToReturn = [];

  @override
  Future<ApiResponse<List<ItemNotifikasi>>> getNotifikasiList({
    String filter = 'semua',
    int page = 1,
  }) async {
    if (shouldFail) {
      return ApiResponse.error(message: 'Simulated API failure');
    }
    return ApiResponse.success(
      data: itemsToReturn,
      meta: {
        'current_page': page,
        'last_page': 2,
        'per_page': 15,
        'total': itemsToReturn.length,
      },
    );
  }

  @override
  Future<ApiResponse<int>> getUnreadCount() async {
    if (shouldFail) {
      return ApiResponse.error(message: 'Simulated count failure');
    }
    return ApiResponse.success(data: unreadCountToReturn);
  }

  @override
  Future<ApiResponse<ItemNotifikasi>> markAsRead(String id) async {
    if (shouldFail) {
      return ApiResponse.error(message: 'Simulated mark failure');
    }
    final matched = itemsToReturn.firstWhere(
      (e) => e.id == id,
      orElse: () => ItemNotifikasi(
        id: id,
        idNotifikasi: id,
        jenisNotifikasi: 'lahan_terverifikasi',
        judul: 'Test',
        pesan: 'Test',
        idPenerima: 'USR-01',
        sudahDibaca: true,
      ),
    );
    return ApiResponse.success(data: matched.copyWith(sudahDibaca: true));
  }

  @override
  Future<ApiResponse<int>> markAllAsRead() async {
    if (shouldFail) {
      return ApiResponse.error(message: 'Simulated mark-all failure');
    }
    return ApiResponse.success(data: unreadCountToReturn);
  }
}

void main() {
  group('1. ItemNotifikasi Model & Parser Tests', () {
    test('1.1 Mem-parsing notifikasi Lahan dengan payload lengkap', () {
      final json = {
        'id_notifikasi': 'NTF-20261125-001',
        'id': 'NTF-20261125-001',
        'jenis_notifikasi': 'lahan_terverifikasi',
        'judul': 'Lahan Berhasil Diverifikasi',
        'pesan': 'Lahan Sawah Kulon telah diverifikasi oleh Ketua.',
        'id_pengirim': 'PGR-8046',
        'pengirim_nama': 'Ketua PokTan',
        'id_penerima': 'PGR-7219',
        'id_lahan': 'LHN-001',
        'nama_lahan': 'Sawah Kulon',
        'data_payload': {
          'id_lahan': 'LHN-001',
          'nama_lahan': 'Sawah Kulon',
          'nomor_revisi': 1,
        },
        'sudah_dibaca': false,
        'dibaca_pada': null,
        'created_at': '2026-11-25T08:30:00Z',
      };

      final item = ItemNotifikasi.fromJson(json);

      expect(item.id, 'NTF-20261125-001');
      expect(item.idNotifikasi, 'NTF-20261125-001');
      expect(item.jenisNotifikasi, 'lahan_terverifikasi');
      expect(item.entityType, 'lahan');
      expect(item.targetLahanId, 'LHN-001');
      expect(item.entityId, 'LHN-001');
      expect(item.isRead, false);
      expect(item.createdAt, isNotNull);
    });

    test('1.2 Mem-parsing notifikasi Siklus Tanam dengan payload entity_type', () {
      final json = {
        'id_notifikasi': 'NTF-20261125-002',
        'jenis_notifikasi': 'siklus_pengajuan_selesai',
        'judul': 'Pengajuan Pengakhiran Siklus',
        'pesan': 'Pengajuan selesai siklus tanam Ciherang.',
        'id_penerima': 'PGR-8046',
        'data_payload': {
          'entity_type': 'siklus_tanam',
          'entity_id': 'SKL-001',
          'id_lahan': 'LHN-002',
          'status': 'menunggu_selesai',
        },
        'sudah_dibaca': true,
        'dibaca_pada': '2026-11-25T09:00:00Z',
        'created_at': '2026-11-25T08:45:00Z',
      };

      final item = ItemNotifikasi.fromJson(json);

      expect(item.id, 'NTF-20261125-002');
      expect(item.entityType, 'siklus_tanam');
      expect(item.entityId, 'SKL-001');
      expect(item.targetSiklusId, 'SKL-001');
      expect(item.targetLahanId, 'LHN-002');
      expect(item.isRead, true);
      expect(item.dibacaPada, isNotNull);
    });

    test('1.3 Mem-parsing notifikasi Panen dengan payload lengkap', () {
      final json = {
        'id_notifikasi': 'NTF-20261125-003',
        'jenis_notifikasi': 'panen_pengajuan_baru',
        'judul': 'Catatan Panen Baru Diajukan',
        'pesan': 'Panen Padi Ciherang seberat 850 kg diajukan.',
        'id_penerima': 'PGR-8046',
        'data_payload': {
          'entity_type': 'panen',
          'entity_id': 'PNN-001',
          'kode_panen': 'PNN/20261125/001',
          'id_lahan': 'LHN-001',
          'id_siklus': 'SKL-001',
        },
        'sudah_dibaca': 0, // Format int dari raw DB
      };

      final item = ItemNotifikasi.fromJson(json);

      expect(item.entityType, 'panen');
      expect(item.targetPanenId, 'PNN-001');
      expect(item.targetSiklusId, 'SKL-001');
      expect(item.targetLahanId, 'LHN-001');
      expect(item.isRead, false);
    });

    test('1.4 Menangani field opsional null tanpa error / crash', () {
      final json = {
        'id_notifikasi': 'NTF-EMPTY',
        'judul': 'Notifikasi Sederhana',
        'pesan': 'Isi pesan sederhana',
        'id_penerima': 'USR-99',
      };

      final item = ItemNotifikasi.fromJson(json);

      expect(item.id, 'NTF-EMPTY');
      expect(item.idLahan, isNull);
      expect(item.namaLahan, isNull);
      expect(item.dataPayload, isNull);
      expect(item.createdAt, isNull);
      expect(item.isRead, false);
      expect(item.entityType, 'lainnya');
      expect(item.entityId, isNull);
    });

    test('1.5 copyWith berfungsi memodifikasi status read secara aman', () {
      const item = ItemNotifikasi(
        id: 'NTF-01',
        idNotifikasi: 'NTF-01',
        jenisNotifikasi: 'test',
        judul: 'Test',
        pesan: 'Test',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );

      final updated = item.copyWith(sudahDibaca: true);

      expect(item.sudahDibaca, false);
      expect(updated.sudahDibaca, true);
      expect(updated.id, 'NTF-01');
    });
  });

  group('2. WaktuRelatifUtil Tests', () {
    test('2.1 Format waktu null', () {
      expect(WaktuRelatifUtil.format(null), '-');
    });

    test('2.2 Format kurang dari 1 menit -> Baru saja', () {
      final dt = DateTime.now().subtract(const Duration(seconds: 25));
      expect(WaktuRelatifUtil.format(dt), 'Baru saja');
    });

    test('2.3 Format dalam menit', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 15));
      expect(WaktuRelatifUtil.format(dt), '15 menit lalu');
    });

    test('2.4 Format dalam jam', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(WaktuRelatifUtil.format(dt), '3 jam lalu');
    });

    test('2.5 Format kemarin', () {
      final dt = DateTime.now().subtract(const Duration(days: 1));
      expect(WaktuRelatifUtil.format(dt), 'Kemarin');
    });

    test('2.6 Format dalam hari', () {
      final dt = DateTime.now().subtract(const Duration(days: 4));
      expect(WaktuRelatifUtil.format(dt), '4 hari lalu');
    });

    test('2.7 Format lebih dari 30 hari', () {
      final dt = DateTime(2026, 1, 15);
      final formatted = WaktuRelatifUtil.format(dt);
      expect(formatted, contains('Jan 2026'));
    });
  });

  group('3. NotifikasiRepository State Management Tests', () {
    late MockNotifikasiApiService mockApi;
    late NotifikasiRepository repository;

    setUp(() {
      mockApi = MockNotifikasiApiService();
      repository = NotifikasiRepository(apiService: mockApi);
      repository.resetForTesting();
    });

    test('3.1 fetchUnreadCount memperbarui unreadCountListenable secara reaktif', () async {
      mockApi.unreadCountToReturn = 7;

      int notifiedCount = 0;
      repository.unreadCountListenable.addListener(() {
        notifiedCount = repository.unreadCount;
      });

      await repository.fetchUnreadCount();

      expect(repository.unreadCount, 7);
      expect(notifiedCount, 7);
    });

    test('3.2 loadInitial memuat data dan mengupdate status loaded', () async {
      final dummyItem = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'lahan_terverifikasi',
        judul: 'Lahan Diverifikasi',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );
      mockApi.itemsToReturn = [dummyItem];
      mockApi.unreadCountToReturn = 1;

      await repository.loadInitial();

      expect(repository.status, NotifikasiLoadStatus.loaded);
      expect(repository.items.length, 1);
      expect(repository.items.first.id, 'NTF-1');
    });

    test('3.3 markAsRead melakukan optimistic update dan decrement unreadCount', () async {
      final dummyItem = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Panen Disetujui',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );
      repository.resetForTesting(
        items: [dummyItem],
        unreadCount: 3,
        status: NotifikasiLoadStatus.loaded,
      );

      final success = await repository.markAsRead(dummyItem);

      expect(success, true);
      expect(repository.items.first.sudahDibaca, true);
      expect(repository.unreadCount, 2);
    });

    test('3.4 markAsRead melakukan rollback jika API server gagal', () async {
      mockApi.shouldFail = true;

      final dummyItem = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Panen Disetujui',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );
      repository.resetForTesting(
        items: [dummyItem],
        unreadCount: 3,
        status: NotifikasiLoadStatus.loaded,
      );

      final success = await repository.markAsRead(dummyItem);

      expect(success, false);
      expect(repository.items.first.sudahDibaca, false);
      expect(repository.unreadCount, 3);
    });

    test('3.5 markAllAsRead menandai semua read dan me-reset unreadCount ke 0', () async {
      final dummyItem1 = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Panen 1',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );
      final dummyItem2 = ItemNotifikasi(
        id: 'NTF-2',
        idNotifikasi: 'NTF-2',
        jenisNotifikasi: 'lahan_terverifikasi',
        judul: 'Lahan 1',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );
      repository.resetForTesting(
        items: [dummyItem1, dummyItem2],
        unreadCount: 2,
        status: NotifikasiLoadStatus.loaded,
      );

      final success = await repository.markAllAsRead();

      expect(success, true);
      expect(repository.unreadCount, 0);
      expect(repository.items.every((e) => e.sudahDibaca), true);
    });

    test('3.6 switchFilter beralih antara semua dan belum_dibaca', () async {
      mockApi.itemsToReturn = [];
      await repository.switchFilter('belum_dibaca');

      expect(repository.activeFilter, 'belum_dibaca');
      expect(repository.status, NotifikasiLoadStatus.loaded);
    });

    test('3.7 loadNextPage menambahkan item baru dan menghindari duplikasi ID', () async {
      final item1 = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Item 1',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
      );
      final item2 = ItemNotifikasi(
        id: 'NTF-2',
        idNotifikasi: 'NTF-2',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Item 2',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
      );

      repository.resetForTesting(
        items: [item1],
        status: NotifikasiLoadStatus.loaded,
      );
      // Simulate paginationMeta: page 1 of 2
      mockApi.itemsToReturn = [item1, item2]; // item1 is duplicate, item2 is new

      // Set pagination meta to allow next page
      await repository.loadInitial();
      mockApi.itemsToReturn = [item1, item2];
      await repository.loadNextPage();

      // Should contain 2 items without duplicating NTF-1
      expect(repository.items.length, 2);
      expect(repository.items.map((e) => e.id).toSet().length, 2);
    });

    test('3.8 refresh mempertahankan item lama jika API gagal', () async {
      final item1 = ItemNotifikasi(
        id: 'NTF-1',
        idNotifikasi: 'NTF-1',
        jenisNotifikasi: 'panen_disetujui',
        judul: 'Item 1',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
      );
      repository.resetForTesting(
        items: [item1],
        status: NotifikasiLoadStatus.loaded,
      );

      mockApi.shouldFail = true;
      await repository.refresh();

      // Data tidak hilang saat refresh gagal
      expect(repository.items.length, 1);
      expect(repository.items.first.id, 'NTF-1');
    });

    test('3.9 markAsRead untuk item di luar daftar tetap memanggil API dan mengurangi unreadCount', () async {
      final externalItem = ItemNotifikasi(
        id: 'NTF-EXT-99',
        idNotifikasi: 'NTF-EXT-99',
        jenisNotifikasi: 'lahan_terverifikasi',
        judul: 'External',
        pesan: 'Pesan',
        idPenerima: 'USR-01',
        sudahDibaca: false,
      );

      repository.resetForTesting(
        items: [],
        unreadCount: 4,
        status: NotifikasiLoadStatus.loaded,
      );

      final success = await repository.markAsRead(externalItem);

      expect(success, true);
      expect(repository.unreadCount, 3);
    });
  });
}
