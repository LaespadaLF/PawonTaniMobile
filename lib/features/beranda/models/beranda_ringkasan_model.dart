/// Model data representasi ringkasan dashboard beranda mobile.
class BerandaRingkasanModel {
  final BerandaUserModel user;
  final BerandaStatistikModel statistik;
  final BerandaCuacaModel cuaca;
  final List<BerandaArtikelModel> artikels;

  const BerandaRingkasanModel({
    required this.user,
    required this.statistik,
    required this.cuaca,
    required this.artikels,
  });

  factory BerandaRingkasanModel.fromJson(Map<String, dynamic> json) {
    return BerandaRingkasanModel(
      user: BerandaUserModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
      statistik: BerandaStatistikModel.fromJson(
        Map<String, dynamic>.from(json['statistik'] as Map? ?? {}),
      ),
      cuaca: BerandaCuacaModel.fromJson(
        Map<String, dynamic>.from(json['cuaca'] as Map? ?? {}),
      ),
      artikels: (json['artikels'] as List? ?? [])
          .map((item) => BerandaArtikelModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class BerandaUserModel {
  final String nama;
  final String role;
  final String kelompok;

  const BerandaUserModel({
    required this.nama,
    required this.role,
    required this.kelompok,
  });

  factory BerandaUserModel.fromJson(Map<String, dynamic> json) {
    return BerandaUserModel(
      nama: json['nama'] as String? ?? 'Petani PawonTani',
      role: json['role'] as String? ?? 'Anggota',
      kelompok: json['kelompok'] as String? ?? 'Kelompok Tani',
    );
  }
}

class BerandaStatistikModel {
  final int totalLahan;
  final int lahanAktif;
  final int lahanIstirahat;
  final int lahanPersiapan;
  final double totalLuasHa;
  final int totalKomoditas;
  final List<String> komoditasList;
  final int totalAktivitas;

  const BerandaStatistikModel({
    required this.totalLahan,
    required this.lahanAktif,
    required this.lahanIstirahat,
    required this.lahanPersiapan,
    required this.totalLuasHa,
    required this.totalKomoditas,
    required this.komoditasList,
    required this.totalAktivitas,
  });

  factory BerandaStatistikModel.fromJson(Map<String, dynamic> json) {
    return BerandaStatistikModel(
      totalLahan: (json['total_lahan'] as num?)?.toInt() ?? 0,
      lahanAktif: (json['lahan_aktif'] as num?)?.toInt() ?? 0,
      lahanIstirahat: (json['lahan_istirahat'] as num?)?.toInt() ?? 0,
      lahanPersiapan: (json['lahan_persiapan'] as num?)?.toInt() ?? 0,
      totalLuasHa: (json['total_luas_ha'] as num?)?.toDouble() ?? 0.0,
      totalKomoditas: (json['total_komoditas'] as num?)?.toInt() ?? 0,
      komoditasList: (json['komoditas_list'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      totalAktivitas: (json['total_aktivitas'] as num?)?.toInt() ?? 0,
    );
  }
}

class BerandaCuacaModel {
  final int suhu;
  final int kelembapan;
  final double kecepatanAngin;
  final int kodeCuaca;
  final String kondisi;
  final String lokasi;
  final int suhuMaks;
  final int suhuMin;
  final int peluangHujan;
  final List<ForecastDailyModel> forecastDaily;

  const BerandaCuacaModel({
    required this.suhu,
    required this.kelembapan,
    required this.kecepatanAngin,
    required this.kodeCuaca,
    required this.kondisi,
    required this.lokasi,
    required this.suhuMaks,
    required this.suhuMin,
    required this.peluangHujan,
    required this.forecastDaily,
  });

  factory BerandaCuacaModel.fromJson(Map<String, dynamic> json) {
    return BerandaCuacaModel(
      suhu: (json['suhu'] as num?)?.toInt() ?? 28,
      kelembapan: (json['kelembapan'] as num?)?.toInt() ?? 80,
      kecepatanAngin: (json['kecepatan_angin'] as num?)?.toDouble() ?? 4.0,
      kodeCuaca: (json['kode_cuaca'] as num?)?.toInt() ?? 2,
      kondisi: json['kondisi'] as String? ?? 'Cerah Berawan',
      lokasi: json['lokasi'] as String? ?? 'Jember, Jawa Timur',
      suhuMaks: (json['suhu_maks'] as num?)?.toInt() ?? 31,
      suhuMin: (json['suhu_min'] as num?)?.toInt() ?? 24,
      peluangHujan: (json['peluang_hujan'] as num?)?.toInt() ?? 20,
      forecastDaily: (json['forecast_daily'] as List? ?? [])
          .map((item) => ForecastDailyModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class ForecastDailyModel {
  final String tanggal;
  final int kode;
  final String kondisi;
  final int suhuMaks;
  final int suhuMin;
  final int hujanPersen;

  const ForecastDailyModel({
    required this.tanggal,
    required this.kode,
    required this.kondisi,
    required this.suhuMaks,
    required this.suhuMin,
    required this.hujanPersen,
  });

  factory ForecastDailyModel.fromJson(Map<String, dynamic> json) {
    return ForecastDailyModel(
      tanggal: json['tanggal'] as String? ?? '',
      kode: (json['kode'] as num?)?.toInt() ?? 0,
      kondisi: json['kondisi'] as String? ?? 'Cerah',
      suhuMaks: (json['suhu_maks'] as num?)?.toInt() ?? 30,
      suhuMin: (json['suhu_min'] as num?)?.toInt() ?? 24,
      hujanPersen: (json['hujan_persen'] as num?)?.toInt() ?? 0,
    );
  }
}

class BerandaArtikelModel {
  final String id;
  final String judul;
  final String? kategori;
  final String? tanggal;
  final String? gambar;
  final String? konten;

  const BerandaArtikelModel({
    required this.id,
    required this.judul,
    this.kategori,
    this.tanggal,
    this.gambar,
    this.konten,
  });

  factory BerandaArtikelModel.fromJson(Map<String, dynamic> json) {
    return BerandaArtikelModel(
      id: json['id_artikel']?.toString() ?? '',
      judul: json['judul'] as String? ?? '',
      kategori: json['kategori'] as String?,
      tanggal: json['tanggal'] as String?,
      gambar: json['gambar'] as String?,
      konten: json['konten'] as String?,
    );
  }
}
