import 'package:equatable/equatable.dart';

enum WalletTransactionType { topup, purchase, refund }

enum WalletTransactionStatus { pending, success, failed }

class WalletTransaction extends Equatable {
  final String id;
  final String userId;
  final int amount; // Amount in smallest currency unit (fils)
  final WalletTransactionType type;
  final String? provider; // e.g., 'zaincash'
  final String? providerReference; // Provider's transaction reference
  final WalletTransactionStatus status;
  final Map<String, dynamic>? metadata; // Additional transaction data
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    this.provider,
    this.providerReference,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get amount in dinars (amount / 1000)
  double get amountInDinars => amount / 1000.0;

  /// Get formatted amount string in dinars
  String get formattedAmount => '${amountInDinars.toStringAsFixed(3)} د.ع';

  /// Get transaction type display name in Arabic
  String get typeDisplayName {
    switch (type) {
      case WalletTransactionType.topup:
        return 'شحن المحفظة';
      case WalletTransactionType.purchase:
        return 'شراء';
      case WalletTransactionType.refund:
        return 'استرداد';
    }
  }

  /// Get transaction status display name in Arabic
  String get statusDisplayName {
    switch (status) {
      case WalletTransactionStatus.pending:
        return 'قيد الانتظار';
      case WalletTransactionStatus.success:
        return 'مكتمل';
      case WalletTransactionStatus.failed:
        return 'فاشل';
    }
  }

  /// Check if transaction is positive (adds to balance)
  bool get isPositive => type == WalletTransactionType.topup || type == WalletTransactionType.refund;

  WalletTransaction copyWith({
    String? id,
    String? userId,
    int? amount,
    WalletTransactionType? type,
    String? provider,
    String? providerReference,
    WalletTransactionStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      providerReference: providerReference ?? this.providerReference,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        type,
        provider,
        providerReference,
        status,
        metadata,
        createdAt,
        updatedAt,
      ];
}
