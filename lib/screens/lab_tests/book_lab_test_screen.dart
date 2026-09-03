import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/address.dart';
import '../../models/franchise.dart';
import '../../models/lab_test.dart';
import '../../providers/address_provider.dart';
import '../../providers/franchise_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../payment/payment_screen.dart';

class BookLabTestScreen extends StatefulWidget {
  const BookLabTestScreen({super.key, required this.test});

  final LabTest test;

  @override
  State<BookLabTestScreen> createState() => _BookLabTestScreenState();
}

class _BookLabTestScreenState extends State<BookLabTestScreen> {
  Franchise? _selectedFranchise;
  Address? _selectedAddress;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final franchiseProvider = context.read<FranchiseProvider>();
      if (franchiseProvider.franchises.isEmpty) franchiseProvider.loadFranchises();
      if (!widget.test.requiresCenterVisit) {
        final addressProvider = context.read<AddressProvider>();
        if (addressProvider.addresses.isEmpty) addressProvider.loadAddresses();
      }
    });
  }

  bool get _canSubmit {
    if (_selectedFranchise == null || _selectedDate == null) return false;
    if (!widget.test.requiresCenterVisit && _selectedAddress == null) return false;
    return true;
  }

  Future<void> _pickDate() async {
    final labTests = context.read<LabTestProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      selectableDayPredicate: (date) => !labTests.isDateBlocked(date),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final order = await context.read<LabTestProvider>().book(
          labTestId: widget.test.id,
          franchiseId: _selectedFranchise!.id,
          scheduledDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
          addressId: _selectedAddress?.id,
        );

    if (!mounted) return;

    if (order != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PaymentScreen(order: order)),
      );
    } else {
      final error = context.read<LabTestProvider>().errorMessage;
      if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final test = widget.test;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Test')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(
                  '${AppConstants.currencySymbol}${test.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                ),
                if (test.preparationInstructions != null) ...[
                  const SizedBox(height: 8),
                  Text('Before your test: ${test.preparationInstructions}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            test.requiresCenterVisit ? 'This test requires a center visit' : 'A technician will visit your home',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          const Text('Store', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Consumer<FranchiseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return const LinearProgressIndicator();
              return _SelectTile(
                label: _selectedFranchise?.name ?? 'Select a store',
                icon: Icons.storefront_outlined,
                onTap: () async {
                  final selected = await showModalBottomSheet<Franchise>(
                    context: context,
                    builder: (context) => ListView(
                      shrinkWrap: true,
                      children: provider.franchises
                          .map((f) => ListTile(title: Text(f.name), subtitle: Text(f.locationLabel), onTap: () => Navigator.pop(context, f)))
                          .toList(),
                    ),
                  );
                  if (selected != null) setState(() => _selectedFranchise = selected);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          const Text('Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _SelectTile(
            label: _selectedDate != null ? DateFormat('EEE, dd MMM yyyy').format(_selectedDate!) : 'Choose a date',
            icon: Icons.calendar_today_outlined,
            onTap: _pickDate,
          ),

          if (!test.requiresCenterVisit) ...[
            const SizedBox(height: 16),
            const Text('Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Consumer<AddressProvider>(
              builder: (context, provider, _) {
                return _SelectTile(
                  label: _selectedAddress?.shortLabel ?? 'Select an address',
                  icon: Icons.location_on_outlined,
                  onTap: () async {
                    final selected = await showModalBottomSheet<Address>(
                      context: context,
                      builder: (context) => ListView(
                        shrinkWrap: true,
                        children: provider.addresses
                            .map((a) => ListTile(title: Text(a.shortLabel), subtitle: a.label != null ? Text(a.label!) : null, onTap: () => Navigator.pop(context, a)))
                            .toList(),
                      ),
                    );
                    if (selected != null) setState(() => _selectedAddress = selected);
                  },
                );
              },
            ),
          ],

          const SizedBox(height: 28),
          Consumer<LabTestProvider>(
            builder: (context, provider, _) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_canSubmit && !provider.isBooking) ? _submit : null,
                child: provider.isBooking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Proceed to Pay ${AppConstants.currencySymbol}${test.price.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
