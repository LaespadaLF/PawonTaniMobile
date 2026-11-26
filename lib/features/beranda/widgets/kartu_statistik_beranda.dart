import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/beranda/models/beranda_ringkasan_model.dart';

class HomeFarmSummarySection extends StatelessWidget {
  final VoidCallback? onDetailTap;
  final VoidCallback? onLahanTap;
  final VoidCallback? onKomoditasTap;
  final VoidCallback? onPanenTap;
  final VoidCallback? onPenjualanTap;
  final VoidCallback? onKondisiTap;
  final BerandaStatistikModel? statistik;

  const HomeFarmSummarySection({
    super.key,
    this.onDetailTap,
    this.onLahanTap,
    this.onKomoditasTap,
    this.onPanenTap,
    this.onPenjualanTap,
    this.onKondisiTap,
    this.statistik,
  });

  @override
  Widget build(BuildContext context) {
    final lahanAktifVal = statistik != null ? '${statistik!.lahanAktif}' : '0';
    final totalLahanVal = statistik != null ? '${statistik!.totalLahan}' : '0';
    final totalKomoditasVal = statistik != null ? '${statistik!.totalKomoditas}' : '0';
    final komoditasSub = (statistik != null && statistik!.komoditasList.isNotEmpty)
        ? statistik!.komoditasList.join(', ')
        : 'Belum ada data';
    final luasSub = statistik != null && statistik!.totalLuasHa > 0
        ? 'Total ${statistik!.totalLuasHa.toStringAsFixed(1)} Ha'
        : 'dari $totalLahanVal total lahan';
    final aktivitasVal = statistik != null ? '${statistik!.totalAktivitas}' : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Ringkasan Pertanian',
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
              onTap: onDetailTap,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Lihat detail >',
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

        // 2x2 Grid of Stat Cards
        Row(
          children: [
            // Card 1: Lahan Aktif
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.yard_outlined,
                  color: WarnaAplikasi.primary,
                  size: 19,
                ),
                value: lahanAktifVal,
                title: 'Lahan Aktif',
                subtitle: luasSub,
                onTap: onLahanTap,
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Komoditas
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.eco_outlined,
                  color: WarnaAplikasi.primary,
                  size: 19,
                ),
                value: totalKomoditasVal,
                title: 'Komoditas',
                subtitle: komoditasSub,
                onTap: onKomoditasTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 3: Total Lahan Terdaftar
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.landscape_outlined,
                  color: WarnaAplikasi.primary,
                  size: 19,
                ),
                value: totalLahanVal,
                title: 'Total Petak Lahan',
                subtitle: '${statistik?.lahanIstirahat ?? 0} Istirahat · ${statistik?.lahanPersiapan ?? 0} Olah',
                onTap: onLahanTap,
              ),
            ),
            const SizedBox(width: 12),
            // Card 4: Catatan Aktivitas
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.assignment_outlined,
                  color: WarnaAplikasi.primary,
                  size: 19,
                ),
                value: aktivitasVal,
                title: 'Aktivitas Tanam',
                subtitle: 'Tercatat di sistem',
                onTap: onPenjualanTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Full-width Card: Kondisi Pertanian
        _ConditionCard(onTap: onKondisiTap),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Widget iconWidget;
  final String value;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.iconWidget,
    required this.value,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 128),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: WarnaAplikasi.borderPale,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: WarnaAplikasi.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: iconWidget),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: WarnaAplikasi.textGrayLight,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: WarnaAplikasi.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: WarnaAplikasi.primaryDark,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: WarnaAplikasi.textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _ConditionCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: WarnaAplikasi.greenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: WarnaAplikasi.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: WarnaAplikasi.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kondisi Pertanian Baik',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WarnaAplikasi.primaryDark,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Semua lahan terpantau normal dan aktif.',
                  style: TextStyle(
                    fontSize: 11,
                    color: WarnaAplikasi.textGray,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.info_outline_rounded, size: 18, color: WarnaAplikasi.primary),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }
}
