import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/error_state.dart';
import '../../models/wallet.dart';
import '../../providers/wallet_provider.dart';
import '../payment/payment_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadWallet();
    });
  }

  Future<void> _showTopupSheet(BuildContext context) async {
    final controller = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Top up your Susthayan Wallet', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '${AppConstants.currencySymbol} ',
                hintText: 'Enter amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [100, 200, 500, 1000].map((preset) {
                return OutlinedButton(
                  onPressed: () => controller.text = preset.toString(),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 32), padding: const EdgeInsets.symmetric(horizontal: 12)),
                  child: Text('${AppConstants.currencySymbol}$preset', style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Consumer<WalletProvider>(
              builder: (context, provider, _) => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.isToppingUp
                      ? null
                      : () async {
                          final amount = double.tryParse(controller.text.trim());
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(content: Text('Enter a valid amount')),
                            );
                            return;
                          }

                          final order = await provider.topup(amount);
                          if (!sheetContext.mounted) return;

                          if (order != null) {
                            Navigator.pop(sheetContext); // close the sheet first
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PaymentScreen(order: order)),
                            );
                          } else if (provider.errorMessage != null) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(content: Text(provider.errorMessage!)),
                            );
                          }
                        },
                  child: provider.isToppingUp
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Proceed to Add Money'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Susthayan Wallet')),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.wallet.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.wallet.balance == 0 && provider.wallet.transactions.isEmpty) {
            return ErrorState(message: provider.errorMessage!, onRetry: provider.loadWallet);
          }

          return RefreshIndicator(
            onRefresh: provider.loadWallet,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Available Balance', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5)),
                      const SizedBox(height: 6),
                      Text(
                        '${AppConstants.currencySymbol}${provider.wallet.balance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showTopupSheet(context),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
                          child: const Text('Add Money'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                if (provider.wallet.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textMuted))),
                  )
                else
                  ...provider.wallet.transactions.map((t) => _TransactionTile(transaction: t)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: transaction.isCredit ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 16,
              color: transaction.isCredit ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy, hh:mm a').format(transaction.createdAt), style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${transaction.isCredit ? '+' : '-'}${AppConstants.currencySymbol}${transaction.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: transaction.isCredit ? AppColors.success : AppColors.error),
          ),
        ],
      ),
    );
  }
}
