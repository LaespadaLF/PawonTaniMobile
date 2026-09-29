import 'package:flutter/material.dart';

class PartnershipCard extends StatelessWidget {
  final VoidCallback? onTap;

  const PartnershipCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF7F1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD6EADB),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Sprout Icon Container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFD8EFE0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.eco_rounded,
                color: Color(0xFF245738),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Middle Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kemitraan Paktani & Bulog',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF162A1D),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5E7567),
                        height: 1.35,
                      ),
                      children: [
                        TextSpan(text: 'Hasil panen yang '),
                        TextSpan(
                          text: 'terverifikasi otomatis',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E3325),
                          ),
                        ),
                        TextSpan(
                          text: ' masuk kuota lelang bersama mitra pupuk Pupuk Indonesia & Bulog.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Right Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF869E90),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
