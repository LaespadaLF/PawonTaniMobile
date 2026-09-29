enum HarvestStatus {
  menunggu,
  disetujui,
  ditolak,
}

enum CropType {
  padi,
  jagung,
}

class HarvestItem {
  final String id;
  final String harvestCode;
  final String title;
  final String subtitle;
  final CropType cropType;
  final HarvestStatus status;
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
  final List<String> photos;

  const HarvestItem({
    required this.id,
    this.harvestCode = 'PN-202410-001',
    required this.title,
    required this.subtitle,
    required this.cropType,
    required this.status,
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
        'Kondisi cuaca cerah pagi hari. Gabah langsung dimuat dalam 97 karung gonikuring. Penimbangan disaksikan langsung oleh Poktan Sumber Makmur. Kualitas gabah bersih.',
    this.validatedBy = 'Masduki (Ketua Poktan Sumber Makmur)',
    this.validatedAt = '19 Nov 2024 13:54',
    this.photos = const [
      'https://images.unsplash.com/photo-1586771107445-d3ca888129ff?w=600&q=80',
      'https://images.unsplash.com/photo-1595246140625-573b715d11dc?w=600&q=80',
    ],
  });

  double get weightTon => weightKg / 1000.0;
  double get weightKuintal => weightKg / 100.0;
  double get estimatedValue => weightKg * pricePerKg;

  HarvestItem copyWith({
    String? id,
    String? harvestCode,
    String? title,
    String? subtitle,
    CropType? cropType,
    HarvestStatus? status,
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
    List<String>? photos,
  }) {
    return HarvestItem(
      id: id ?? this.id,
      harvestCode: harvestCode ?? this.harvestCode,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      cropType: cropType ?? this.cropType,
      status: status ?? this.status,
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
      photos: photos ?? this.photos,
    );
  }
}
