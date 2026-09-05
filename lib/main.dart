import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'providers/address_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/brand_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/coupon_provider.dart';
import 'providers/franchise_provider.dart';
import 'providers/health_article_provider.dart';
import 'providers/health_provider.dart';
import 'providers/home_banner_provider.dart';
import 'providers/lab_test_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/order_provider.dart';
import 'providers/prescription_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'services/address_service.dart';
import 'services/appointment_service.dart';
import 'services/auth_service.dart';
import 'services/brand_service.dart';
import 'services/cart_service.dart';
import 'services/coupon_service.dart';
import 'services/franchise_service.dart';
import 'services/health_article_service.dart';
import 'services/health_service.dart';
import 'services/home_banner_service.dart';
import 'services/lab_test_service.dart';
import 'services/notification_service.dart';
import 'services/order_service.dart';
import 'services/prescription_service.dart';
import 'services/product_service.dart';
import 'services/wallet_service.dart';

void main() {
  runApp(const SusthayanApp());
}

class SusthayanApp extends StatelessWidget {
  const SusthayanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // One ApiClient for the whole app - every service below shares it,
    // so the auth token/401 handling only needs to be configured once.
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final auth = AuthProvider(AuthService(apiClient));
            // Wires the network layer's 401 handling back to auth state -
            // ApiClient can't hold a reference to AuthProvider itself
            // (it's constructed first, with no BuildContext), so this
            // callback is how a 401 anywhere in the app ends up forcing
            // a logout instead of just failing silently.
            apiClient.onUnauthorized = auth.forceLogout;
            return auth;
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider(CartService(apiClient))),
        ChangeNotifierProvider(create: (_) => CouponProvider(CouponService(apiClient))),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService(apiClient))),
        ChangeNotifierProvider(create: (_) => WalletProvider(WalletService(apiClient))),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService(apiClient))),
        ChangeNotifierProvider(create: (_) => AddressProvider(AddressService(apiClient))),
        ChangeNotifierProvider(create: (_) => AppointmentProvider(AppointmentService(apiClient))),
        ChangeNotifierProvider(create: (_) => BrandProvider(BrandService(apiClient))),
        ChangeNotifierProvider(create: (_) => PrescriptionProvider(PrescriptionService(apiClient))),
        ChangeNotifierProvider(create: (_) => FranchiseProvider(FranchiseService(apiClient))),
        ChangeNotifierProvider(create: (_) => HealthProvider(HealthService(apiClient))),
        ChangeNotifierProvider(create: (_) => HealthArticleProvider(HealthArticleService(apiClient))),
        ChangeNotifierProvider(create: (_) => HomeBannerProvider(HomeBannerService(apiClient))),
        ChangeNotifierProvider(create: (_) => LabTestProvider(LabTestService(apiClient))),
        ChangeNotifierProvider(create: (_) => NotificationProvider(NotificationService(apiClient))),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
