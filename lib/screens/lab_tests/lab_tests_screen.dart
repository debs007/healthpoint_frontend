import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/error_state.dart';
import '../../models/lab_test.dart';
import '../../providers/lab_test_provider.dart';
import 'book_lab_test_screen.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabTestProvider>().loadTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lab Tests')),
      body: Consumer<LabTestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.tests.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadTests);
          }
          if (provider.tests.isEmpty) {
            return Center(child: Text('No tests available right now.', style: TextStyle(color: AppColors.textMuted)));
          }

          final grouped = <String, List<LabTest>>{};
          for (final test in provider.tests) {
            grouped.putIfAbsent(test.category ?? 'Other', () => []).add(test);
          }

          return RefreshIndicator(
            onRefresh: provider.loadTests,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.expand((entry) => [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    ...entry.value.map((test) => _LabTestTile(test: test)),
                    const SizedBox(height: 8),
                  ]).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _LabTestTile extends StatelessWidget {
  const _LabTestTile({required this.test});

  final LabTest test;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      test.requiresCenterVisit ? Icons.storefront_outlined : Icons.home_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      test.requiresCenterVisit ? 'Center visit' : 'Home visit',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                if (test.sampleType != null) ...[
                  const SizedBox(height: 2),
                  Text(test.sampleType!, style: TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                ],
                const SizedBox(height: 6),
                Text(
                  '${AppConstants.currencySymbol}${test.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookLabTestScreen(test: test)),
            ),
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 36), textStyle: const TextStyle(fontSize: 12)),
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}
