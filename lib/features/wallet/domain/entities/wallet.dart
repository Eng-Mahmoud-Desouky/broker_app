import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String userId;
  final int balance; // Balance in smallest currency unit (fils)
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    required this.userId,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get balance in dinars (balance / 1000)
  double get balanceInDinars => balance / 1000.0;

  /// Get formatted balance string in dinars
  String get formattedBalance => '${balanceInDinars.toStringAsFixed(3)} د.ع';

  Wallet copyWith({
    String? userId,
    int? balance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object> get props => [userId, balance, createdAt, updatedAt];
}
