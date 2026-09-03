/// Every API path the app calls, matching routes/api.php exactly. If the
/// backend route changes, this is the only file that needs updating.
class ApiEndpoints {
  ApiEndpoints._();

  // --- Auth ---
  static const String otpRequest = '/auth/customer/otp/request';
  static const String otpVerify = '/auth/customer/otp/verify';
  static const String me = '/me';
  static const String updateProfile = '/customer/profile';
  static const String logout = '/logout';

  // --- Notifications ---
  static const String notifications = '/customer/notifications';
  static String markNotificationRead(int id) => '/customer/notifications/$id/read';
  static const String markAllNotificationsRead = '/customer/notifications/mark-all-read';

  // --- Health Records ---
  static const String healthProfile = '/customer/health/profile';
  static const String vitals = '/customer/health/vitals';
  static const String healthRecords = '/customer/health/records';
  static String healthRecordFile(String id) => '/customer/health/records/$id/file';

  // --- Lab Tests ---
  static const String labTests = '/customer/lab-tests';
  static const String labTestBlockedDates = '/customer/lab-tests/blocked-dates';
  static const String labTestBookings = '/customer/lab-test-bookings';

  // --- Home Banners ---
  static const String homeBanners = '/customer/home-banners';

  // --- Brands ---
  static const String brands = '/customer/brands';

  // --- Franchises ---
  static const String franchises = '/customer/franchises';

  // --- Addresses ---
  static const String addresses = '/customer/addresses';
  static String address(int id) => '/customer/addresses/$id';

  // --- Products ---
  static const String products = '/customer/products';
  static String product(int id) => '/customer/products/$id';

  // --- Cart ---
  static const String cart = '/customer/cart';
  static const String cartSelectFranchise = '/customer/cart/select-franchise';
  static const String cartItems = '/customer/cart/items';
  static String cartItem(int id) => '/customer/cart/items/$id';

  // --- Prescriptions ---
  static const String prescriptions = '/customer/prescriptions';

  // --- Orders ---
  static const String orders = '/customer/orders';
  static String order(int id) => '/customer/orders/$id';
  static String initiatePayment(int orderId) => '/customer/orders/$orderId/payments/initiate';
  static const String verifyPayment = '/payments/verify';
  static String refunds(int orderId) => '/customer/orders/$orderId/refunds';
}
