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
      final provider = context.read<LabTestProvider>();
      // A stale selection from a previous visit shouldn't silently
      // carry over into a fresh trip to this screen.
      provider.clearSelection();
      provider.loadTests();
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

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadTests,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, provider.selectedTestIds.isEmpty ? 16 : 90),
                    children: grouped.entries.expand((entry) => [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 8),
                            child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          ...entry.value.map((test) => _LabTestTile(
                                test: test,
                                selected: provider.selectedTestIds.contains(test.id),
                                onToggle: () => provider.toggleTestSelection(test.id),
                              )),
                          const SizedBox(height: 8),
                        ]).toList(),
                  ),
                ),
              ),
              if (provider.selectedTestIds.isNotEmpty)
                SafeArea(
                  top: false,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => BookLabTestScreen(tests: provider.selectedTests)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      color: AppColors.primary,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '${provider.selectedTestIds.length}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            provider.selectedTestIds.length == 1 ? 'Test selected' : 'Tests selected',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          const Spacer(),
                          const Text('Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
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

class _LabTestTile extends StatelessWidget {
  const _LabTestTile({required this.test, required this.selected, required this.onToggle});

  final LabTest test;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : null,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
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
            Checkbox(value: selected, onChanged: (_) => onToggle()),
          ],
        ),
      ),
    );
  }
}
