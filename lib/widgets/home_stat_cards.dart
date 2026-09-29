import 'package:flutter/material.dart';

class HomeFarmSummarySection extends StatelessWidget {
  final VoidCallback? onDetailTap;
  final VoidCallback? onLahanTap;
  final VoidCallback? onKomoditasTap;
  final VoidCallback? onPanenTap;
  final VoidCallback? onPenjualanTap;
  final VoidCallback? onKondisiTap;

  const HomeFarmSummarySection({
    super.key,
    this.onDetailTap,
    this.onLahanTap,
    this.onKomoditasTap,
    this.onPanenTap,
    this.onPenjualanTap,
    this.onKondisiTap,
  });

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
              'Ringkasan Pertanian',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF162A1D),
              ),
            ),
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
                    color: Color(0xFF285438),
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
                  color: Color(0xFF285438),
                  size: 19,
                ),
                value: '3',
                title: 'Lahan Aktif',
                subtitle: 'dari 4 total lahan',
                onTap: onLahanTap,
              ),
            ),
            const SizedBox(width: 12),
            // Card 2: Komoditas
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.eco_outlined,
                  color: Color(0xFF285438),
                  size: 19,
                ),
                value: '2',
                title: 'Komoditas',
                subtitle: 'Cabai, Padi',
                onTap: onKomoditasTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Card 3: Total Panen
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.agriculture_rounded,
                  color: Color(0xFF285438),
                  size: 19,
                ),
                value: '4,2 Ton',
                title: 'Total Panen',
                subtitle: null,
                onTap: onPanenTap,
              ),
            ),
            const SizedBox(width: 12),
            // Card 4: Total Penjualan
            Expanded(
              child: _StatCard(
                iconWidget: const Icon(
                  Icons.credit_card_outlined,
                  color: Color(0xFF285438),
                  size: 19,
                ),
                value: 'Rp28,5 jt',
                title: 'Total Penjualan',
                subtitle: null,
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
          color: const Color(0xFFE8EFEA),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Container and Chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F4EC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: iconWidget),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFFB0C2B5),
                    ),
                  ],
                ),

                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF162A1D),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF162A1D),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF718679),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Green Icon circle
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: Color(0xFF285438),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Text & Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Kondisi Pertanian',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF162A1D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F6EA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Aman',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF285438),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: const [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Color(0xFF718679),
                          ),
                          SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              'Pemupukan terakhir 2 jam yang lalu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF718679),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFFB0C2B5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
