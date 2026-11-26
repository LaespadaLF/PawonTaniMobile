import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/lahan/models/item_siklus_tanam.dart';

void main() {
  group('ItemSiklusTanam Phase 5 Pengakhiran Tests', () {
    test('ItemSiklusTanam parses Phase 5 termination and harvest realization fields correctly', () {
      final json = {
        'id_siklus': 'SKL-20261124-TERM1',
        'id_lahan': 'LHN-20261108-XB72',
        'id_komoditas': 'KMDT-001',
        'komoditas_nama': 'Padi Sawah',
        'varietas': 'Ciherang MT5',
        'musim_tanam': 'MT 1 - 2026',
        'tanggal_mulai': '2026-11-01',
        'estimasi_panen': '2027-02-01',
        'tanggal_selesai': '2027-02-15',
        'status': 'menunggu_selesai',
        'is_berjalan': true,
        'is_boleh_input': false,
        'jenis_pengakhiran': 'selesai',
        'tanggal_pengajuan': '2027-02-14T08:00:00Z',
        'tanggal_verifikasi': null,
        'alasan_pengakhiran': 'Seluruh petak telah dipanen dan timbangan telah disetujui.',
        'foto_bukti_gagal': null,
        'diverifikasi_oleh': null,
        'catatan_verifikasi': null,
        'target_panen_ton': 5.0,
        'total_panen_kg': 4800.0,
        'total_panen_ton': 4.8,
        'persentase_target': 96.0,
        'riwayat_pengakhiran': [
          {
            'id_riwayat': 'RWT-001',
            'jenis_pengakhiran': 'selesai',
            'aksi': 'pengajuan',
            'status_sebelumnya': 'aktif',
            'status_sesudahnya': 'menunggu_selesai',
            'alasan': 'Panen rampung',
            'foto_bukti': null,
            'verifikator_id': null,
            'verifikator_nama': null,
            'catatan_verifikasi': null,
            'tanggal_keputusan': null,
            'created_at': '2027-02-14T08:00:00Z',
          }
        ],
      };

      final siklus = ItemSiklusTanam.fromJson(json);

      expect(siklus.idSiklus, 'SKL-20261124-TERM1');
      expect(siklus.status, 'menunggu_selesai');
      expect(siklus.isAktif, isFalse);
      expect(siklus.isMenungguSelesai, isTrue);
      expect(siklus.isMenungguGagal, isFalse);
      expect(siklus.isMenungguVerifikasi, isTrue);
      expect(siklus.isTerminal, isFalse);
      expect(siklus.isBerjalan, isTrue);
      expect(siklus.isBolehInput, isFalse);
      expect(siklus.jenisPengakhiran, 'selesai');
      expect(siklus.targetPanenTon, 5.0);
      expect(siklus.totalPanenKg, 4800.0);
      expect(siklus.totalPanenTon, 4.8);
      expect(siklus.persentaseTarget, 96.0);
      expect(siklus.statusLabel, 'Menunggu Selesai');

      // Riwayat Pengakhiran Check
      expect(siklus.riwayatPengakhiran.length, 1);
      final rwt = siklus.riwayatPengakhiran.first;
      expect(rwt.idRiwayat, 'RWT-001');
      expect(rwt.aksi, 'pengajuan');
      expect(rwt.statusSebelumnya, 'aktif');
      expect(rwt.statusSesudahnya, 'menunggu_selesai');
      expect(rwt.alasan, 'Panen rampung');

      // Serialization roundtrip
      final serialized = siklus.toJson();
      expect(serialized['status'], 'menunggu_selesai');
      expect(serialized['total_panen_ton'], 4.8);
      expect(serialized['persentase_target'], 96.0);
      expect(serialized['riwayat_pengakhiran'], isList);
      expect((serialized['riwayat_pengakhiran'] as List).length, 1);
    });

    test('Status flags and terminal condition validation', () {
      final baseJson = {
        'id_siklus': 'SKL-BASE',
        'id_lahan': 'LHN-001',
        'id_komoditas': 'KMD-001',
        'komoditas_nama': 'Padi',
        'musim_tanam': 'MT 1',
      };

      final siklusAktif = ItemSiklusTanam.fromJson({...baseJson, 'status': 'aktif'});
      expect(siklusAktif.isAktif, isTrue);
      expect(siklusAktif.isTerminal, isFalse);
      expect(siklusAktif.isMenungguVerifikasi, isFalse);

      final siklusGagal = ItemSiklusTanam.fromJson({...baseJson, 'status': 'gagal'});
      expect(siklusGagal.isGagal, isTrue);
      expect(siklusGagal.isTerminal, isTrue);
      expect(siklusGagal.statusLabel, 'Gagal');

      final siklusBatal = ItemSiklusTanam.fromJson({...baseJson, 'status': 'dibatalkan'});
      expect(siklusBatal.isDibatalkan, isTrue);
      expect(siklusBatal.isTerminal, isTrue);
      expect(siklusBatal.statusLabel, 'Dibatalkan');

      final siklusSelesai = ItemSiklusTanam.fromJson({...baseJson, 'status': 'selesai'});
      expect(siklusSelesai.isSelesai, isTrue);
      expect(siklusSelesai.isTerminal, isTrue);
      expect(siklusSelesai.statusLabel, 'Selesai');
    });

    test('ItemRiwayatPengakhiran serialization and null safety', () {
      final rwtJson = {
        'id_riwayat': 'RWT-999',
        'jenis_pengakhiran': 'gagal',
        'aksi': 'persetujuan',
        'status_sebelumnya': 'menunggu_gagal',
        'status_sesudahnya': 'gagal',
        'alasan': 'Tanaman puso akibat banjir',
        'foto_bukti': 'bukti_banjir.jpg',
        'verifikator_id': 'PGR-8046',
        'verifikator_nama': 'Ketua Poktan',
        'catatan_verifikasi': 'Disetujui setelah survei lapangan',
        'tanggal_keputusan': '2026-11-24T20:00:00Z',
      };

      final rwt = ItemRiwayatPengakhiran.fromJson(rwtJson);
      expect(rwt.idRiwayat, 'RWT-999');
      expect(rwt.verifikatorNama, 'Ketua Poktan');
      expect(rwt.fotoBukti, 'bukti_banjir.jpg');

      final serialized = rwt.toJson();
      expect(serialized['id_riwayat'], 'RWT-999');
      expect(serialized['verifikator_id'], 'PGR-8046');
      expect(serialized['status_sesudahnya'], 'gagal');
    });
  });
}
