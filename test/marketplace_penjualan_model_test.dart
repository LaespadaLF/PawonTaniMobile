import 'package:flutter_test/flutter_test.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/models/item_produk_saya.dart';

void main() {
  group('ItemProdukSaya Model Tests', () {
    test('fromJson parses correctly and calculates availability', () {
      final json = {
        'id_produk': 'PRD-20261124-0001',
        'id_pengguna': 'PGR-1234',
        'id_komoditas': 'kmdt-001',
        'nama_komoditas': 'Beras Pandanwangi',
        'nama_produk': 'Beras Organik Pandanwangi',
        'foto_produk': 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        'deskripsi': 'Beras pilihan tanpa pestisida',
        'jenis_harga': 'rentang',
        'harga': 14000.0,
        'harga_min': 14000.0,
        'harga_max': 16000.0,
        'harga_formatted': 'Rp 14.000 - Rp 16.000',
        'satuan': 'kg',
        'stok_fisik': 100.0,
        'stok_ditahan': 30.0,
        'stok_tersedia': 70.0,
        'total_terjual': 50.0,
        'status': 'aktif',
      };

      final item = ItemProdukSaya.fromJson(json);

      expect(item.idProduk, 'PRD-20261124-0001');
      expect(item.namaProduk, 'Beras Organik Pandanwangi');
      expect(item.hargaFormatted, 'Rp 14.000 - Rp 16.000');
      expect(item.stokFisik, 100.0);
      expect(item.stokDitahan, 30.0);
      expect(item.stokTersedia, 70.0);
      expect(item.totalTerjual, 50.0);
      expect(item.isAktif, isTrue);
      expect(item.isStokHabis, isFalse);
    });

    test('isStokHabis returns true when stokTersedia is 0', () {
      const item = ItemProdukSaya(
        idProduk: 'PRD-1',
        idPengguna: 'PGR-1',
        namaProduk: 'Jagung',
        jenisHarga: 'tetap',
        harga: 5000,
        hargaFormatted: 'Rp 5.000',
        satuan: 'kg',
        stokFisik: 50,
        stokDitahan: 50,
        stokTersedia: 0,
        totalTerjual: 200,
        status: 'stok_habis',
      );

      expect(item.isStokHabis, isTrue);
      expect(item.isAktif, isFalse);
    });
  });

  group('SaleItem Model Tests', () {
    test('fromJson parses multi-payment and handover status correctly', () {
      final json = {
        'id_penjualan': 'TRX-PN-20261124-001',
        'kode_transaksi': 'TRX-PN-20261124-001',
        'nama_produk': 'Cabai Rawit Merah',
        'nama_komoditas': 'Cabai',
        'jumlah': 50.0,
        'satuan': 'kg',
        'harga_satuan': 20000.0,
        'total_harga': 1000000.0,
        'total_dibayar': 300000.0,
        'sisa_pembayaran': 700000.0,
        'status_pembayaran': 'dp',
        'status_penyerahan': 'belum_diserahkan',
        'tanggal_transaksi': '2026-11-24',
        'waktu_transaksi': '10:30',
        'riwayat_pembayaran': [
          {
            'id_pembayaran': 'PAY-001',
            'nominal': 300000.0,
            'tanggal_pembayaran': '2026-11-24',
            'keterangan': 'DP Pertama',
            'status_verifikasi': 'terverifikasi',
          }
        ],
      };

      final sale = SaleItem.fromJson(json);

      expect(sale.id, 'TRX-PN-20261124-001');
      expect(sale.commodityName, 'Cabai Rawit Merah');
      expect(sale.volumeKg, 50.0);
      expect(sale.pricePerKg, 20000.0);
      expect(sale.totalValue, 1000000.0);
      expect(sale.totalReceived, 300000.0);
      expect(sale.remainingAmount, 700000.0);
      expect(sale.status, SaleStatus.uangMuka);
      expect(sale.isSudahDiserahkan, isFalse);
      expect(sale.isDibatalkan, isFalse);
      expect(sale.riwayatPembayaran.length, 1);
      expect(sale.riwayatPembayaran.first.nominal, 300000.0);
    });
  });
}
