import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/doctor.dart';
import '../../models/doctor_hospital_affiliation.dart';
import '../../providers/appointment_provider.dart';
import '../payment/payment_screen.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required this.doctor, required this.affiliation});

  final Doctor doctor;
  final DoctorHospitalAffiliation affiliation;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final visitDayNames = widget.affiliation.visitDayNames;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: (date) {
        final dayName = DateFormat('EEEE').format(date).toLowerCase();
        return visitDayNames.contains(dayName);
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_selectedDate == null) return;

    final order = await context.read<AppointmentProvider>().book(
          doctorId: widget.doctor.id,
          affiliationId: widget.affiliation.affiliationId,
          scheduledDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        );

    if (!mounted) return;

    if (order != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PaymentScreen(order: order)),
      );
    } else {
      final error = context.read<AppointmentProvider>().errorMessage;
      if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final affiliation = widget.affiliation;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.doctor.degree, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                const Divider(height: 20),
                Row(
                  children: [
                    Icon(Icons.local_hospital_outlined, size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(child: Text(affiliation.hospitalName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(affiliation.hospitalAddress, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select a date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedDate != null ? DateFormat('EEE, dd MMM yyyy').format(_selectedDate!) : 'Choose a date',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Available on: ${affiliation.visitDays.map((d) => d.dayOfWeek[0].toUpperCase() + d.dayOfWeek.substring(1)).join(', ')}',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 28),
          Consumer<AppointmentProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && !provider.isBooking) ? _submit : null,
                child: provider.isBooking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Proceed to Pay ${AppConstants.currencySymbol}${affiliation.consultationCharge.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
