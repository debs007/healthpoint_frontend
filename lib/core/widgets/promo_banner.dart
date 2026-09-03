import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The light-mint promo card design, used on both Home and Categories.
/// Image is now always a remote URL (admin-uploaded via the backend,
/// R2-hosted) rather than a bundled local asset - Image.network, not
/// Image.asset. Text fields are all optional, matching the backend's
/// home_banners schema (an image-only banner is valid).
class PromoBanner extends StatelessWidget {
  const PromoBanner({
    super.key,
    required this.image,
    this.badgeText,
    this.headline,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.height = 160,
  });

  final String image;
  final String? badgeText;
  final String? headline;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasText = badgeText != null || headline != null || subtitle != null || buttonText != null;

    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(color: AppColors.surfaceTint),
            ),
          ),
          if (hasText)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(4)),
                      child: Text(badgeText!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  if (badgeText != null) const SizedBox(height: 8),
                  if (headline != null) Text(headline!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  if (headline != null) const SizedBox(height: 4),
                  if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  if (subtitle != null) const SizedBox(height: 14),
                  if (buttonText != null)
                    ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(140, 40)),
                      child: Text(buttonText!),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
