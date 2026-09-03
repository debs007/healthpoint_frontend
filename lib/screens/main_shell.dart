import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/app_icon.dart';
import '../core/constants/app_icons.dart';
import '../providers/cart_provider.dart';
import '../providers/notification_provider.dart';
import 'account/account_screen.dart';
import 'categories/categories_screen.dart';
import 'health_records/health_records_screen.dart';
import 'home/home_screen.dart';
import 'orders/orders_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  final _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    OrdersScreen(),
    HealthRecordsScreen(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Cart badge needs to be live from the moment the app shell mounts,
    // not just whenever the user happens to open the cart itself.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadCart();
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.navHome),
            activeIcon: AppIcon(AppIcons.navHome, color: AppColors.primary),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.navCategories),
            activeIcon: AppIcon(AppIcons.navCategories, color: AppColors.primary),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.navOrders),
            activeIcon: AppIcon(AppIcons.navOrders, color: AppColors.primary),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.navHealthRecords),
            activeIcon: AppIcon(AppIcons.navHealthRecords, color: AppColors.primary),
            label: 'Health Records',
          ),
          BottomNavigationBarItem(
            icon: AppIcon(AppIcons.navAccount),
            activeIcon: AppIcon(AppIcons.navAccount, color: AppColors.primary),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
