/// Every icon asset path the app references. When real icon files are
/// provided, name them EXACTLY as listed here and drop them into
/// assets/icons/ - nothing else needs to change, since every screen reads
/// through these constants (via AppIcon in core/widgets/app_icon.dart)
/// rather than hardcoding a path or a Material icon directly.
///
/// Until then, AppIcon renders a Material-icon fallback for each of these
/// keys - see the _fallbackMap in that file for the current mapping.
class AppIcons {
  AppIcons._();

  // --- Navigation (bottom bar) ---
  static const String navHome = 'assets/icons/ic_nav_home.svg';
  static const String navCategories = 'assets/icons/ic_nav_categories.svg';
  static const String navOrders = 'assets/icons/ic_nav_orders.svg';
  static const String navHealthRecords = 'assets/icons/ic_nav_health_records.svg';
  static const String navAccount = 'assets/icons/ic_nav_account.svg';

  // --- Top bar / common ---
  static const String location = 'assets/icons/ic_location.svg';
  static const String search = 'assets/icons/ic_search.svg';
  static const String scan = 'assets/icons/ic_scan.svg';
  static const String notification = 'assets/icons/ic_notification.svg';
  static const String cart = 'assets/icons/ic_cart.svg';
  static const String settings = 'assets/icons/ic_settings.svg';
  static const String camera = 'assets/icons/ic_camera.svg';
  static const String chevronRight = 'assets/icons/ic_chevron_right.svg';
  static const String copy = 'assets/icons/ic_copy.svg';
  static const String upload = 'assets/icons/ic_upload.svg';
  static const String lock = 'assets/icons/ic_lock.svg';
  static const String phone = 'assets/icons/ic_phone.svg';
  static const String email = 'assets/icons/ic_email.svg';

  // --- Home quick actions / categories ---
  static const String categoryMedicines = 'assets/icons/ic_cat_medicines.svg';
  static const String categoryHealthcare = 'assets/icons/ic_cat_healthcare.svg';
  static const String categoryLabTests = 'assets/icons/ic_cat_lab_tests.svg';
  static const String categoryMotherBaby = 'assets/icons/ic_cat_mother_baby.svg';
  static const String categoryFitness = 'assets/icons/ic_cat_fitness.svg';
  static const String categoryViewAll = 'assets/icons/ic_cat_view_all.svg';
  static const String categoryPersonalCare = 'assets/icons/ic_cat_personal_care.svg';
  static const String categoryFirstAid = 'assets/icons/ic_cat_first_aid.svg';
  static const String categoryHealthDevices = 'assets/icons/ic_cat_health_devices.svg';
  static const String categoryEyeCare = 'assets/icons/ic_cat_eye_care.svg';
  static const String categoryOralCare = 'assets/icons/ic_cat_oral_care.svg';
  static const String categorySkinCare = 'assets/icons/ic_cat_skin_care.svg';
  static const String categoryAyurveda = 'assets/icons/ic_cat_ayurveda.svg';
  static const String categoryPetCare = 'assets/icons/ic_cat_pet_care.svg';

  static const String uploadPrescription = 'assets/icons/ic_upload_prescription.svg';
  static const String quickDelivery = 'assets/icons/ic_quick_delivery.svg';
  static const String offers = 'assets/icons/ic_offers.svg';

  // --- Orders ---
  static const String statusPending = 'assets/icons/ic_status_pending.svg';
  static const String statusProcessing = 'assets/icons/ic_status_processing.svg';
  static const String statusShipped = 'assets/icons/ic_status_shipped.svg';
  static const String statusDelivered = 'assets/icons/ic_status_delivered.svg';
  static const String statusCancelled = 'assets/icons/ic_status_cancelled.svg';

  // --- Account menu ---
  static const String wallet = 'assets/icons/ic_wallet.svg';
  static const String coupon = 'assets/icons/ic_coupon.svg';
  static const String prescriptionDoc = 'assets/icons/ic_prescription_doc.svg';
  static const String addressBook = 'assets/icons/ic_address_book.svg';
  static const String paymentMethods = 'assets/icons/ic_payment_methods.svg';
  static const String reminders = 'assets/icons/ic_reminders.svg';
  static const String reviews = 'assets/icons/ic_reviews.svg';
  static const String referEarn = 'assets/icons/ic_refer_earn.svg';
  static const String helpSupport = 'assets/icons/ic_help_support.svg';
  static const String logout = 'assets/icons/ic_logout.svg';

  // --- Health records ---
  static const String vitalsHeartRate = 'assets/icons/ic_vitals_heart_rate.svg';
  static const String vitalsBloodPressure = 'assets/icons/ic_vitals_blood_pressure.svg';
  static const String vitalsSpo2 = 'assets/icons/ic_vitals_spo2.svg';
  static const String vitalsTemperature = 'assets/icons/ic_vitals_temperature.svg';
  static const String labReports = 'assets/icons/ic_lab_reports.svg';
  static const String medicalDocuments = 'assets/icons/ic_medical_documents.svg';
  static const String vaccinationRecords = 'assets/icons/ic_vaccination_records.svg';
  static const String healthCheckups = 'assets/icons/ic_health_checkups.svg';
  static const String appointments = 'assets/icons/ic_appointments.svg';
  static const String shieldCheck = 'assets/icons/ic_shield_check.svg';
}
