import 'package:equatable/equatable.dart';

/// Sale Entity - Domain Layer
/// Represents a single sale transaction
/// Contains TVA calculation and links to product and client
class SaleEntity extends Equatable {
  final String id;
  final String productId;
  final String? clientId;
  final String referenceCode; // Product reference for display
  final String productName;
  final int quantity;
  final double sellingPrice; // Unit price
  final double purchasePrice; // For profit calculation
  final double totalWithoutTVA;
  final double tvaAmount;
  final double totalWithTVA;
  final DateTime createdAt;

  const SaleEntity({
    required this.id,
    required this.productId,
    this.clientId,
    required this.referenceCode,
    required this.productName,
    required this.quantity,
    required this.sellingPrice,
    required this.purchasePrice,
    required this.totalWithoutTVA,
    required this.tvaAmount,
    required this.totalWithTVA,
    required this.createdAt,
  });

  /// Calculate profit for this sale
  double get profit => totalWithoutTVA - (purchasePrice * quantity);

  @override
  List<Object?> get props => [
        id,
        productId,
        clientId,
        referenceCode,
        productName,
        quantity,
        sellingPrice,
        purchasePrice,
        totalWithoutTVA,
        tvaAmount,
        totalWithTVA,
        createdAt,
      ];
}
