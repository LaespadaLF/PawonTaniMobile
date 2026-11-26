enum HarvestStatus {
  menunggu,
  disetujui,
  ditolak;

  String get displayName {
    switch (this) {
      case HarvestStatus.disetujui:
        return 'Disetujui';
      case HarvestStatus.ditolak:
        return 'Ditolak';
      case HarvestStatus.menunggu:
        return 'Menunggu';
    }
  }

  static HarvestStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'disetujui':
      case 'approved':
      case 'terverifikasi':
        return HarvestStatus.disetujui;
      case 'ditolak':
      case 'rejected':
        return HarvestStatus.ditolak;
      case 'menunggu':
      case 'pending':
      default:
        return HarvestStatus.menunggu;
    }
  }
}

enum CropType {
  padi,
  jagung;

  String get displayName => this == CropType.padi ? 'Padi' : 'Jagung';

  static CropType fromString(String? val) {
    final lower = val?.toLowerCase().trim() ?? '';
    if (lower.contains('jagung')) return CropType.jagung;
    return CropType.padi;
  }
}

class HarvestItem {
  final String id;
  final String harvestCode;
  final String title;
  final String subtitle;
  final CropType cropType;
  final HarvestStatus status;
  final String idLahan;
  final String location;
  final String blockArea;
  final String date;
  final String harvestTime;
  final String season;
  final String poktan;
  final double weightKg;
  final String qualityGrade;
  final String moistureOrNotes;
  final double moisturePercent;
  final double wholeGrainPercent;
  final double wastePercent;
  final String harvestMethod;
  final double harvestCost;
  final String costWorkers;
  final double pricePerKg;
  final String fieldNotes;
  final String validatedBy;
  final String validatedAt;
  final String? validatedNotes;
  final List<String> photos;
  final String? idSiklus;

  bool get isLegacy => idSiklus == null || idSiklus!.isEmpty;

  const HarvestItem({
    required this.id,
    this.harvestCode = 'PN-202410-001',
    required this.title,
    required this.subtitle,
    required this.cropType,
    required this.status,
    this.idLahan = '',
    this.idSiklus,
    required this.location,
    required this.blockArea,
    required this.date,
    this.harvestTime = '09:00 WIB',
    required this.season,
    this.poktan = 'Poktan Sumber Makmur',
    required this.weightKg,
    required this.qualityGrade,
    required this.moistureOrNotes,
    this.moisturePercent = 13.8,
    this.wholeGrainPercent = 95.0,
    this.wastePercent = 2.0,
    this.harvestMethod = 'Mesin Combine Harvester',
    this.harvestCost = 1200000,
    this.costWorkers = '8 Orang Pekerja & Petani',
    this.pricePerKg = 7000,
    this.fieldNotes =
        'Kondisi cuaca cerah pagi hari. Gabah langsung dimuat dalam karung. Kualitas gabah bersih.',
    this.validatedBy = 'Pengurus Poktan',
    this.validatedAt = '',
    this.validatedNotes,
    this.photos = const [],
  });

  double get weightTon => weightKg / 1000.0;
  double get weightKuintal => weightKg / 100.0;
  double get estimatedValue => weightKg * pricePerKg;

