import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/error_state.dart';
import '../../models/department.dart';
import '../../providers/appointment_provider.dart';
import 'doctors_screen.dart';

/// Entry point for the whole Appointments feature - department first,
/// then doctors within it. "All Doctors" is always available too, for
/// anyone who'd rather browse without narrowing by department first.
class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadDepartments();
    });
  }

  static const _icons = [
    Icons.favorite_outline_rounded,
    Icons.healing_outlined,
    Icons.accessibility_new_rounded,
    Icons.child_care_rounded,
    Icons.visibility_outlined,
    Icons.psychology_outlined,
    Icons.medical_services_outlined,
    Icons.local_hospital_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book an Appointment')),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.departments.isEmpty && provider.errorMessage != null) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadDepartments);
          }
          if (provider.departments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Find a Doctor', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Choose a department, or browse all doctors', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              _AllDoctorsCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DoctorsScreen()),
                ),
              ),
              const SizedBox(height: 20),
              Text('Departments', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.departments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemBuilder: (context, i) => _DepartmentCard(
                  department: provider.departments[i],
                  icon: _icons[i % _icons.length],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => DoctorsScreen(department: provider.departments[i])),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AllDoctorsCard extends StatelessWidget {
  const _AllDoctorsCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.groups_2_outlined, color: Colors.white, size: 30),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Browse All Doctors', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('See every doctor across all departments', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DepartmentCard extends StatelessWidget {
  const _DepartmentCard({required this.department, required this.icon, required this.onTap});

  final Department department;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 8),
            Text(department.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
