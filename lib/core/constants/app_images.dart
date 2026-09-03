import 'app_icons.dart';

/// Real image assets. Mapping corrected from directly viewing each source
/// file individually (not inferred from file size/transparency, which
/// previously mismatched the Apple icon with a chevron-down arrow -
/// direct observation is the reliable source here, not a heuristic).
///
/// Important: there is no standalone Susthayan logo-mark file in the
/// provided set. The only place the actual cross/plus mark appears is
/// baked into loginHero itself (it's a full branded banner - logo,
/// wordmark, tagline, and the pill-bottle illustration all in one image),
/// which is why the login screen doesn't render a separate logo anymore.
class AppImages {
  AppImages._();

  /// The full branded banner - logo, wordmark, tagline, and illustration
  /// all in one file. This is the ONLY branding element on the login
  /// screen now; nothing else duplicates it.
  static const String loginHero = 'assets/images/login_hero.png';

  static const String socialApple = 'assets/images/social_apple.png';
  static const String socialGoogle = 'assets/images/social_google.png';

  static const String badgeGenuine = 'assets/images/badge_genuine.png';
  static const String badgeDelivery = 'assets/images/badge_delivery.png';
  static const String badgeSupport = 'assets/images/badge_support.png';

  /// Not used on the login screen (no password field per this build's
  /// scope) - kept in case a future screen needs them.
  static const String iconEyeOff = 'assets/images/icon_eye_off.png';
  static const String iconLock = 'assets/images/icon_lock.png';
  static const String iconPhone = 'assets/images/icon_phone.png';
  static const String iconChevronDown = 'assets/images/icon_chevron_down.png';

  // --- Home screen ---
  /// Decorative banner artwork for the home promo card. The promotional
  /// TEXT ("FLAT 20% OFF" etc.) stays as real Flutter widgets, not baked
  /// into this image - that copy is business content that needs to be
  /// editable, not a fixed graphic.
  static const String homePromoBanner = 'assets/images/home_promo_banner.png';
  static const String homeSecondaryBanner = 'assets/images/home_secondary_banner.png';
  static const String articleImmunity = 'assets/images/article_immunity.png';
  static const String articleHabits = 'assets/images/article_habits.png';

  /// Real icon assets now available for the home screen - keyed by the
  /// matching AppIcons constant so AppIcon (core/widgets/app_icon.dart)
  /// can prefer these over its Material fallback automatically.
  ///
  /// location/search/notification/cart/scan are deliberately NOT mapped
  /// here even though similar assets exist in the source set - they're
  /// 500x500 canvases with a lot of opaque white padding around a small
  /// centered glyph, which reads as a visible white square at 18-24px in
  /// a toolbar rather than a clean icon. Material fallback is the actual
  /// better fit there, not a placeholder waiting to be replaced.
  ///
  /// IMPORTANT - none of these source PNGs have an alpha channel (verified
  /// directly, not assumed): they're flat opaque RGB. AppIcon does not
  /// apply color tinting to anything in this map for exactly that reason -
  /// tinting an opaque image recolors the entire canvas, not just the
  /// icon shape, which is what caused every one of these to render as a
  /// solid colored square before this was caught.
  static const Map<String, String> homeIcons = {
    AppIcons.categoryMedicines: 'assets/images/home_icons/ic_cat_medicines.png',
    AppIcons.categoryHealthcare: 'assets/images/home_icons/ic_cat_healthcare.png',
    AppIcons.categoryLabTests: 'assets/images/home_icons/ic_cat_lab_tests.png',
    AppIcons.categoryMotherBaby: 'assets/images/home_icons/ic_cat_mother_baby.png',
    AppIcons.categoryFitness: 'assets/images/home_icons/ic_cat_fitness.png',
    AppIcons.categoryViewAll: 'assets/images/home_icons/ic_cat_view_all.png',
    AppIcons.uploadPrescription: 'assets/images/home_icons/ic_upload_prescription.png',
    AppIcons.quickDelivery: 'assets/images/home_icons/ic_quick_delivery.png',
    AppIcons.offers: 'assets/images/home_icons/ic_offers.png',
  };

  /// Fallback product imagery - used ONLY when a real product from the
  /// API has no image_url of its own. These are NOT tied to specific
  /// live products; the product grid always prefers the real
  /// product.imageUrl from the backend first. Don't assume any live
  /// product actually matches what these photos depict.
  static const List<String> productFallbacks = [
    'assets/images/products/product_crocin650.png',
    'assets/images/products/product_dolo650.png',
    'assets/images/products/product_calcirol.png',
    'assets/images/products/product_amoxicillin500.png',
    'assets/images/products/product_spare_5.png',
    'assets/images/products/product_spare_6.png',
    'assets/images/products/product_spare_7.png',
    'assets/images/products/product_spare_8.png',
    'assets/images/products/product_spare_9.png',
    'assets/images/products/product_spare_10.png',
    'assets/images/products/product_spare_11.png',
  ];
}
