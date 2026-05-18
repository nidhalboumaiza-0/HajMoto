import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';

// ─── InvoiceItemModel ─────────────────────────────────────────────────────────

/// Data model for a single invoice line item.
class InvoiceItemModel extends InvoiceItemEntity {
  const InvoiceItemModel({
    required super.productId,
    required super.referenceCode,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.purchasePrice,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      productId: json['product_id'] as String? ?? '',
      referenceCode: json['reference_code'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'reference_code': referenceCode,
        'product_name': productName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'purchase_price': purchasePrice,
      };

  factory InvoiceItemModel.fromEntity(InvoiceItemEntity e) => InvoiceItemModel(
        productId: e.productId,
        referenceCode: e.referenceCode,
        productName: e.productName,
        quantity: e.quantity,
        unitPrice: e.unitPrice,
        purchasePrice: e.purchasePrice,
      );
}

// ─── InvoiceModel ─────────────────────────────────────────────────────────────

/// Invoice Model - Data Layer
/// Stores items as a JSON array under the 'items' key.
class InvoiceModel extends InvoiceEntity {
  const InvoiceModel({
    required super.id,
    required super.invoiceNumber,
    required super.clientId,
    required super.clientName,
    required super.clientCin,
    required super.clientMobile,
    required super.items,
    required super.totalWithoutTVA,
    required super.tvaAmount,
    required super.totalWithTVA,
    required super.createdAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final items = rawItems != null
        ? rawItems
            .map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : _legacyItem(json);

    return InvoiceModel(
      id: json['id'] as String,
      invoiceNumber: json['invoice_number'] as String,
      clientId: json['client_id'] as String,
      clientName: json['client_name'] as String,
      clientCin: json['client_cin'] as String,
      clientMobile: json['client_mobile'] as String,
      items: items,
      totalWithoutTVA: (json['total_without_tva'] as num).toDouble(),
      tvaAmount: (json['tva_amount'] as num).toDouble(),
      totalWithTVA: (json['total_with_tva'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Backward-compat shim: build a 1-item list from old flat JSON fields.
  static List<InvoiceItemModel> _legacyItem(Map<String, dynamic> json) => [
        InvoiceItemModel(
          productId: json['product_id'] as String? ?? '',
          referenceCode: json['reference_code'] as String? ?? '',
          productName: json['product_name'] as String? ?? '',
          quantity: json['quantity'] as int? ?? 1,
          unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
          purchasePrice: 0.0,
        ),
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_number': invoiceNumber,
        'client_id': clientId,
        'client_name': clientName,
        'client_cin': clientCin,
        'client_mobile': clientMobile,
        'items': items.map((i) => InvoiceItemModel.fromEntity(i).toJson()).toList(),
        'total_without_tva': totalWithoutTVA,
        'tva_amount': tvaAmount,
        'total_with_tva': totalWithTVA,
        'created_at': createdAt.toIso8601String(),
      };

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
