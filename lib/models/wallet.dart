class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.createdAt,
  });

  final int id;
  final String type; // 'credit' or 'debit'
  final double amount;
  final String description;
  final DateTime createdAt;

  bool get isCredit => type == 'credit';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int,
      type: json['type'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class Wallet {
  const Wallet({required this.balance, this.transactions = const []});

  final double balance;
  final List<WalletTransaction> transactions;

  static const empty = Wallet(balance: 0);

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final transactionsJson = json['transactions'] as List<dynamic>? ?? [];
    return Wallet(
      balance: double.tryParse(json['balance'].toString()) ?? 0,
      transactions: transactionsJson.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
