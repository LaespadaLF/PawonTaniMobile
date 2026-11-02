/// Model data pengguna yang diautentikasi, memetakan respons JSON dari
/// endpoint Laravel PenggunaResource.
class AuthUserModel {
  final String id;
  final String nama;
  final String? nik;
  final String username;
  final String? email;
  final String? noTelepon;
  final String? alamat;
  final String? fotoProfil;
  final String role;
  final String status;
  final KelompokTaniModel? kelompokTani;
  final AnggotaModel? anggota;
  final LokasiModel? lokasi;

  const AuthUserModel({
    required this.id,
    required this.nama,
    this.nik,
    required this.username,
    this.email,
    this.noTelepon,
    this.alamat,
    this.fotoProfil,
    required this.role,
    required this.status,
    this.kelompokTani,
    this.anggota,
    this.lokasi,
  });

  /// Validasi apakah akun memiliki peran Anggota
  bool get isAnggota => role.toLowerCase() == 'anggota';

  /// Validasi apakah akun berstatus Aktif
  bool get isAktif => status.toLowerCase() == 'aktif';

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nik: json['nik']?.toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      noTelepon: json['no_telepon']?.toString(),
      alamat: json['alamat']?.toString(),
      fotoProfil: json['foto_profil']?.toString(),
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      kelompokTani: json['kelompok_tani'] != null && json['kelompok_tani'] is Map
          ? KelompokTaniModel.fromJson(Map<String, dynamic>.from(json['kelompok_tani']))
          : null,
      anggota: json['anggota'] != null && json['anggota'] is Map
          ? AnggotaModel.fromJson(Map<String, dynamic>.from(json['anggota']))
          : null,
      lokasi: json['lokasi'] != null && json['lokasi'] is Map
          ? LokasiModel.fromJson(Map<String, dynamic>.from(json['lokasi']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nik': nik,
      'username': username,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'foto_profil': fotoProfil,
      'role': role,
      'status': status,
      'kelompok_tani': kelompokTani?.toJson(),
      'anggota': anggota?.toJson(),
      'lokasi': lokasi?.toJson(),
    };
  }
}

class KelompokTaniModel {
  final String? idKelompok;
  final String? namaKelompok;
  final String? alamat;
  final String? status;

  const KelompokTaniModel({
    this.idKelompok,
    this.namaKelompok,
    this.alamat,
    this.status,
  });

  factory KelompokTaniModel.fromJson(Map<String, dynamic> json) {
    return KelompokTaniModel(
      idKelompok: json['id_kelompok']?.toString(),
      namaKelompok: json['nama_kelompok']?.toString(),
      alamat: json['alamat']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kelompok': idKelompok,
      'nama_kelompok': namaKelompok,
      'alamat': alamat,
      'status': status,
    };
  }
}

class AnggotaModel {
  final String? idAnggota;
  final String? statusKeanggotaan;

  const AnggotaModel({
    this.idAnggota,
    this.statusKeanggotaan,
  });

  factory AnggotaModel.fromJson(Map<String, dynamic> json) {
    return AnggotaModel(
      idAnggota: json['id_anggota']?.toString(),
      statusKeanggotaan: json['status_keanggotaan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_anggota': idAnggota,
      'status_keanggotaan': statusKeanggotaan,
    };
  }
}

class LokasiModel {
  final String? provinsiId;
  final String? kabupatenId;
  final String? kecamatanId;
  final String? desaId;
  final String? nama;
  final double? latitude;
  final double? longitude;

  const LokasiModel({
    this.provinsiId,
    this.kabupatenId,
    this.kecamatanId,
    this.desaId,
    this.nama,
    this.latitude,
    this.longitude,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(
      provinsiId: json['provinsi_id']?.toString(),
      kabupatenId: json['kabupaten_id']?.toString(),
      kecamatanId: json['kecamatan_id']?.toString(),
      desaId: json['desa_id']?.toString(),
      nama: json['nama']?.toString(),
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinsi_id': provinsiId,
      'kabupaten_id': kabupatenId,
      'kecamatan_id': kecamatanId,
      'desa_id': desaId,
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
