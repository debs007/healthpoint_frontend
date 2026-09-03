import 'package:flutter/material.dart';

/// Every color in the app lives here. The four brand shades were
/// re-sampled directly from the actual Susthayan logo asset file
/// (assets/images/logo_mark.png) - more authoritative than the earlier
/// screenshot-based extraction, since this is the real source file rather
/// than a photo of it on a phone screen. Status/neutral colors are
/// reasonable, standard choices not sampled from the designs - adjust
/// these specifically if the real spec differs.
class AppColors {
  AppColors._();

  // --- Brand palette (sampled directly from logo_mark.png) ---
  /// Deepest green - used sparingly, for the darkest accents/icons.
  static const Color primaryDark = Color(0xFF0A4A38);

  /// The main brand green - primary buttons, active nav items, links.
  static const Color primary = Color(0xFF208060);

  /// Brighter accent green - secondary actions, selected/active states.
  static const Color accent = Color(0xFF60A890);

  /// Light mint - card backgrounds, section tints, banner backgrounds.
  static const Color surfaceTint = Color(0xFFD0E8E0);

  /// A slightly deeper mint, seen behind icon badges/quick-action tiles.
  static const Color surfaceTintDeep = Color(0xFFA8D0C8);

  // --- Neutrals (standard choices - confirm against exact designs if available) ---
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F0F0);

  // --- Status colors (order tracking, badges) ---
  static const Color statusDelivered = Color(0xFF16A34A);
  static const Color statusProcessing = Color(0xFFF59E0B);
  static const Color statusShipped = Color(0xFF2563EB);
  static const Color statusPending = Color(0xFF9CA3AF);
  static const Color statusCancelled = Color(0xFFDC2626);

  // --- Semantic ---
  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color badgeRed = Color(0xFFEF4444);

  /// Maps a backend order-status string directly to its badge color, so
  /// every screen that shows a status pill stays visually consistent
  /// without each one re-implementing the same switch statement.
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'picked_up':
        return statusDelivered;
      case 'preparing':
      case 'confirmed':
      case 'ready_for_dispatch':
        return statusProcessing;
      case 'out_for_delivery':
        return statusShipped;
      case 'cancelled':
      case 'refunded':
        return statusCancelled;
      default:
        return statusPending;
    }
  }
}
