import 'package:meta/meta.dart'; // For @immutable annotation

enum TransactionType { send, receive }

enum TransactionStatus { pending, completed, failed }

@immutable
class Transaction {
  final String id;
  final String senderId;
  final String receiverId;
  final TransactionType type;
  final double amount;
  final String currency;
  final TransactionStatus status;
  final String? transactionHash;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.transactionHash,
    required this.createdAt,
  })  : assert(id.isNotEmpty),
        assert(senderId.isNotEmpty),
        assert(receiverId.isNotEmpty),
        assert(amount >= 0),
        assert(currency.isNotEmpty);

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      type: _parseTransactionType(json['type']),
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      status: _parseTransactionStatus(json['status']),
      transactionHash: json['transactionHash'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'transactionHash': transactionHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static TransactionType _parseTransactionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'send':
        return TransactionType.send;
      case 'receive':
        return TransactionType.receive;
      default:
        return TransactionType.send; // Default to send if type is not recognized
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending; // Default to pending if status is not recognized
    }
  }
}
