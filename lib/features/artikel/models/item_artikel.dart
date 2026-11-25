import 'package:pawon_mobile/core/constants/api_constants.dart';

class ArticleItem {
  final String id;
  final String title;
  final String category; // TIPS, ARTIKEL, PANDUAN
  final String? categoryLabel;
  final String readTime;
  final String? imageUrl;
  final String? summary;
  final String? content;
  final String? date;
  final String? commodityName;
  final String? target;

  const ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    this.categoryLabel,
    this.imageUrl,
    this.summary,
    this.content,
    this.date,
    this.commodityName,
    this.target,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    final rawCat = (json['category'] ?? json['type'] ?? 'ARTIKEL').toString().toUpperCase();
    final rawImg = (json['image_url'] ?? json['gambar'] ?? json['foto'])?.toString();
    final resolvedImg = ApiConstants.resolveImageUrl(rawImg);

    return ArticleItem(
      id: (json['id'] ?? json['id_artikel'] ?? json['id_tips'] ?? json['id_panduan'] ?? '').toString(),
      title: (json['title'] ?? json['judul'] ?? '').toString(),
      category: rawCat,
      categoryLabel: json['kategori_label']?.toString() ?? json['kategori']?.toString(),
      readTime: json['read_time']?.toString() ?? '5 menit baca',
      imageUrl: resolvedImg,
      summary: json['summary']?.toString() ?? json['ringkasan']?.toString(),
      content: json['content']?.toString() ?? json['isi']?.toString(),
      date: json['date']?.toString() ?? json['tanggal']?.toString(),
      commodityName: json['commodity_name']?.toString() ?? json['komoditas']?['nama_komoditas']?.toString(),
      target: json['target']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'kategori_label': categoryLabel,
      'read_time': readTime,
      'image_url': imageUrl,
      'summary': summary,
      'content': content,
      'date': date,
      'commodity_name': commodityName,
      'target': target,
    };
  }
}
