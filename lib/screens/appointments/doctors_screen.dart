import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/error_state.dart';
import '../../models/department.dart';
import '../../models/doctor.dart';
import '../../providers/appointment_provider.dart';
import 'doctor_detail_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key, this.department});

  final Department? department;

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadDoctors(departmentId: widget.department?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.department?.name ?? 'All Doctors')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.doctors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.doctors.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: () => provider.loadDoctors(departmentId: widget.department?.id));
          }
          if (provider.doctors.isEmpty) {
            return Center(child: Text('No doctors available here right now.', style: TextStyle(color: AppColors.textMuted)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDoctors(departmentId: widget.department?.id),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.doctors.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DoctorTile(doctor: provider.doctors[i]),
            ),
          );
        },
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  const _DoctorTile({required this.doctor});

  final Doctor doctor;

  @override
  Widget build(BuildContext context) {
    final lowestCharge = doctor.hospitals.isEmpty
        ? null
        : doctor.hospitals.map((h) => h.consultationCharge).reduce((a, b) => a < b ? a : b);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => DoctorDetailScreen(doctorId: doctor.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.surfaceTint,
              backgroundImage: doctor.photoUrl != null ? NetworkImage(doctor.photoUrl!) : null,
              child: doctor.photoUrl == null ? Icon(Icons.person, color: AppColors.primary, size: 30) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
                  const SizedBox(height: 2),
                  Text(doctor.degree, style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  if (doctor.department != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(20)),
                      child: Text(doctor.department!, style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.local_hospital_outlined, size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        '${doctor.hospitals.length} ${doctor.hospitals.length == 1 ? 'hospital' : 'hospitals'}',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                      if (lowestCharge != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          'From ${AppConstants.currencySymbol}${lowestCharge.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.success),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
