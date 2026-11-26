import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/constants/api_constants.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/panen/models/item_panen.dart';

class HomeLatestHarvestSection extends StatelessWidget {
  final HarvestItem? item;
  final bool isLoading;
  final VoidCallback? onAllTap;
  final ValueChanged<HarvestItem>? onItemTap;
  final VoidCallback? onAddTap;

  const HomeLatestHarvestSection({
    super.key,
    this.item,
    this.isLoading = false,
    this.onAllTap,
    this.onItemTap,
    this.onAddTap,
  });

  String _formatWeight(double kg, double ton) {
    if (kg >= 1000) {
      final tonStr = ton.toStringAsFixed(2);
      return tonStr.endsWith('.00')
          ? '${ton.toInt()} Ton'
          : '${tonStr.replaceAll('.', ',')} Ton';
    }
    return '${kg.toInt()} kg';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Hasil Panen Terbaru',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: WarnaAplikasi.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                    color: WarnaAplikasi.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Body Content: Loading, Empty, or Actual Harvest Card
        if (isLoading)
          _buildLoadingSkeleton()
        else if (item != null)
          _buildHarvestCard(context, item!)
        else
          _buildEmptyState(context),
      ],
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.borderPale, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: WarnaAplikasi.borderPale.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.borderPale.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: WarnaAplikasi.borderPale.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHarvestCard(BuildContext context, HarvestItem harvest) {
    Color statusBg;
    Color statusColor;
    String statusLabel;

    switch (harvest.status) {
      case HarvestStatus.disetujui:
        statusBg = WarnaAplikasi.greenLight;
        statusColor = WarnaAplikasi.primary;
        statusLabel = 'Disetujui';
        break;
      case HarvestStatus.ditolak:
        statusBg = WarnaAplikasi.errorRedBg;
        statusColor = WarnaAplikasi.errorRedDark;
        statusLabel = 'Ditolak';
        break;
      case HarvestStatus.menunggu:
        statusBg = WarnaAplikasi.hppAmberBg;
        statusColor = const Color(0xFFC05621);
        statusLabel = 'Menunggu';
        break;
    }

    final hasPhoto = harvest.photos.isNotEmpty;
    final photoUrl = hasPhoto ? ApiConstants.resolveImageUrl(harvest.photos.first) : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: WarnaAplikasi.borderPale,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onItemTap?.call(harvest),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Thumbnail Gambar Panen atau Ikon Komoditas
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 58,
                    height: 58,
                    color: WarnaAplikasi.greenLight,
                    child: photoUrl != null
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildCropFallbackIcon(harvest.cropType);
                            },
                          )
                        : _buildCropFallbackIcon(harvest.cropType),
                  ),
                ),
                const SizedBox(width: 14),

                // Informasi Panen
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              harvest.title.isNotEmpty
                                  ? harvest.title
                                  : harvest.cropType.displayName,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: WarnaAplikasi.primaryDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${harvest.cropType.displayName} • ${harvest.location}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: WarnaAplikasi.textGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _formatWeight(harvest.weightKg, harvest.weightTon),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: WarnaAplikasi.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            harvest.date.isNotEmpty ? harvest.date : harvest.season,
                            style: const TextStyle(
                              fontSize: 11,
                              color: WarnaAplikasi.textGrayGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron Right
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: WarnaAplikasi.textGrayGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.borderPale),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WarnaAplikasi.greenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: WarnaAplikasi.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Belum Ada Panen Baru',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Catat panen untuk pantau hasil & tonase',
                  style: TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAddTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: WarnaAplikasi.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Catat',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropFallbackIcon(CropType cropType) {
    if (cropType == CropType.jagung) {
      return Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: WarnaAplikasi.hppAmberBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.grain_rounded,
            color: Color(0xFFD97706),
            size: 20,
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFE2F4E7),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.eco_rounded,
          color: WarnaAplikasi.primary,
          size: 20,
        ),
      ),
    );
  }
}
