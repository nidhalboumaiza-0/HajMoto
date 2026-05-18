import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';

/// Sale Model - Data Layer
/// Extends SaleEntity with JSON serialization for Supabase
class SaleModel extends SaleEntity {
  const SaleModel({
    required super.id,
    required super.productId,
    super.clientId,
    required super.referenceCode,
    required super.productName,
    required super.quantity,
    required super.sellingPrice,
    required super.purchasePrice,
    required super.totalWithoutTVA,
    required super.tvaAmount,
    required super.totalWithTVA,
    required super.createdAt,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      clientId: json['client_id'] as String?,
      referenceCode: json['reference_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      quantity: json['quantity'] as int,
      sellingPrice: (json['selling_price'] as num).toDouble(),
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      totalWithoutTVA: (json['total_without_tva'] as num).toDouble(),
      tvaAmount: (json['tva_amount'] as num).toDouble(),
      totalWithTVA: (json['total_with_tva'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'client_id': clientId,
      'reference_code': referenceCode,
      'product_name': productName,
      'quantity': quantity,
      'selling_price': sellingPrice,
      'purchase_price': purchasePrice,
      'total_without_tva': totalWithoutTVA,
      'tva_amount': tvaAmount,
      'total_with_tva': totalWithTVA,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  factory SaleModel.fromEntity(SaleEntity entity) {
    return SaleModel(
      id: entity.id,
      productId: entity.productId,
      clientId: entity.clientId,
      referenceCode: entity.referenceCode,
      productName: entity.productName,
      quantity: entity.quantity,
      sellingPrice: entity.sellingPrice,
      purchasePrice: entity.purchasePrice,
      totalWithoutTVA: entity.totalWithoutTVA,
      tvaAmount: entity.tvaAmount,
      totalWithTVA: entity.totalWithTVA,
      createdAt: entity.createdAt,
    );
  }
}
