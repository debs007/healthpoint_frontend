import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/doctor.dart';
import '../../models/doctor_hospital_affiliation.dart';
import '../../providers/appointment_provider.dart';
import 'book_appointment_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final int doctorId;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  Doctor? _doctor;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final doctor = await context.read<AppointmentProvider>().loadDoctor(widget.doctorId);
    if (!mounted) return;
    setState(() {
      _doctor = doctor;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final doctor = _doctor;
    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.watch<AppointmentProvider>().errorMessage ?? 'Couldn\'t load this doctor.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: _load, child: const Text('Try again')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white,
                        backgroundImage: doctor.photoUrl != null ? NetworkImage(doctor.photoUrl!) : null,
                        child: doctor.photoUrl == null ? Icon(Icons.person, color: AppColors.primary, size: 46) : null,
                      ),
                      const SizedBox(height: 12),
                      Text(doctor.name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(doctor.degree, style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
                      if (doctor.department != null || doctor.yearsOfExperience != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (doctor.department != null) _HeaderChip(text: doctor.department!),
                            if (doctor.department != null && doctor.yearsOfExperience != null) const SizedBox(width: 8),
                            if (doctor.yearsOfExperience != null) _HeaderChip(text: '${doctor.yearsOfExperience} yrs experience'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(doctor.bio!, style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.5)),
                    const Divider(height: 32),
                  ],
                  Text('Available at ${doctor.hospitals.length} ${doctor.hospitals.length == 1 ? 'Hospital' : 'Hospitals'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 12),
                  ...doctor.hospitals.map((affiliation) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HospitalCard(doctor: doctor, affiliation: affiliation),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.doctor, required this.affiliation});

  final Doctor doctor;
  final DoctorHospitalAffiliation affiliation;

  static const _dayAbbreviations = {
    'monday': 'Mon', 'tuesday': 'Tue', 'wednesday': 'Wed', 'thursday': 'Thu',
    'friday': 'Fri', 'saturday': 'Sat', 'sunday': 'Sun',
  };

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
              Icon(Icons.local_hospital_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(affiliation.hospitalName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5))),
              Text(
                '${AppConstants.currencySymbol}${affiliation.consultationCharge.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(child: Text(affiliation.hospitalAddress, style: TextStyle(fontSize: 12, color: AppColors.textMuted))),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: affiliation.visitDays.map((day) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.surfaceTint, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  '${_dayAbbreviations[day.dayOfWeek] ?? day.dayOfWeek} ${day.startTime}-${day.endTime}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: affiliation.visitDays.isEmpty
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BookAppointmentScreen(doctor: doctor, affiliation: affiliation)),
                      ),
              child: const Text('Book Appointment'),
            ),
          ),
        ],
      ),
    );
  }
}
