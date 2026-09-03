import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/error_state.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../order_detail/order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  // Backend status values (see Enums/OrderStatus.php) mapped to the tab
  // labels shown in the design - "Processing" covers everything between
  // confirmed and out_for_delivery, matching how the design groups them,
  // not a 1:1 status-to-tab mapping.
  static const _tabs = <String, List<String>?>{
    'All Orders': null,
    'Pending': ['pending_payment'],
    'Processing': ['confirmed', 'preparing', 'ready_for_dispatch'],
    'Shipped': ['out_for_delivery'],
    'Delivered': ['delivered', 'picked_up'],
    'Cancelled': ['cancelled', 'refunded'],
  };

  String _activeTab = 'All Orders';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.orders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.orders.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadOrders);
          }

          final statuses = _tabs[_activeTab];
          final filtered = statuses == null
              ? provider.orders
              : provider.orders.where((o) => statuses.contains(o.status)).toList();

          return Column(
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _tabs.keys.map((tab) {
                    final selected = tab == _activeTab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeTab = tab),
                        selectedColor: AppColors.surfaceTint,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.primary : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                        ),
                        side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('No orders in this category yet.', style: TextStyle(color: AppColors.textMuted)),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.loadOrders,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) => _OrderCard(order: filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(order.status);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order ID', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text(order.displayId, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Placed on ${dateFormat.format(order.placedAt)}',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const Divider(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text(
                      '${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Items', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    Text('${order.items.length} item(s)', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: order.id)),
              ),
              child: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}
