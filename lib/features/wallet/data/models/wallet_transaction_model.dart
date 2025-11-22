import '../../domain/entities/wallet_transaction.dart';

class WalletTransactionModel extends WalletTransaction {
  const WalletTransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    super.provider,
    super.providerReference,
    required super.status,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    // Handle nullable fields from Supabase
    final id = json['id'];
    if (id == null) {
      throw FormatException('id cannot be null in transaction data');
    }

    final userId = json['user_id'];
    if (userId == null) {
      throw FormatException('user_id cannot be null in transaction data');
    }

    final amount = json['amount'];
    if (amount == null) {
      throw FormatException('amount cannot be null in transaction data');
    } 

    final typeStr = json['type'];
    if (typeStr == null) {
      throw FormatException('type cannot be null in transaction data');
    }

    final statusStr = json['status'];
    if (statusStr == null) {
      throw FormatException('status cannot be null in transaction data');
    }

    final createdAtStr = json['created_at'];
    if (createdAtStr == null) {
      throw FormatException('created_at cannot be null in transaction data');
    }

    final updatedAtStr = json['updated_at'];
    if (updatedAtStr == null) {
      throw FormatException('updated_at cannot be null in transaction data');
    }

    return WalletTransactionModel(
      id: id as String,
      userId: userId as String,
      amount: amount as int,
      type: _parseTransactionType(typeStr as String),
      provider: json['provider'] as String?,
      providerReference: json['provider_reference'] as String?,
      status: _parseTransactionStatus(statusStr as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(createdAtStr as String),
      updatedAt: DateTime.parse(updatedAtStr as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'type': _transactionTypeToString(type),
      'provider': provider,
      'provider_reference': providerReference,
      'status': _transactionStatusToString(status),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WalletTransactionModel.fromEntity(WalletTransaction transaction) {
    return WalletTransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      amount: transaction.amount,
      type: transaction.type,
      provider: transaction.provider,
      providerReference: transaction.providerReference,
      status: transaction.status,
      metadata: transaction.metadata,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  static WalletTransactionType _parseTransactionType(String type) {
    switch (type) {
      case 'topup':
        return WalletTransactionType.topup;
      case 'purchase':
        return WalletTransactionType.purchase;
      case 'refund':
        return WalletTransactionType.refund;
      default:
        throw ArgumentError('Unknown transaction type: $type');
    }
  }

  static String _transactionTypeToString(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topup:
        return 'topup';
      case WalletTransactionType.purchase:
        return 'purchase';
      case WalletTransactionType.refund:
        return 'refund';
    }
  }

  static WalletTransactionStatus _parseTransactionStatus(String status) {
    switch (status) {
      case 'pending':
        return WalletTransactionStatus.pending;
      case 'success':
        return WalletTransactionStatus.success;
      case 'failed':
        return WalletTransactionStatus.failed;
      default:
        throw ArgumentError('Unknown transaction status: $status');
    }
  }

  static String _transactionStatusToString(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.pending:
        return 'pending';
      case WalletTransactionStatus.success:
        return 'success';
      case WalletTransactionStatus.failed:
        return 'failed';
    }
  }

  @override
  WalletTransactionModel copyWith({
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
    return WalletTransactionModel(
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
}
