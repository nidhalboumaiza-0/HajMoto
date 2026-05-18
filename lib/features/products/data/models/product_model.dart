import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';

/// Product Model - Data Layer
/// Extends ProductEntity with JSON serialization for Supabase
/// Maps between Supabase database format and domain entity
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.referenceCode,
    required super.name,
    required super.categories,
    required super.purchasePrice,
    required super.sellingPrice,
    required super.quantity,
    super.lowStockThreshold,
    required super.createdAt,
    required super.updatedAt,
    super.imagePaths,
  });

  /// Create from Supabase JSON response
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      referenceCode: json['reference_code'] as String,
      name: json['name'] as String,
      // Support both new 'categories' list and legacy 'category' string
      categories: json['categories'] != null
          ? (json['categories'] as List<dynamic>).map((e) => e as String).toList()
          : json['category'] != null
              ? [json['category'] as String]
              : const ['vespa_parts'],
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int? ?? 5,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      imagePaths: (json['image_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_code': referenceCode,
      'name': name,
      'categories': categories,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_paths': imagePaths,
    };
  }

  /// Convert to JSON without ID (for insert, let Supabase generate ID)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Create from domain entity
  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      referenceCode: entity.referenceCode,
      name: entity.name,
      categories: entity.categories,
      purchasePrice: entity.purchasePrice,
      sellingPrice: entity.sellingPrice,
      quantity: entity.quantity,
      lowStockThreshold: entity.lowStockThreshold,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      imagePaths: entity.imagePaths,
    );
  }

  /// Create a copy with updated fields
  ProductModel copyWith({
    String? id,
    String? referenceCode,
    String? name,
    List<String>? categories,
    double? purchasePrice,
    double? sellingPrice,
    int? quantity,
    int? lowStockThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? imagePaths,
  }) {
    return ProductModel(
      id: id ?? this.id,
      referenceCode: referenceCode ?? this.referenceCode,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }
}
