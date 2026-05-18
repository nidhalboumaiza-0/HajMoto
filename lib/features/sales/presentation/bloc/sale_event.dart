import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';

/// Sale BLoC Events
abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Load all sales
class LoadSalesEvent extends SaleEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSalesEvent({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Create a new sale session (multi-item):
/// For each cart item a SaleEntity is created (for stock tracking),
/// then one InvoiceEntity is created covering all items.
class CreateSaleEvent extends SaleEvent {
  /// The list of products/quantities the client is purchasing.
  final List<InvoiceItemEntity> items;
  final String clientFirstName;
  final String clientLastName;
  final String clientMobile;
  final String clientCin;

  const CreateSaleEvent({
    required this.items,
    required this.clientFirstName,
    required this.clientLastName,
    required this.clientMobile,
    required this.clientCin,
  });

  @override
  List<Object?> get props => [
        items,
        clientFirstName,
        clientLastName,
        clientMobile,
        clientCin,
      ];
}

/// Look up client by CIN
class LookupClientEvent extends SaleEvent {
  final String cin;

  const LookupClientEvent(this.cin);

  @override
  List<Object?> get props => [cin];
}

/// Load all invoices
class LoadInvoicesEvent extends SaleEvent {
  const LoadInvoicesEvent();
}

/// Load invoices for a specific client
class LoadClientInvoicesEvent extends SaleEvent {
  final String clientId;

  const LoadClientInvoicesEvent(this.clientId);

  @override
  List<Object?> get props => [clientId];
}
