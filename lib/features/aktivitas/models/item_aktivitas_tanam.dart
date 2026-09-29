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
  });

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
    );
  }
}
