import 'package:pawon_mobile/core/constants/api_constants.dart';

enum ActivityCategory {
  pemupukan,
  penyiraman,
  pengairan,
  penyemprotan,
  penyiangan,
  pemangkasan;

  String get label {
    switch (this) {
      case ActivityCategory.pemupukan:
        return 'Pemupukan';
      case ActivityCategory.penyiraman:
        return 'Penyiraman';
      case ActivityCategory.pengairan:
        return 'Pengairan';
      case ActivityCategory.penyemprotan:
        return 'Penyemprotan';
      case ActivityCategory.penyiangan:
        return 'Penyiangan';
      case ActivityCategory.pemangkasan:
        return 'Pemangkasan';
    }
  }

  static ActivityCategory fromString(String? val) {
    if (val == null) return ActivityCategory.pemupukan;
    final lower = val.toLowerCase().trim();
    for (final cat in ActivityCategory.values) {
      if (cat.name.toLowerCase() == lower || cat.label.toLowerCase() == lower) {
        return cat;
      }
    }
    return ActivityCategory.pemupukan;
  }
}

enum PlantCondition {
  sehat,
  perluPerhatian,
  terserangHama;

  String get label {
    switch (this) {
      case PlantCondition.sehat:
        return 'Sehat';
      case PlantCondition.perluPerhatian:
        return 'Perlu Perhatian';
      case PlantCondition.terserangHama:
        return 'Terserang Hama/Penyakit';
    }
  }

  String get badgeText {
    switch (this) {
      case PlantCondition.sehat:
        return '✔ Sehat';
      case PlantCondition.perluPerhatian:
        return '▲ Perlu Perhatian';
      case PlantCondition.terserangHama:
        return '⚠ Hama/Penyakit';
    }
  }

  static PlantCondition fromString(String? val) {
    if (val == null) return PlantCondition.sehat;
    final lower = val.toLowerCase().trim();
    if (lower.contains('perhatian') || lower.contains('perlu')) {
      return PlantCondition.perluPerhatian;
    }
    if (lower.contains('hama') || lower.contains('penyakit')) {
      return PlantCondition.terserangHama;
    }
    return PlantCondition.sehat;
  }
}

class PlantActivityItem {
  final String id;
  final String title;
  final String cropName;
  final ActivityCategory category;
  final PlantCondition condition;
  final String date;
  final String time;
  final String location;
  final String blockArea;
  final String notes;
  final String? imageUrl;
  final int? dayNumber;
  final String? lahanId;
  final double? biaya;

  const PlantActivityItem({
    required this.id,
    required this.title,
    required this.cropName,
    required this.category,
    required this.condition,
    required this.date,
    required this.time,
    required this.location,
    required this.blockArea,
    required this.notes,
    this.imageUrl,
    this.dayNumber,
    this.lahanId,
    this.biaya,
  });

  factory PlantActivityItem.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] ?? json['kategori'])?.toString();
    final category = ActivityCategory.fromString(catStr);

    final condStr = (json['condition'] ?? json['kondisi_tanaman'])?.toString();
    final condition = PlantCondition.fromString(condStr);

    final id = (json['id'] ?? json['id_aktivitas'] ?? '').toString();
    final title = (json['title'] ?? json['judul'] ?? category.label).toString();
    final cropName = (json['crop_name'] ?? json['cropName'] ?? '').toString();
    final date = (json['date'] ?? json['tanggal'] ?? '').toString();
    final time = (json['time'] ?? json['waktu'] ?? '').toString();
    final location = (json['location'] ?? json['nama_lahan'] ?? '').toString();
    final blockArea = (json['block_area'] ?? json['blockArea'] ?? '').toString();
    final notes = (json['notes'] ?? json['catatan'] ?? '').toString();
    final rawImg = (json['image_url'] ?? json['imageUrl'] ?? json['foto_aktivitas'])?.toString();
    final imageUrl = rawImg != null && rawImg.isNotEmpty ? ApiConstants.resolveImageUrl(rawImg) : null;
    final dayNumber = int.tryParse((json['day_number'] ?? json['dayNumber'] ?? json['hari_setelah_tanam'])?.toString() ?? '');
    final lahanId = (json['id_lahan'] ?? json['lahan_id'])?.toString();
    final biaya = double.tryParse((json['biaya'])?.toString() ?? '');

    return PlantActivityItem(
      id: id,
      title: title,
      cropName: cropName,
      category: category,
      condition: condition,
      date: date,
      time: time,
      location: location,
      blockArea: blockArea,
      notes: notes,
      imageUrl: imageUrl,
      dayNumber: dayNumber,
      lahanId: lahanId,
      biaya: biaya,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_aktivitas': id,
      'id_lahan': lahanId,
      'kategori': category.name,
      'judul': title,
      'kondisi_tanaman': condition.name,
      'tanggal': date,
      'waktu': time,
      'hari_setelah_tanam': dayNumber,
      'catatan': notes,
      'foto_aktivitas': imageUrl,
      'biaya': biaya,
    };
  }

  PlantActivityItem copyWith({
    String? id,
    String? title,
    String? cropName,
    ActivityCategory? category,
    PlantCondition? condition,
    String? date,
    String? time,
    String? location,
    String? blockArea,
    String? notes,
    String? imageUrl,
    int? dayNumber,
    String? lahanId,
    double? biaya,
  }) {
    return PlantActivityItem(
      id: id ?? this.id,
      title: title ?? this.title,
      cropName: cropName ?? this.cropName,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      blockArea: blockArea ?? this.blockArea,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      dayNumber: dayNumber ?? this.dayNumber,
      lahanId: lahanId ?? this.lahanId,
      biaya: biaya ?? this.biaya,
    );
  }
}
