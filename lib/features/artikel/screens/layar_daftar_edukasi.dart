import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/artikel/models/item_artikel.dart';
import 'package:pawon_mobile/features/artikel/screens/layar_detail_artikel.dart';
import 'package:pawon_mobile/features/artikel/services/artikel_api_service.dart';

class LayarDaftarEdukasi extends StatefulWidget {
  const LayarDaftarEdukasi({super.key});

  @override
  State<LayarDaftarEdukasi> createState() => _LayarDaftarEdukasiState();
}

class _LayarDaftarEdukasiState extends State<LayarDaftarEdukasi> {
  final ArtikelApiService _apiService = ArtikelApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ArticleItem> _allItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'semua';

  final List<Map<String, String>> _categories = const [
    {'key': 'semua', 'label': 'Semua'},
    {'key': 'artikel', 'label': 'Artikel'},
    {'key': 'tips', 'label': 'Tips'},
    {'key': 'panduan', 'label': 'Panduan'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchEdukasi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEdukasi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _apiService.getEdukasiList(
        kategori: _selectedCategory,
        query: _searchController.text.trim(),
      );

      if (!mounted) return;

      if (res.success && res.data != null) {
        setState(() {
          _allItems = res.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.message.isNotEmpty ? res.message : 'Gagal memuat konten edukasi.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.primaryBackground,
      appBar: PawonFormHeader(
        title: 'Edukasi Pertanian',
        subtitle: 'Tips, panduan & artikel dari penyuluh pertanian',
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Field
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.bgPage,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WarnaAplikasi.borderField),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchEdukasi(),
                    decoration: InputDecoration(
                      hintText: 'Cari tips, panduan, atau artikel...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: WarnaAplikasi.textGray),
                      prefixIcon: const Icon(Icons.search, size: 20, color: WarnaAplikasi.textGray),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _fetchEdukasi();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat['label']!),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val && _selectedCategory != cat['key']) {
                              setState(() => _selectedCategory = cat['key']!);
                              _fetchEdukasi();
                            }
                          },
                          selectedColor: WarnaAplikasi.primary,
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : WarnaAplikasi.textDarkGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? WarnaAplikasi.primary : WarnaAplikasi.borderField,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.primary))
                : _errorMessage != null
                    ? _buildErrorView()
                    : _allItems.isEmpty
                        ? _buildEmptyView()
                        : RefreshIndicator(
                            onRefresh: _fetchEdukasi,
                            color: WarnaAplikasi.primary,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: _allItems.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _allItems[index];
                                return _buildArticleCard(item);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(ArticleItem item) {
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LayarDetailArtikel(article: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: WarnaAplikasi.borderField),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.categoryLabel ?? item.category,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.readTime,
                        style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                      ),
                      if (item.date != null && item.date!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: WarnaAplikasi.textGrayLight)),
                        const SizedBox(width: 8),
                        Text(
                          item.date!,
                          style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textGray),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: WarnaAplikasi.primaryDark,
                      height: 1.3,
                    ),
                  ),
                  if (item.summary != null && item.summary!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.summary!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: WarnaAplikasi.textGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48, color: WarnaAplikasi.textGrayLight),
            const SizedBox(height: 12),
            const Text(
              'Belum Ada Konten Edukasi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: WarnaAplikasi.primaryDark),
            ),
            const SizedBox(height: 6),
            const Text(
              'Konten edukasi akan muncul di sini setelah dipublikasikan oleh penyuluh.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: WarnaAplikasi.textGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: WarnaAplikasi.errorRedDark),
            const SizedBox(height: 12),
            Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: WarnaAplikasi.errorRedDark)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchEdukasi,
              style: ElevatedButton.styleFrom(backgroundColor: WarnaAplikasi.primary),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
