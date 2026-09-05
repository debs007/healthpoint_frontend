import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/address.dart';
import '../../models/lab_center.dart';
import '../../models/lab_test.dart';
import '../../providers/address_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../payment/payment_screen.dart';

/// Center selection is always shown here, regardless of the test's visit
/// type - even for a home-collection test, the customer picks which
/// center processes their sample (their own preference for which lab to
/// trust), they just also pick an address alongside it. Only the address
/// step and the set of qualifying centers differ by visit type - not
/// whether center selection happens at all.
class BookLabTestScreen extends StatefulWidget {
  const BookLabTestScreen({super.key, required this.test});

  final LabTest test;

  @override
  State<BookLabTestScreen> createState() => _BookLabTestScreenState();
}

class _BookLabTestScreenState extends State<BookLabTestScreen> {
  List<LabCenter> _centers = [];
  LabCenter? _selectedCenter;
  Address? _selectedAddress;
  DateTime? _selectedDate;
  bool _loadingCenters = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final centers = await context.read<LabTestProvider>().loadCentersFor(widget.test.id);
      if (!mounted) return;
      setState(() {
        _centers = centers;
        _loadingCenters = false;
      });

      final addressProvider = context.read<AddressProvider>();
      if (!widget.test.requiresCenterVisit && addressProvider.addresses.isEmpty) {
        addressProvider.loadAddresses();
      }
    });
  }

  bool get _canSubmit {
    if (_selectedCenter == null || _selectedDate == null) return false;
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

  Future<void> _pickCenter() async {
    final selected = await showModalBottomSheet<LabCenter>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _centers.isEmpty
            ? const Center(child: Text('No centers currently offer this test.'))
            : ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _centers.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('Select a center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    );
                  }
                  final center = _centers[i - 1];
                  return ListTile(
                    tileColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
                    leading: Icon(Icons.local_hospital_outlined, color: AppColors.primary),
                    title: Text(center.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(center.fullAddress, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: center.price != null
                        ? Text('${AppConstants.currencySymbol}${center.price!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                    onTap: () => Navigator.pop(context, center),
                  );
                },
              ),
      ),
    );
    if (selected != null) setState(() => _selectedCenter = selected);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final order = await context.read<LabTestProvider>().book(
          labTestId: widget.test.id,
          labCenterId: _selectedCenter!.id,
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
    final price = _selectedCenter?.price ?? test.price;

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
                  '${AppConstants.currencySymbol}${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                ),
                if (_selectedCenter != null)
                  Text('at ${_selectedCenter!.name}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (test.preparationInstructions != null) ...[
                  const SizedBox(height: 8),
                  Text('Before your test: ${test.preparationInstructions}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            test.requiresCenterVisit ? 'This test requires a center visit' : 'A technician will visit your home - choose which center processes your sample',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 12),

          const Text('Center', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          _loadingCenters
              ? const LinearProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectTile(
                      label: _selectedCenter?.name ?? 'Select a center',
                      icon: Icons.local_hospital_outlined,
                      onTap: _pickCenter,
                    ),
                    if (_selectedCenter != null) ...[
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Expanded(child: Text(_selectedCenter!.fullAddress, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted))),
                          ],
                        ),
                      ),
                    ],
                  ],
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
            const Text('Collection Address', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Consumer<AddressProvider>(
              builder: (context, provider, _) {
                return _SelectTile(
                  label: _selectedAddress?.shortLabel ?? 'Select an address',
                  icon: Icons.home_outlined,
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
                    : Text('Proceed to Pay ${AppConstants.currencySymbol}${price.toStringAsFixed(2)}'),
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
