import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';
import 'package:pawon_mobile/features/artikel/screens/layar_daftar_edukasi.dart';
import 'package:pawon_mobile/features/artikel/screens/layar_detail_artikel.dart';
import 'package:pawon_mobile/features/artikel/services/artikel_api_service.dart';

class HomeArticlesSection extends StatefulWidget {
  final VoidCallback? onAllTap;
  final ValueChanged<ArticleItem>? onArticleTap;

  const HomeArticlesSection({
    super.key,
    this.onAllTap,
    this.onArticleTap,
  });

  @override
  State<HomeArticlesSection> createState() => _HomeArticlesSectionState();
}

class _HomeArticlesSectionState extends State<HomeArticlesSection> {
  final ArtikelApiService _apiService = ArtikelApiService();
  List<ArticleItem> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final res = await _apiService.getEdukasiList(limit: 6);
      if (!mounted) return;
      if (res.success && res.data != null && res.data!.isNotEmpty) {
        setState(() {
          _articles = res.data!;
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _handleAllTap() {
    if (widget.onAllTap != null) {
      widget.onAllTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LayarDaftarEdukasi()),
      );
    }
  }

  void _handleArticleTap(ArticleItem item) {
    if (widget.onArticleTap != null) {
      widget.onArticleTap!(item);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LayarDetailArtikel(article: item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark ? Colors.white : WarnaAplikasi.primaryDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Informasi & Panduan Pertanian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: headerColor,
              ),
            ),
            InkWell(
              onTap: _handleAllTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat semua >',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primary,
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
          child: _isLoading
              ? _buildLoadingSkeleton()
              : _articles.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: _articles.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = _articles[index];
                        return _ArticleCard(
                          item: item,
                          onTap: () => _handleArticleTap(item),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, __) => Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WarnaAplikasi.borderField),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: WarnaAplikasi.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WarnaAplikasi.borderField),
      ),
      child: const Center(
        child: Text(
          'Belum ada informasi & panduan pertanian.',
          style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
        ),
      ),
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

    switch (item.category.toUpperCase()) {
      case 'TIPS':
        badgeBg = WarnaAplikasi.hppAmberBg;
        badgeTextColor = WarnaAplikasi.warningOrange;
        break;
      case 'ARTIKEL':
        badgeBg = WarnaAplikasi.bgSuccessLight;
        badgeTextColor = WarnaAplikasi.successGreen;
        break;
      case 'PANDUAN':
      default:
        badgeBg = WarnaAplikasi.statusBadgeBlueBg;
        badgeTextColor = WarnaAplikasi.statusBadgeBlueText;
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1D2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final subtitleColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textGray;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Banner
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _fallbackBanner(),
                      )
                    : _fallbackBanner(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryLabel ?? item.category,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Read Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: subtitleColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.readTime,
                        style: TextStyle(
                          fontSize: 11,
                          color: subtitleColor,
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
    );
  }

  Widget _fallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF285438), Color(0xFF1E3F2B)],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 22,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
