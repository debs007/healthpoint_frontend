import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/error_state.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Goes through OrderProvider (already registered app-wide in
      // main.dart) rather than instantiating OrderService directly -
      // OrderService itself was never registered as its own injectable
      // provider, only wrapped inside OrderProvider.
      final provider = context.read<OrderProvider>();
      _order = await provider.getOrderDetail(widget.orderId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_order != null ? _order!.displayId : 'Order details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ErrorState(message: _errorMessage!, onRetry: _load)
              : _order == null
                  ? const SizedBox.shrink()
                  : _OrderDetailBody(order: _order!),
    );
  }
}

class _OrderDetailBody extends StatelessWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.statusColor(order.status);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(14)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.displayId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Placed ${dateFormat.format(order.placedAt)}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (order.franchiseName != null)
                    Text('From ${order.franchiseName}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  order.status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          order.orderType == 'lab_test'
              ? 'Test Booked'
              : order.orderType == 'appointment'
                  ? 'Appointment Details'
                  : 'Items',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 10),
        if (order.orderType == 'lab_test' && order.labTestBookings.isNotEmpty)
          _LabTestBookingCard(bookings: order.labTestBookings)
        else if (order.orderType == 'lab_test' && order.labTestBooking != null)
          _LabTestBookingCard(bookings: [order.labTestBooking!])
        else if (order.orderType == 'appointment' && order.appointmentBooking != null)
          _AppointmentBookingCard(booking: order.appointmentBooking!)
        else if (order.items.isEmpty)
          Text('No item details available.', style: TextStyle(color: AppColors.textMuted))
        else
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: order.items.map((item) {
                final isLast = item == order.items.last;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.productName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ),
                      Text('x${item.quantity}', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      const SizedBox(width: 12),
                      Text(
                        '${AppConstants.currencySymbol}${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total paid', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${AppConstants.currencySymbol}${order.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
            ],
          ),
        ),
        if (order.deliveredAt != null) ...[
          const SizedBox(height: 12),
          Text(
            'Delivered on ${dateFormat.format(order.deliveredAt!)}',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _LabTestBookingCard extends StatelessWidget {
  const _LabTestBookingCard({required this.bookings});

  final List<LabTestBookingInfo> bookings;

  @override
  Widget build(BuildContext context) {
    final first = bookings.first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final booking in bookings) ...[
            Text(booking.testName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            if (booking != bookings.last) const SizedBox(height: 4),
          ],
          const SizedBox(height: 10),
          // Every test in one booking shares the same visit type, center,
          // and date - shown once here rather than repeated per test.
          _DetailLine(
            icon: first.bookingType == 'center_visit' ? Icons.storefront_outlined : Icons.home_outlined,
            label: first.bookingType == 'center_visit' ? 'Center visit' : 'Home collection',
          ),
          if (first.centerName != null) ...[
            const SizedBox(height: 6),
            _DetailLine(icon: Icons.local_hospital_outlined, label: first.centerName!),
          ],
          if (first.centerAddress != null) ...[
            const SizedBox(height: 6),
            _DetailLine(icon: Icons.location_on_outlined, label: first.centerAddress!),
          ],
          const SizedBox(height: 6),
          _DetailLine(icon: Icons.calendar_today_outlined, label: DateFormat('EEE, dd MMM yyyy').format(first.scheduledDate)),
        ],
      ),
    );
  }
}

class _AppointmentBookingCard extends StatelessWidget {
  const _AppointmentBookingCard({required this.booking});

  final AppointmentBookingInfo booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dr. ${booking.doctorName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          if (booking.doctorDegree != null) ...[
            const SizedBox(height: 2),
            Text(booking.doctorDegree!, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 10),
          if (booking.hospitalName != null) ...[
            _DetailLine(icon: Icons.local_hospital_outlined, label: booking.hospitalName!),
            const SizedBox(height: 6),
          ],
          if (booking.hospitalAddress != null) ...[
            _DetailLine(icon: Icons.location_on_outlined, label: booking.hospitalAddress!),
            const SizedBox(height: 6),
          ],
          _DetailLine(icon: Icons.calendar_today_outlined, label: DateFormat('EEE, dd MMM yyyy').format(booking.scheduledDate)),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5))),
      ],
    );
  }
}
