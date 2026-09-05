import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/health_record_item.dart';
import '../../providers/health_provider.dart';

class RecordsListScreen extends StatelessWidget {
  const RecordsListScreen({super.key, required this.type, required this.typeLabel});

  final String type;
  final String typeLabel;

  Future<void> _confirmDelete(BuildContext context, HealthRecordItem record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this record?'),
        content: Text('"${record.title}" will be permanently deleted. This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await context.read<HealthProvider>().deleteRecord(record.id);
    if (!context.mounted) return;

    if (!success) {
      final error = context.read<HealthProvider>().errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? 'Couldn\'t delete this record.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(typeLabel)),
      body: Consumer<HealthProvider>(
        builder: (context, provider, _) {
          final items = provider.records.where((r) => r.type == type).toList();

          if (items.isEmpty) {
            return Center(child: Text('No records here yet.', style: TextStyle(color: AppColors.textMuted)));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final record = items[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(record.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(DateFormat('dd MMM yyyy').format(record.recordDate), style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          if (record.notes != null && record.notes!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(record.notes!, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                          if (!record.hasFile) ...[
                            const SizedBox(height: 4),
                            Text('No file attached', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                    ),
                    // Prescription entries aren't real HealthRecord rows -
                    // they come from a separate model with its own
                    // lifecycle, so there's genuinely no delete action
                    // for them here.
                    if (!record.isPrescription)
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.textMuted),
                        onPressed: () => _confirmDelete(context, record),
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
