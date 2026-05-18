import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';

/// Sale BLoC States
abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

class SaleInitialState extends SaleState {
  const SaleInitialState();
}

class SaleLoadingState extends SaleState {
  const SaleLoadingState();
}

/// Sales list loaded
class SalesLoadedState extends SaleState {
  final List<SaleEntity> sales;

  const SalesLoadedState(this.sales);

  @override
  List<Object?> get props => [sales];
}

/// Sale created successfully with invoice
class SaleCreatedState extends SaleState {
  final SaleEntity sale;
  final InvoiceEntity invoice;
  final ClientEntity client;

  const SaleCreatedState({
    required this.sale,
    required this.invoice,
    required this.client,
  });

  @override
  List<Object?> get props => [sale, invoice, client];
}

/// Client found during lookup
class ClientFoundState extends SaleState {
  final ClientEntity client;

  const ClientFoundState(this.client);

  @override
  List<Object?> get props => [client];
}

/// Client not found (new client)
class ClientNotFoundState extends SaleState {
  const ClientNotFoundState();
}

/// Invoices loaded
class InvoicesLoadedState extends SaleState {
  final List<InvoiceEntity> invoices;

  const InvoicesLoadedState(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

/// Error state
class SaleErrorState extends SaleState {
  final String message;

  const SaleErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty sales
class SaleEmptyState extends SaleState {
  final String message;

  const SaleEmptyState({this.message = 'No sales found'});

  @override
  List<Object?> get props => [message];
}
