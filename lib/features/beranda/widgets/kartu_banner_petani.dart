import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/beranda/models/beranda_ringkasan_model.dart';

class FarmerBannerCard extends StatelessWidget {
  final VoidCallback? onTap;
  final BerandaCuacaModel? cuaca;

  const FarmerBannerCard({
    super.key,
    this.onTap,
    this.cuaca,
  });

  @override
  Widget build(BuildContext context) {
    final suhuText = cuaca != null ? '${cuaca!.suhu}°C' : '28°C';
    final kondisiText = cuaca?.kondisi ?? 'Cerah Berawan';
    final lokasiText = cuaca?.lokasi ?? 'Jember';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 155),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1E3A2B),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/banner_sawah_padi.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A2B), Color(0xFF2E5A1C), Color(0xFF4D9830)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Soft Gradient Overlays for optimal readability
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x73000000), // ~45% black
                    Color(0x33000000), // ~20% black
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.58, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x52000000),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.60],
                  begin: Alignment.topRight,
                  end: Alignment.center,
                ),
              ),
            ),
          ),

          // 3. Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: Headline & Subtitle
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: -0.35,
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Semangat bertani,\nhasil terbaik menanti!',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.22,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        'Pantau pertanianmu dengan lebih mudah.',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                          color: Color(0xEBFFFFFF),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right Column: Live Weather Info & Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weather header: Icon + Temp
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildWeatherIcon(cuaca?.kodeCuaca ?? 2),
                        const SizedBox(width: 8),
                        Text(
                          suhuText,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Weather condition
                    Text(
                      kondisiText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xF2FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Location pin & name
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: Color(0xE6FFFFFF),
                        ),
                        const SizedBox(width: 2),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 110),
                          child: Text(
                            lokasiText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: Color(0xEBFFFFFF),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action Button: "Lihat detail >"
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(20),
                        splashColor: const Color(0x33FFFFFF),
                        highlightColor: const Color(0x1AFFFFFF),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x22FFFFFF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0x40FFFFFF),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat detail',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(int code) {
    IconData icon;
    Color color = Colors.amber;

    if (code == 0 || code == 1) {
      icon = Icons.wb_sunny_rounded;
      color = Colors.amber;
    } else if (code == 2 || code == 3) {
      icon = Icons.wb_cloudy_rounded;
      color = Colors.white;
    } else if (code >= 51 && code <= 82) {
      icon = Icons.grain_rounded;
      color = Colors.lightBlueAccent;
    } else if (code >= 95) {
      icon = Icons.thunderstorm_rounded;
      color = Colors.purpleAccent;
    } else {
      icon = Icons.cloud_outlined;
      color = Colors.white70;
    }

    return Icon(icon, color: color, size: 24);
  }
}
