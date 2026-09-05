import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/health_profile.dart';
import '../../models/health_record_item.dart';
import '../../models/vital.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';
import '../appointments/departments_screen.dart';
import 'records_list_screen.dart';
import 'vitals_history_screen.dart';

/// Replaces the old "Coming soon" placeholder now that a real backend
/// module exists for it - profile, vitals, and records are all real.
/// Appointments now navigates to the real booking feature too - it used
/// to show "needs a booking system that hasn't been built yet," which is
/// no longer true.
class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Health Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: () => _showUploadSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.records.isEmpty && provider.vitals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.records.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadAll);
          }

          return RefreshIndicator(
            onRefresh: provider.loadAll,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Manage and track your health information', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                _ProfileCard(
                  name: user?.name ?? '',
                  profileImageUrl: user?.profileImageUrl,
                  profile: provider.profile,
                  vitalsCount: provider.vitals.length,
                  recordsCount: provider.records.length,
                ),
                const SizedBox(height: 20),
                const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                _QuickActionsRow(onUpload: () => _showUploadSheet(context), onLogVitals: () => _showVitalsSheet(context)),
                const SizedBox(height: 20),
                _VitalsCard(latest: provider.latestVital),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Health Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${provider.records.length} total', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 10),
                if (provider.records.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No records yet - tap upload to add one.', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  ..._groupByType(provider.records).entries.map((entry) => _RecordTypeGroup(type: entry.key, items: entry.value)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your data is safe with us. Records are private and only visible to you.',
                          style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<HealthRecordItem>> _groupByType(List<HealthRecordItem> records) {
    final grouped = <String, List<HealthRecordItem>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.type, () => []).add(record);
    }
    return grouped;
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _UploadRecordSheet(),
    );
  }

  void _showVitalsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _LogVitalsSheet(),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.name, required this.profileImageUrl, required this.profile, required this.vitalsCount, required this.recordsCount});

  final String name;
  final String? profileImageUrl;
  final HealthProfile profile;
  final int vitalsCount;
  final int recordsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white,
            backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
            child: profileImageUrl == null ? const Icon(Icons.person, color: AppColors.primary, size: 28) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello, $name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (profile.age != null) '${profile.age} Years',
                    if (profile.gender != null) (profile.gender as String)[0].toUpperCase() + (profile.gender as String).substring(1),
                  ].join(' • '),
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _StatChip(icon: Icons.favorite_border_rounded, count: vitalsCount, label: vitalsCount == 1 ? 'Vital logged' : 'Vitals logged'),
                    const SizedBox(width: 10),
                    _StatChip(icon: Icons.description_outlined, count: recordsCount, label: recordsCount == 1 ? 'Report' : 'Reports'),
                  ],
                ),
              ],
            ),
          ),
          if (profile.bloodGroup != null || profile.heightCm != null || profile.weightKg != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (profile.bloodGroup != null) Text(profile.bloodGroup!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                if (profile.heightCm != null) Text('${profile.heightCm} cm', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                if (profile.weightKg != null) Text('${profile.weightKg} kg', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.count, required this.label});

  final IconData icon;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 4),
          Text('$count $label', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onUpload, required this.onLogVitals});

  final VoidCallback onUpload;
  final VoidCallback onLogVitals;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickAction(icon: Icons.upload_file_outlined, label: 'Upload\nRecords', onTap: onUpload)),
        const SizedBox(width: 8),
        Expanded(child: _QuickAction(icon: Icons.favorite_border_rounded, label: 'Log\nVitals', onTap: onLogVitals)),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_today_outlined,
            label: 'Appointment\nBookings',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DepartmentsScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, height: 1.2)),
          ],
        ),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({required this.latest});

  final Vital? latest;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const VitalsHistoryScreen()),
      ),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Health Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 14),
          if (latest == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('No vitals logged yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            )
          else ...[
            Row(
              children: [
                Expanded(child: _VitalStat(label: 'Heart Rate', value: latest!.heartRateBpm != null ? '${latest!.heartRateBpm} bpm' : '—')),
                Expanded(child: _VitalStat(label: 'Blood Pressure', value: latest!.bloodPressureLabel ?? '—')),
                Expanded(child: _VitalStat(label: 'SpO2', value: latest!.spo2Percentage != null ? '${latest!.spo2Percentage}%' : '—')),
                Expanded(child: _VitalStat(label: 'Temperature', value: latest!.temperatureFahrenheit != null ? '${latest!.temperatureFahrenheit}°F' : '—')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Last updated on ${DateFormat('dd MMM yyyy, hh:mm a').format(latest!.recordedAt)}',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
      ),
    );
  }
}

class _VitalStat extends StatelessWidget {
  const _VitalStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }
}

const _typeLabels = {
  'lab_report': 'Lab Test Reports',
  'medical_document': 'Medical Documents',
  'vaccination': 'Vaccination Records',
  'checkup': 'Health Checkups',
  'prescription': 'Prescriptions',
};

class _RecordTypeGroup extends StatelessWidget {
  const _RecordTypeGroup({required this.type, required this.items});

  final String type;
  final List<HealthRecordItem> items;

  @override
  Widget build(BuildContext context) {
    final mostRecent = items.first;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RecordsListScreen(type: type, typeLabel: _typeLabels[type] ?? type)),
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(8)),
        child: Icon(_iconFor(type), color: AppColors.primary, size: 18),
      ),
      title: Text(_typeLabels[type] ?? type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      subtitle: Text('${items.length} ${items.length == 1 ? 'record' : 'records'}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      trailing: Text(DateFormat('dd MMM yyyy').format(mostRecent.recordDate), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'lab_report':
        return Icons.science_outlined;
      case 'medical_document':
        return Icons.folder_outlined;
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'checkup':
        return Icons.monitor_heart_outlined;
      case 'prescription':
        return Icons.receipt_long_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _LogVitalsSheet extends StatefulWidget {
  const _LogVitalsSheet();

  @override
  State<_LogVitalsSheet> createState() => _LogVitalsSheetState();
}

class _LogVitalsSheetState extends State<_LogVitalsSheet> {
  final _heartRate = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _spo2 = TextEditingController();
  final _temp = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _heartRate.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    _spo2.dispose();
    _temp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    final success = await context.read<HealthProvider>().recordVitals(
          heartRateBpm: int.tryParse(_heartRate.text),
          bloodPressureSystolic: int.tryParse(_systolic.text),
          bloodPressureDiastolic: int.tryParse(_diastolic.text),
          spo2Percentage: int.tryParse(_spo2.text),
          temperatureFahrenheit: double.tryParse(_temp.text),
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
    } else {
      final error = context.read<HealthProvider>().errorMessage;
      if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Self-reported - fill in whichever readings you have.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          TextField(controller: _heartRate, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Heart rate (bpm)')),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: TextField(controller: _systolic, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BP Systolic'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _diastolic, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BP Diastolic'))),
            ],
          ),
          const SizedBox(height: 10),
          TextField(controller: _spo2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'SpO2 (%)')),
          const SizedBox(height: 10),
          TextField(controller: _temp, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Temperature (°F)')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _UploadRecordSheet extends StatefulWidget {
  const _UploadRecordSheet();

  @override
  State<_UploadRecordSheet> createState() => _UploadRecordSheetState();
}

class _UploadRecordSheetState extends State<_UploadRecordSheet> {
  final _title = TextEditingController();
  String _type = 'lab_report';
  DateTime _date = DateTime.now();
  String? _filePath;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _filePath = picked.path);
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a title')));
      return;
    }

    setState(() => _submitting = true);

    final success = await context.read<HealthProvider>().uploadRecord(
          type: _type,
          title: _title.text.trim(),
          recordDate: DateFormat('yyyy-MM-dd').format(_date),
          filePath: _filePath,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
    } else {
      final error = context.read<HealthProvider>().errorMessage;
      if (error != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload Health Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: _typeLabels.entries
                .where((e) => e.key != 'prescription')
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (value) => setState(() => _type = value ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Date: ${DateFormat('dd MMM yyyy').format(_date)}'),
            trailing: const Icon(Icons.calendar_today_outlined, size: 18),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 6),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.attach_file_outlined, size: 18),
            label: Text(_filePath != null ? 'File attached' : 'Attach a file (optional)'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Save'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
