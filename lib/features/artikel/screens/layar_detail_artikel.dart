import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';

class LayarDetailArtikel extends StatelessWidget {
  final ArticleItem article;

  const LayarDetailArtikel({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? const Color(0xFFF1F5F2) : WarnaAplikasi.primaryDark;
    final bodyTextColor = isDark ? const Color(0xFFE2E9E4) : const Color(0xFF2D3748);
    final leadBg = isDark ? const Color(0xFF1D2420) : WarnaAplikasi.bgPaleGreen3;
    final leadBorder = isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderPale2;
    final leadTextColor = isDark ? const Color(0xFFA0B3A6) : WarnaAplikasi.textDarkGreen;

    Color badgeBg;
    Color badgeTextColor;

    switch (article.category.toUpperCase()) {
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

    return Scaffold(
      backgroundColor: WarnaAplikasi.getBackgroundColor(context),
      appBar: PawonFormHeader(
        title: 'Detail Edukasi',
        subtitle: 'Baca panduan & artikel pertanian',
        onBack: () => Navigator.pop(context),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama (Hero Cover)
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Image.network(
                article.imageUrl!,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackBanner(),
              )
            else
              _buildFallbackBanner(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta bar: Badge + Read Time + Date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          article.categoryLabel ?? article.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.access_time_rounded, size: 14, color: WarnaAplikasi.textGray),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                      ),
                      if (article.date != null && article.date!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Text('•', style: TextStyle(color: WarnaAplikasi.textGrayLight)),
                        const SizedBox(width: 10),
                        Text(
                          article.date!,
                          style: const TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Judul
                  Text(
                    article.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: titleColor,
                      height: 1.3,
                    ),
                  ),

                  // Komoditas Tag (jika ada)
                  if (article.commodityName != null && article.commodityName!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.eco_outlined, size: 16, color: WarnaAplikasi.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Komoditas: ${article.commodityName}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF81C784) : WarnaAplikasi.primary,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  Divider(color: isDark ? const Color(0xFF28332C) : WarnaAplikasi.borderField),
                  const SizedBox(height: 14),

                  // Ringkasan (Lead) jika ada
                  if (article.summary != null && article.summary!.trim().isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: leadBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: leadBorder),
                      ),
                      child: Text(
                        article.summary!,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: leadTextColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Isi Konten Lengkap
                  Text(
                    _formatContent(article.content ?? article.summary ?? 'Belum ada konten detail untuk artikel ini.'),
                    style: TextStyle(
                      fontSize: 14.5,
                      color: bodyTextColor,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF285438), Color(0xFF1E3F2B)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              article.category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatContent(String raw) {
    // Bersihkan tag HTML sederhana jika konten berasal dari WYSIWYG
    var cleaned = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), '');
    return cleaned.trim();
  }
}