  factory HarvestItem.fromJson(Map<String, dynamic> json) {
    final rawCrop = (json['komoditas_nama'] ?? json['crop_type'] ?? '').toString();
    final cropType = CropType.fromString(rawCrop);
    final status = HarvestStatus.fromString((json['status'] ?? '').toString());

    final weight = double.tryParse((json['berat_kg'] ?? '0').toString()) ?? 0.0;
    final price = double.tryParse((json['harga_per_kg'] ?? '0').toString()) ?? 0.0;
    final cost = double.tryParse((json['biaya_panen'] ?? '0').toString()) ?? 0.0;
    final moisture = double.tryParse((json['kadar_air'] ?? '14').toString()) ?? 14.0;
    final wholeGrain = double.tryParse((json['persen_butir_utuh'] ?? '95').toString()) ?? 95.0;
    final waste = double.tryParse((json['persen_hampa_kotoran'] ?? '2').toString()) ?? 2.0;

    // Gabungkan foto utama dan daftar foto agar semua bukti ikut terbaca.
    // Backend mengirim `foto_panen` (URL utama) dan `photos` (semua URL);
    // tanpa penggabungan, layar edit hanya melihat satu foto sehingga foto
    // lain tidak bisa dipertahankan atau dihapus satu per satu.
    final photoList = <String>[];
    final fotoUtama = (json['foto_panen'] ?? '').toString().trim();
    if (fotoUtama.isNotEmpty) {
      photoList.add(fotoUtama);
    }
    if (json['photos'] is List) {
      for (final foto in json['photos'] as List) {
        final url = foto?.toString().trim() ?? '';
        if (url.isNotEmpty && !photoList.contains(url)) {
          photoList.add(url);
        }
      }
    }

    final moistureNote = json['kadar_air'] != null
        ? 'Kadar Air ${json['kadar_air']}%'
        : (json['moistureOrNotes'] ?? 'Kadar Air 14%').toString();

    return HarvestItem(
      id: (json['id'] ?? json['id_panen'] ?? '').toString(),
      harvestCode: (json['kode_panen'] ?? json['harvestCode'] ?? 'PN-PANEN').toString(),
      title: (json['varietas'] ?? json['title'] ?? 'Padi').toString(),
      subtitle: (json['jenis_panen'] ?? json['subtitle'] ?? 'Gabah Kering Panen (GKP)').toString(),
      cropType: cropType,
      status: status,
      idLahan: (json['id_lahan'] ?? '').toString(),
      location: (json['nama_lahan'] ?? json['location'] ?? 'Petak Lahan').toString(),
      blockArea: (json['blok_luas'] ?? json['blockArea'] ?? '').toString(),
      date: (json['tanggal_panen_format'] ?? json['tanggal_panen'] ?? json['date'] ?? '').toString(),
      harvestTime: (json['waktu_panen'] ?? json['harvestTime'] ?? '09:00 WIB').toString(),
      season: (json['musim_tanam'] ?? json['season'] ?? 'Musim Rendeng').toString(),
      poktan: (json['poktan'] ?? 'Kelompok Tani').toString(),
      weightKg: weight,
      qualityGrade: (json['kualitas_grade'] ?? json['qualityGrade'] ?? 'Grade A').toString(),
      moistureOrNotes: moistureNote,
      moisturePercent: moisture,
      wholeGrainPercent: wholeGrain,
      wastePercent: waste,
      harvestMethod: (json['metode_panen'] ?? json['harvestMethod'] ?? 'Mesin Combine Harvester').toString(),
      harvestCost: cost,
      costWorkers: (json['keterangan_tenaga_kerja'] ?? json['costWorkers'] ?? '').toString(),
      pricePerKg: price,
      fieldNotes: (json['catatan'] ?? json['fieldNotes'] ?? '').toString(),
      validatedBy: (json['diverifikasi_oleh'] ?? json['validatedBy'] ?? '').toString(),
      validatedAt: (json['tanggal_verifikasi'] ?? json['validatedAt'] ?? '').toString(),
      validatedNotes: json['catatan_verifikasi']?.toString(),
      photos: photoList,
      idSiklus: (json['id_siklus'] ?? json['siklus_id'] ?? json['siklus']?['id_siklus'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_panen': id,
      'kode_panen': harvestCode,
      'id_lahan': idLahan,
      'id_siklus': idSiklus,
      'nama_lahan': location,
      'blok_luas': blockArea,
      'varietas': title,
      'jenis_panen': subtitle,
      'komoditas_nama': cropType.displayName,
      'status': status.name,
      'tanggal_panen': date,
      'waktu_panen': harvestTime,
      'musim_tanam': season,
      'poktan': poktan,
      'berat_kg': weightKg,
      'kualitas_grade': qualityGrade,
      'kadar_air': moisturePercent,
      'persen_butir_utuh': wholeGrainPercent,
      'persen_hampa_kotoran': wastePercent,
      'metode_panen': harvestMethod,
      'biaya_panen': harvestCost,
      'keterangan_tenaga_kerja': costWorkers,
      'harga_per_kg': pricePerKg,
      'catatan': fieldNotes,
      'photos': photos,
    };
  }

  HarvestItem copyWith({
    String? id,
    String? harvestCode,
    String? title,
    String? subtitle,
    CropType? cropType,
    HarvestStatus? status,
    String? idLahan,
    String? location,
    String? blockArea,
    String? date,
    String? harvestTime,
    String? season,
    String? poktan,
    double? weightKg,
    String? qualityGrade,
    String? moistureOrNotes,
    double? moisturePercent,
    double? wholeGrainPercent,
    double? wastePercent,
    String? harvestMethod,
    double? harvestCost,
    String? costWorkers,
    double? pricePerKg,
    String? fieldNotes,
    String? validatedBy,
    String? validatedAt,
    String? validatedNotes,
    List<String>? photos,
    String? idSiklus,
  }) {
    return HarvestItem(
      id: id ?? this.id,
      harvestCode: harvestCode ?? this.harvestCode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      cropType: cropType ?? this.cropType,
      status: status ?? this.status,
      idLahan: idLahan ?? this.idLahan,
      idSiklus: idSiklus ?? this.idSiklus,
      location: location ?? this.location,
      blockArea: blockArea ?? this.blockArea,
      date: date ?? this.date,
      harvestTime: harvestTime ?? this.harvestTime,
      season: season ?? this.season,
      poktan: poktan ?? this.poktan,
      weightKg: weightKg ?? this.weightKg,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      moistureOrNotes: moistureOrNotes ?? this.moistureOrNotes,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      wholeGrainPercent: wholeGrainPercent ?? this.wholeGrainPercent,
      wastePercent: wastePercent ?? this.wastePercent,
      harvestMethod: harvestMethod ?? this.harvestMethod,
      harvestCost: harvestCost ?? this.harvestCost,
      costWorkers: costWorkers ?? this.costWorkers,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      fieldNotes: fieldNotes ?? this.fieldNotes,
      validatedBy: validatedBy ?? this.validatedBy,
      validatedAt: validatedAt ?? this.validatedAt,
      validatedNotes: validatedNotes ?? this.validatedNotes,
      photos: photos ?? this.photos,
    );
  }
}
