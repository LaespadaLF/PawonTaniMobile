import 'package:flutter/material.dart';
import '../models/article_item.dart';

class HomeArticlesSection extends StatelessWidget {
  final VoidCallback? onAllTap;
  final ValueChanged<ArticleItem>? onArticleTap;

  const HomeArticlesSection({
    super.key,
    this.onAllTap,
    this.onArticleTap,
  });

  static const List<ArticleItem> _articles = [
    ArticleItem(
      id: '1',
      title: 'Cara Mengatasi Hama pada Tanaman Padi',
      category: 'TIPS',
      readTime: '5 menit baca',
      imageUrl: 'https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?w=600&auto=format&fit=crop&q=80',
      summary: 'Langkah efektif mengidentifikasi wereng batang coklat dan penggerek batang padi, serta penggunaan musuh alami dan pestisida nabati secara ramah lingkungan.',
    ),
    ArticleItem(
      id: '2',
      title: 'Pemupukan Berimbang Pada Tanaman Padi',
      category: 'ARTIKEL',
      readTime: '7 menit baca',
      imageUrl: 'https://images.unsplash.com/photo-1592417817098-8f3d6910a711?w=600&auto=format&fit=crop&q=80',
      summary: 'Panduan takaran NPK, Urea, dan pupuk organik sesuai fase vegetatif dan generatif untuk memaksimalkan bobot bulir gabah dan efisiensi biaya.',
    ),
    ArticleItem(
      id: '3',
      title: 'Manajemen Irigasi Hemat Air Musim Kemarau',
      category: 'PANDUAN',
      readTime: '4 menit baca',
      imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=600&auto=format&fit=crop&q=80',
      summary: 'Teknik pengairan basah-kering berselang (AWD) yang terbukti menghemat kebutuhan air hingga 25% tanpa mengurangi produktivitas panen.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Informasi & Panduan Pertanian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF162A1D),
              ),
            ),
            InkWell(
              onTap: onAllTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat semua >',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF285438),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal List of Articles
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _articles.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = _articles[index];
              return _ArticleCard(
                item: item,
                onTap: () => onArticleTap?.call(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleItem item;
  final VoidCallback? onTap;

  const _ArticleCard({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeBg;
    Color badgeTextColor;

    switch (item.category) {
      case 'TIPS':
        badgeBg = const Color(0xFFFFF3E0);
        badgeTextColor = const Color(0xFFD97706);
        break;
      case 'ARTIKEL':
        badgeBg = const Color(0xFFDCFCE7);
        badgeTextColor = const Color(0xFF16A34A);
        break;
      default:
        badgeBg = const Color(0xFFE0F2FE);
        badgeTextColor = const Color(0xFF0284C7);
    }

    return Container(
      width: 215,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8EFEA),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Header Image
              SizedBox(
                height: 104,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: item.category == 'TIPS'
                                  ? [const Color(0xFFC7B168), const Color(0xFF8C9B47)]
                                  : [const Color(0xFF1E3A8A), const Color(0xFF047857)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item.category == 'TIPS'
                                  ? Icons.bug_report_outlined
                                  : Icons.eco_rounded,
                              color: const Color(0xD9FFFFFF),
                              size: 36,
                            ),
                          ),
                        );
                      },
                    ),
                    // Subtle dark gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0x26000000),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Article Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeTextColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF162A1D),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Read Time
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Color(0xFF718679),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.readTime,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF718679),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
