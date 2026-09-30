import 'package:flutter/material.dart';

class FarmerBannerCard extends StatelessWidget {
  final VoidCallback? onTap;

  const FarmerBannerCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
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
          // 1. Background Image: Pemandangan Sawah dan Padi
          Positioned.fill(
            child: Image.asset(
              'assets/images/banner_sawah_padi.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),

          // 2. Soft Gradient Overlays for optimal readability
          // Gradient from left to right (subtle darkening over green mountain blur)
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

          // Subtle top-right vignette to guarantee crisp contrast on weather info
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x52000000), // ~32% black
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
                // Left Column: Leaf Icon, Headline, Subtitle
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Leaf Icon (clean white tilted leaf)
                      Transform.rotate(
                        angle: -0.35,
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Headline
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

                      // Subtitle
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

                // Right Column: Weather Info & "Lihat detail >" Button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Weather header: Sun behind Cloud + 28°C
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildWeatherSunCloudIcon(),
                        const SizedBox(width: 8),
                        const Text(
                          '28°C',
                          style: TextStyle(
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
                    const Text(
                      'Cerah Berawan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xF2FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Location pin & name
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 13,
                          color: Color(0xE6FFFFFF),
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Sukamaju',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xEBFFFFFF),
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
                              color: const Color(0xA6FFFFFF),
                              width: 1.1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Lihat detail',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: -0.1,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 15,
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

  /// Custom icon: Glowing Sun behind soft blue/white Cloud
  Widget _buildWeatherSunCloudIcon() {
    return SizedBox(
      width: 32,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sun in the background
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x66FBBF24),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFBBF24),
                size: 21,
              ),
            ),
          ),
          // Cloud in foreground
          const Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              Icons.cloud_rounded,
              color: Color(0xFFBAE6FD),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
