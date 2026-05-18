import 'package:equatable/equatable.dart';

/// Represents a single line item within an invoice.
/// One invoice can contain many InvoiceItemEntity items.
class InvoiceItemEntity extends Equatable {
  final String productId;
  final String referenceCode;
  final String productName;
  final int quantity;
  final double unitPrice;     // selling price per unit
  final double purchasePrice; // for profit calculation; not printed on invoice

  const InvoiceItemEntity({
    required this.productId,
    required this.referenceCode,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasePrice,
  });

  /// Line total before TVA: quantity × unitPrice
  double get lineTotalHT => quantity * unitPrice;

  @override
  List<Object?> get props => [
        productId,
        referenceCode,
        productName,
        quantity,
        unitPrice,
        purchasePrice,
      ];
}
