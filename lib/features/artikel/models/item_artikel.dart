class ArticleItem {
  final String id;
  final String title;
  final String category; // TIPS, ARTIKEL, PANDUAN
  final String readTime;
  final String imageUrl;
  final String? summary;

  const ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.imageUrl,
    this.summary,
  });
}
