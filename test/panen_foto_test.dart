import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';
import 'package:pawon_mobile/features/panen/services/panen_multipart.dart';

void main() {
  group('HarvestItem.fromJson - daftar foto', () {
    test('foto utama dan seluruh daftar foto digabung tanpa duplikat', () {
      final item = HarvestItem.fromJson({
        'id': 'PN-1',
        'varietas': 'Ciherang',
        'berat_kg': 4500,
        'foto_panen': 'http://localhost/media/panen/a.jpg',
        'photos': [
          'http://localhost/media/panen/a.jpg',
          'http://localhost/media/panen/b.jpg',
          'http://localhost/media/panen/c.jpg',
        ],
      });

      expect(item.photos, [
        'http://localhost/media/panen/a.jpg',
        'http://localhost/media/panen/b.jpg',
        'http://localhost/media/panen/c.jpg',
      ]);
    });

    test('hanya ada foto_panen tanpa daftar photos', () {
      final item = HarvestItem.fromJson({
        'id': 'PN-2',
        'varietas': 'Ciherang',
        'berat_kg': 1000,
        'foto_panen': 'http://localhost/media/panen/satu.jpg',
      });

      expect(item.photos, ['http://localhost/media/panen/satu.jpg']);
    });
  });

  group('bangunFormDataPanen - existing_photos', () {
    test('daftar foto lama dikirim sebagai field berulang existing_photos[]',
        () {
      final formData = bangunFormDataPanen({
        'berat_kg': 4500,
        'existing_photos': <String>['panen/a.jpg', 'panen/b.jpg'],
      });

      final fields = formData.fields
          .where((e) => e.key == 'existing_photos[]')
          .map((e) => e.value)
          .toList();

      expect(fields, ['panen/a.jpg', 'panen/b.jpg']);
      // Tidak boleh dikirim sebagai satu string gabungan.
      expect(formData.fields.any((e) => e.key == 'existing_photos'), isFalse);
      expect(
        formData.fields.firstWhere((e) => e.key == 'berat_kg').value,
        '4500',
      );
    });

    test('daftar kosong tetap mengirim penanda array kosong', () {
      final formData = bangunFormDataPanen({
        'existing_photos': const <String>[],
      });

      final fields = formData.fields
          .where((e) => e.key == 'existing_photos[]')
          .map((e) => e.value)
          .toList();

      expect(fields, ['']);
    });

    test('foto baru tetap dikirim lewat foto_panen_list[]', () {
      final foto = MultipartFile.fromBytes(
        [1, 2, 3],
        filename: 'panen_baru.jpg',
      );

      final formData = bangunFormDataPanen(
        {'existing_photos': <String>['panen/a.jpg']},
        fotoPanenList: [foto],
      );

      expect(
        formData.files.map((e) => e.key).toList(),
        ['foto_panen_list[]'],
      );
      expect(
        formData.fields
            .where((e) => e.key == 'existing_photos[]')
            .map((e) => e.value),
        ['panen/a.jpg'],
      );
    });
  });
}
