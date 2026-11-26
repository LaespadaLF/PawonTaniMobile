import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/network/api_response.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/features/penjualan/models/item_penjualan.dart';
import 'package:pawon_mobile/features/penjualan/models/item_produk_saya.dart';

class MarketplacePenjualanApiService {
  final DioClient _client;

  MarketplacePenjualanApiService({DioClient? client}) : _client = client ?? DioClient();

  // ================= HARGA PASAR =================

  /// Ambil referensi harga pasar dari backend (sama dengan dashboard pengurus)
  Future<ApiResponse<List<Map<String, dynamic>>>> getHargaPasarList() async {
    return await _client.get<List<Map<String, dynamic>>>(
      ApiConstants.hargaPasarEndpoint,
      fromJson: (data) {
        if (data is! List) return <Map<String, dynamic>>[];
        return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      },
    );
  }

  // ================= PRODUK SAYA =================

  /// Ambil daftar produk marketplace milik petani login
  Future<ApiResponse<List<ItemProdukSaya>>> getProdukSayaList() async {
    return await _client.get<List<ItemProdukSaya>>(
      ApiConstants.marketplaceProdukEndpoint,
      fromJson: (data) {
        if (data is! List) return <ItemProdukSaya>[];
        return data
            .map((item) => ItemProdukSaya.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }

  /// Tambah produk marketplace baru
  Future<ApiResponse<ItemProdukSaya>> createProduk(
    Map<String, dynamic> payload, {
    XFile? fotoFile,
  }) async {
    final map = <String, dynamic>{...payload};
    if (fotoFile != null) {
      final bytes = await fotoFile.readAsBytes();
      map['foto'] = MultipartFile.fromBytes(
        bytes,
        filename: fotoFile.name.isNotEmpty ? fotoFile.name : 'foto_produk.jpg',
      );
    }
    final formData = FormData.fromMap(map);

    return await _client.post<ItemProdukSaya>(
      ApiConstants.marketplaceProdukEndpoint,
      data: formData,
      fromJson: (data) => ItemProdukSaya.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Update data produk marketplace
  Future<ApiResponse<ItemProdukSaya>> updateProduk(
    String id,
    Map<String, dynamic> payload, {
    XFile? fotoFile,
  }) async {
    final map = <String, dynamic>{...payload};
    if (fotoFile != null) {
      final bytes = await fotoFile.readAsBytes();
      map['foto'] = MultipartFile.fromBytes(
        bytes,
        filename: fotoFile.name.isNotEmpty ? fotoFile.name : 'foto_produk.jpg',
      );
    }
    final formData = FormData.fromMap(map);

    return await _client.post<ItemProdukSaya>(
      '${ApiConstants.marketplaceProdukEndpoint}/$id',
      data: formData,
      fromJson: (data) => ItemProdukSaya.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Arsipkan / hapus produk marketplace
  Future<ApiResponse<void>> deleteProduk(String id) async {
    return await _client.delete<void>(
      '${ApiConstants.marketplaceProdukEndpoint}/$id',
    );
  }

  // ================= TRANSAKSI PENJUALAN =================

  /// Ambil daftar riwayat penjualan
  Future<ApiResponse<List<SaleItem>>> getPenjualanList({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return await _client.get<List<SaleItem>>(
      ApiConstants.penjualanEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (data) {
        if (data is! List) return <SaleItem>[];
        return data
            .map((item) => SaleItem.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
      },
    );
  }

  /// Ambil detail transaksi penjualan
  Future<ApiResponse<SaleItem>> getPenjualanDetail(String id) async {
    return await _client.get<SaleItem>(
      '${ApiConstants.penjualanEndpoint}/$id',
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Catat transaksi penjualan baru
  Future<ApiResponse<SaleItem>> catatPenjualan(Map<String, dynamic> payload) async {
    return await _client.post<SaleItem>(
      ApiConstants.penjualanEndpoint,
      data: payload,
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Tambah pembayaran bertahap (DP tambahan / cicilan)
  Future<ApiResponse<SaleItem>> tambahPembayaran(
    String idPenjualan, {
    required double nominal,
    String? keterangan,
    String? tanggal,
  }) async {
    return await _client.post<SaleItem>(
      '${ApiConstants.penjualanEndpoint}/$idPenjualan/pembayaran',
      data: {
        'nominal': nominal,
        'keterangan': keterangan ?? 'Pembayaran Bertahap',
        'tanggal_pembayaran': ?tanggal,
      },
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Tandai transaksi Lunas
  Future<ApiResponse<SaleItem>> tandaiLunas(String idPenjualan) async {
    return await _client.post<SaleItem>(
      '${ApiConstants.penjualanEndpoint}/$idPenjualan/lunas',
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Batalkan transaksi penjualan
  Future<ApiResponse<SaleItem>> batalkanTransaksi(
    String idPenjualan, {
    required String alasanBatal,
  }) async {
    return await _client.post<SaleItem>(
      '${ApiConstants.penjualanEndpoint}/$idPenjualan/batalkan',
      data: {
        'alasan_batal': alasanBatal,
      },
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  /// Tandai barang sudah diserahkan
  Future<ApiResponse<SaleItem>> tandaiDiserahkan(String idPenjualan) async {
    return await _client.post<SaleItem>(
      '${ApiConstants.penjualanEndpoint}/$idPenjualan/serahkan',
      fromJson: (data) => SaleItem.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }
}
