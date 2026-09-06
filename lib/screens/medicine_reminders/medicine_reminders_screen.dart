import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/medicine_reminder.dart';
import '../../providers/medicine_reminder_provider.dart';
import 'add_reminder_screen.dart';

class MedicineRemindersScreen extends StatefulWidget {
  const MedicineRemindersScreen({super.key});

  @override
  State<MedicineRemindersScreen> createState() => _MedicineRemindersScreenState();
}

class _MedicineRemindersScreenState extends State<MedicineRemindersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineReminderProvider>().loadReminders();
    });
  }

  Future<void> _confirmStop(MedicineReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop this reminder?'),
        content: Text('You\'ll no longer get reminders for ${reminder.medicineName}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Stop')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<MedicineReminderProvider>().stopReminder(reminder);
    if (!mounted) return;

    if (!success) {
      final error = context.read<MedicineReminderProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Couldn\'t stop this reminder.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      body: Consumer<MedicineReminderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.reminders.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadReminders);
          }
          if (provider.reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No reminders set up yet. Tap the + button to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadReminders,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.reminders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _ReminderCard(reminder: provider.reminders[i], onStop: () => _confirmStop(provider.reminders[i])),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddReminderScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.reminder, required this.onStop});

  final MedicineReminder reminder;
  final VoidCallback onStop;

  String get _timesLabel => reminder.times.join(', ');

  String get _durationLabel {
    final start = DateFormat('dd MMM').format(reminder.startDate);
    if (reminder.endDate == null) return 'From $start, ongoing';
    return '$start - ${DateFormat('dd MMM yyyy').format(reminder.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.medication_outlined, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reminder.medicineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (reminder.dosageNote != null && reminder.dosageNote!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(reminder.dosageNote!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(child: Text(_timesLabel, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted))),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(_durationLabel, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications_off_outlined, color: AppColors.textMuted, size: 20),
            tooltip: 'Stop reminder',
            onPressed: onStop,
          ),
        ],
      ),
    );
  }
}
