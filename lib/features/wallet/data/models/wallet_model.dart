import '../../domain/entities/wallet.dart';

class WalletModel extends Wallet {
  const WalletModel({
    required super.userId,
    required super.balance,
    required super.createdAt,
    required super.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Handle nullable fields from Supabase
    final userId = json['user_id'];
    if (userId == null) {
      throw FormatException('user_id cannot be null in wallet data');
    }

    final balance = json['balance'];
    if (balance == null) {
      throw FormatException('balance cannot be null in wallet data');
    }

    // Note: wallets table doesn't have created_at, so we use updated_at for both
    final updatedAtStr = json['updated_at'];
    if (updatedAtStr == null) {
      throw FormatException('updated_at cannot be null in wallet data');
    }

    final updatedAt = DateTime.parse(updatedAtStr as String);

    return WalletModel(
      userId: userId as String,
      balance: balance as int,
      createdAt:
          updatedAt, // Use updated_at as created_at since created_at doesn't exist
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WalletModel.fromEntity(Wallet wallet) {
    return WalletModel(
      userId: wallet.userId,
      balance: wallet.balance,
      createdAt: wallet.createdAt,
      updatedAt: wallet.updatedAt,
    );
  }

  @override
  WalletModel copyWith({
    String? userId,
    int? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
