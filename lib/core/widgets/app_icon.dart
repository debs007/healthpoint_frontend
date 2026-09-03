import 'package:flutter/material.dart';
import '../constants/app_icons.dart';
import '../constants/app_images.dart';

/// Renders an icon by its AppIcons asset path. Checks AppImages.homeIcons
/// first for a real provided asset; only falls back to the Material icon
/// in _fallbackMap when no real asset exists yet for that key. This is
/// the single place that distinction lives - screens just call
/// AppIcon(AppIcons.x) and never need to know which case applies.
class AppIcon extends StatelessWidget {
  const AppIcon(this.assetPath, {super.key, this.size = 24, this.color});

  final String assetPath;
  final double size;
  final Color? color;

  static final Map<String, IconData> _fallbackMap = {
    AppIcons.navHome: Icons.home_rounded,
    AppIcons.navCategories: Icons.grid_view_rounded,
    AppIcons.navOrders: Icons.inventory_2_outlined,
    AppIcons.navHealthRecords: Icons.favorite_rounded,
    AppIcons.navAccount: Icons.person_outline_rounded,

    AppIcons.location: Icons.location_on_outlined,
    AppIcons.search: Icons.search_rounded,
    AppIcons.scan: Icons.qr_code_scanner_rounded,
    AppIcons.notification: Icons.notifications_none_rounded,
    AppIcons.cart: Icons.shopping_cart_outlined,
    AppIcons.settings: Icons.settings_outlined,
    AppIcons.camera: Icons.camera_alt_outlined,
    AppIcons.chevronRight: Icons.chevron_right_rounded,
    AppIcons.copy: Icons.copy_outlined,
    AppIcons.upload: Icons.upload_outlined,
    AppIcons.lock: Icons.lock_outline_rounded,
    AppIcons.phone: Icons.phone_outlined,
    AppIcons.email: Icons.mail_outline_rounded,

    AppIcons.categoryMedicines: Icons.medication_outlined,
    AppIcons.categoryHealthcare: Icons.eco_outlined,
    AppIcons.categoryLabTests: Icons.add_box_outlined,
    AppIcons.categoryMotherBaby: Icons.child_care_outlined,
    AppIcons.categoryFitness: Icons.fitness_center_outlined,
    AppIcons.categoryViewAll: Icons.more_horiz_rounded,
    AppIcons.categoryPersonalCare: Icons.spa_outlined,
    AppIcons.categoryFirstAid: Icons.healing_outlined,
    AppIcons.categoryHealthDevices: Icons.favorite_border_rounded,
    AppIcons.categoryEyeCare: Icons.visibility_outlined,
    AppIcons.categoryOralCare: Icons.sentiment_satisfied_outlined,
    AppIcons.categorySkinCare: Icons.face_retouching_natural_outlined,
    AppIcons.categoryAyurveda: Icons.grass_outlined,
    AppIcons.categoryPetCare: Icons.pets_outlined,

    AppIcons.uploadPrescription: Icons.description_outlined,
    AppIcons.quickDelivery: Icons.two_wheeler_outlined,
    AppIcons.offers: Icons.local_offer_outlined,

    AppIcons.statusPending: Icons.hourglass_empty_rounded,
    AppIcons.statusProcessing: Icons.autorenew_rounded,
    AppIcons.statusShipped: Icons.local_shipping_outlined,
    AppIcons.statusDelivered: Icons.check_circle_outline_rounded,
    AppIcons.statusCancelled: Icons.cancel_outlined,

    AppIcons.wallet: Icons.account_balance_wallet_outlined,
    AppIcons.coupon: Icons.sell_outlined,
    AppIcons.prescriptionDoc: Icons.receipt_long_outlined,
    AppIcons.addressBook: Icons.location_on_outlined,
    AppIcons.paymentMethods: Icons.credit_card_outlined,
    AppIcons.reminders: Icons.notifications_active_outlined,
    AppIcons.reviews: Icons.star_border_rounded,
    AppIcons.referEarn: Icons.card_giftcard_outlined,
    AppIcons.helpSupport: Icons.help_outline_rounded,
    AppIcons.logout: Icons.logout_rounded,

    AppIcons.vitalsHeartRate: Icons.favorite_rounded,
    AppIcons.vitalsBloodPressure: Icons.water_drop_rounded,
    AppIcons.vitalsSpo2: Icons.opacity_rounded,
    AppIcons.vitalsTemperature: Icons.thermostat_rounded,
    AppIcons.labReports: Icons.science_outlined,
    AppIcons.medicalDocuments: Icons.folder_outlined,
    AppIcons.vaccinationRecords: Icons.vaccines_outlined,
    AppIcons.healthCheckups: Icons.monitor_heart_outlined,
    AppIcons.appointments: Icons.calendar_today_outlined,
    AppIcons.shieldCheck: Icons.verified_user_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final realAsset = AppImages.homeIcons[assetPath];
    if (realAsset != null) {
      // No color tint here, deliberately - confirmed directly (not
      // assumed) that these source PNGs have no alpha channel at all,
      // they're flat opaque RGB. BlendMode.srcIn tinting recolors every
      // non-transparent pixel, and since the whole canvas is
      // non-transparent, that flattens the entire image into one solid
      // colored square instead of just recoloring the icon shape. These
      // render at their own natural color; `color` is ignored for them.
      return Image.asset(realAsset, width: size, height: size);
    }

    final fallback = _fallbackMap[assetPath] ?? Icons.circle_outlined;

    return Icon(fallback, size: size, color: color);
  }
}
