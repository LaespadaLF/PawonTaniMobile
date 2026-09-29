import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showProfile;
  final bool isBackButton;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showProfile = false,
    this.isBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isBackButton)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 28),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  child: const Icon(LucideIcons.leaf, color: AppColors.white, size: 24),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBackButton ? title : 'PawonTani',
                    style: AppTextStyles.cardTitle,
                  ),
                  if (subtitle != null && !isBackButton)
                    Text(
                      subtitle!,
                      style: AppTextStyles.secondary,
                    ),
                ],
              ),
            ],
          ),
          if (showProfile)
            Row(
              children: [
                Stack(
                  children: [
                    const Icon(LucideIcons.bell, color: AppColors.textPrimary, size: 28),
                    Positioned(
                      top: 0,
                      right: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.background, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Icon(LucideIcons.user, color: AppColors.white, size: 20),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
