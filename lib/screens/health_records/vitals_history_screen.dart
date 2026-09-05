import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vital.dart';
import '../../providers/health_provider.dart';

class VitalsHistoryScreen extends StatelessWidget {
  const VitalsHistoryScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Vital vital) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this entry?'),
        content: Text('The reading from ${DateFormat('dd MMM yyyy, hh:mm a').format(vital.recordedAt)} will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<HealthProvider>().deleteVital(vital.id);
    if (!context.mounted) return;

    if (!success) {
      final error = context.read<HealthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Couldn\'t delete this entry.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vitals History')),
      body: Consumer<HealthProvider>(
        builder: (context, provider, _) {
          if (provider.vitals.isEmpty) {
            return Center(child: Text('No vitals logged yet.', style: TextStyle(color: AppColors.textMuted)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.vitals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final vital = provider.vitals[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy, hh:mm a').format(vital.recordedAt),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            runSpacing: 6,
                            children: [
                              if (vital.heartRateBpm != null) _Reading(label: 'Heart Rate', value: '${vital.heartRateBpm} bpm'),
                              if (vital.bloodPressureLabel != null) _Reading(label: 'BP', value: vital.bloodPressureLabel!),
                              if (vital.spo2Percentage != null) _Reading(label: 'SpO2', value: '${vital.spo2Percentage}%'),
                              if (vital.temperatureFahrenheit != null) _Reading(label: 'Temp', value: '${vital.temperatureFahrenheit}°F'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                      onPressed: () => _confirmDelete(context, vital),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
