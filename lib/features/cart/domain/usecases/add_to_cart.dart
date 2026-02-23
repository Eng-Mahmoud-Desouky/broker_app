import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Use case for adding item to cart
class AddToCart implements UseCase<CartItem, AddToCartParams> {
  final CartRepository repository;

  AddToCart(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(AddToCartParams params) async {
    return await repository.addToCart(
      productName: params.productName,
      price: params.price,
      imageUrl: params.imageUrl,
      images: params.images,
      productUrl: params.productUrl,
      platform: params.platform,
      rating: params.rating,
      metadata: params.metadata,
      weightKg: params.weightKg,
      dimensions: params.dimensions,
      rawSpecs: params.rawSpecs,
    );
  }
}

class AddToCartParams extends Equatable {
  final String productName;
  final double price;
  final String? imageUrl;
  final List<String>? images;
  final String productUrl;
  final String platform;
  final String? rating;
  final Map<String, dynamic>? metadata;
  final double? weightKg;
  final Map<String, dynamic>? dimensions;
  final Map<String, dynamic>? rawSpecs;

  const AddToCartParams({
    required this.productName,
    required this.price,
    this.imageUrl,
    this.images,
    required this.productUrl,
    required this.platform,
    this.rating,
    this.metadata,
    this.weightKg,
    this.dimensions,
    this.rawSpecs,
  });

  @override
  List<Object?> get props => [
    productName,
    price,
    imageUrl,
    images,
    productUrl,
    platform,
    rating,
    metadata,
    weightKg,
    dimensions,
    rawSpecs,
  ];
}
