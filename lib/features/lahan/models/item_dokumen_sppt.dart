class ItemDokumenSppt {
  final String id;
  final String namaFile;
  final String mimeType;
  final int ukuranBytes;
  final DateTime? diperbaruiPada;

  const ItemDokumenSppt({
    required this.id,
    required this.namaFile,
    required this.mimeType,
    required this.ukuranBytes,
    this.diperbaruiPada,
  });

  factory ItemDokumenSppt.fromJson(Map<String, dynamic> json) {
    return ItemDokumenSppt(
      id: (json['id'] ?? '').toString(),
      namaFile: (json['original_name'] ?? 'Dokumen SPPT').toString(),
      mimeType: (json['mime_type'] ?? '').toString(),
      ukuranBytes: int.tryParse(json['size_bytes']?.toString() ?? '0') ?? 0,
      diperbaruiPada: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
    );
  }
}
