import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';

/// Invoice Entity - Domain Layer
/// Represents a multi-item invoice generated for a client after a sale session.
/// One invoice can contain multiple InvoiceItemEntity line items.
class InvoiceEntity extends Equatable {
  final String id;
  final String invoiceNumber;
  final String clientId;
  final String clientName;
  final String clientCin;
  final String clientMobile;

  /// Line items purchased in this invoice (one per product)
  final List<InvoiceItemEntity> items;

  final double totalWithoutTVA;
  final double tvaAmount;
  final double totalWithTVA;
  final DateTime createdAt;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    required this.clientName,
    required this.clientCin,
    required this.clientMobile,
    required this.items,
    required this.totalWithoutTVA,
    required this.tvaAmount,
    required this.totalWithTVA,
    required this.createdAt,
  });

  /// Total number of units across all line items
  int get totalQuantity => items.fold(0, (s, i) => s + i.quantity);

  /// One-line summary for display in table rows
  String get itemsSummary {
    if (items.isEmpty) return '-';
    if (items.length == 1) return items.first.productName;
    return '${items.length} articles';
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        clientId,
        clientName,
        clientCin,
        clientMobile,
        items,
        totalWithoutTVA,
        tvaAmount,
        totalWithTVA,
        createdAt,
      ];
}
