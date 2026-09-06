import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/appointment_booking.dart';
import '../../providers/appointment_provider.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingBookings && provider.myBookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.myBookings.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadMyBookings);
          }
          if (provider.myBookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No appointments booked yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadMyBookings,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.myBookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _BookingCard(booking: provider.myBookings[i]),
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final AppointmentBooking booking;

  Color _statusColor() {
    switch (booking.status) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (booking.doctorDegree.isNotEmpty)
                      Text(booking.doctorDegree, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: _statusColor().withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  booking.status[0].toUpperCase() + booking.status.substring(1),
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: _statusColor()),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Icon(Icons.local_hospital_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(child: Text(booking.hospitalName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
            ],
          ),
          if (booking.hospitalAddress.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(booking.hospitalAddress, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted))),
              ],
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(DateFormat('EEE, dd MMM yyyy').format(booking.scheduledDate), style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}
