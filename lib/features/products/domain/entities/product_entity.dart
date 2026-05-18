import 'package:equatable/equatable.dart';

/// Product Entity - Domain Layer
/// Represents a product in the shop inventory
/// This is the core business object, independent of any data source
class ProductEntity extends Equatable {
  final String id;
  final String referenceCode;
  final String name;

  /// Category slugs this product belongs to — can be more than one.
  /// Each value matches a CategoryEntity.value, e.g. 'vespa_parts'.
  final List<String> categories;

  final double purchasePrice;
  final double sellingPrice;
  final int quantity;
  final int lowStockThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Up to 3 local file paths or URLs for product images
  final List<String> imagePaths;

  const ProductEntity({
    required this.id,
    required this.referenceCode,
    required this.name,
    required this.categories,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    this.lowStockThreshold = 5,
    required this.createdAt,
    required this.updatedAt,
    this.imagePaths = const [],
  });

  /// Check if product is low on stock
  bool get isLowStock => quantity > 0 && quantity <= lowStockThreshold;

  /// Check if product is out of stock
  bool get isOutOfStock => quantity <= 0;

  /// Check if product is in stock
  bool get isInStock => quantity > 0;

  /// Calculate profit margin per unit
  double get profitMargin => sellingPrice - purchasePrice;

  /// Calculate profit margin percentage
  double get profitMarginPercentage =>
      purchasePrice > 0 ? (profitMargin / purchasePrice) * 100 : 0;

  @override
  List<Object?> get props => [
        id,
        referenceCode,
        name,
        categories,
        purchasePrice,
        sellingPrice,
        quantity,
        lowStockThreshold,
        createdAt,
        updatedAt,
        imagePaths,
      ];
}
