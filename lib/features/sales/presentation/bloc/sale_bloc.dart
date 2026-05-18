import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';
import 'package:gestion_stock/features/sales/domain/usecases/sale_usecases.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_event.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_state.dart';

/// Sale BLoC - Presentation Layer
/// Manages the complete sale flow:
/// 1. Look up / create client
/// 2. Create sale (with TVA calculation)
/// 3. Generate invoice
/// 4. Stock is updated atomically in the repository
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final CreateSaleUseCase createSaleUseCase;
  final GetSalesUseCase getSalesUseCase;
  final CreateClientUseCase createClientUseCase;
  final GetClientByCinUseCase getClientByCinUseCase;
  final CreateInvoiceUseCase createInvoiceUseCase;
  final GetAllInvoicesUseCase getAllInvoicesUseCase;
  final GetInvoicesByClientUseCase getInvoicesByClientUseCase;

  SaleBloc({
    required this.createSaleUseCase,
    required this.getSalesUseCase,
    required this.createClientUseCase,
    required this.getClientByCinUseCase,
    required this.createInvoiceUseCase,
    required this.getAllInvoicesUseCase,
    required this.getInvoicesByClientUseCase,
  }) : super(const SaleInitialState()) {
    on<LoadSalesEvent>(_onLoadSales);
    on<CreateSaleEvent>(_onCreateSale);
    on<LookupClientEvent>(_onLookupClient);
    on<LoadInvoicesEvent>(_onLoadInvoices);
    on<LoadClientInvoicesEvent>(_onLoadClientInvoices);
  }

  Future<void> _onLoadSales(
    LoadSalesEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoadingState());
    final result = await getSalesUseCase(
      startDate: event.startDate,
      endDate: event.endDate,
    );
    result.fold(
      (failure) => emit(SaleErrorState(failure.message)),
      (sales) {
        if (sales.isEmpty) {
          emit(const SaleEmptyState());
        } else {
          emit(SalesLoadedState(sales));
        }
      },
    );
  }

  Future<void> _onCreateSale(
    CreateSaleEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoadingState());
    try {
      // Step 1: Find or create client
      ClientEntity? client;
      final clientResult = await getClientByCinUseCase(event.clientCin);

      await clientResult.fold(
        (failure) async {
          emit(SaleErrorState(failure.message));
        },
        (existingClient) async {
          if (existingClient != null) {
            client = existingClient;
          } else {
            final newClient = ClientEntity(
              id: '',
              firstName: event.clientFirstName,
              lastName: event.clientLastName,
              mobileNumber: event.clientMobile,
              cin: event.clientCin,
              createdAt: DateTime.now(),
            );
            final createResult = await createClientUseCase(newClient);
            createResult.fold(
              (failure) => emit(SaleErrorState(failure.message)),
              (created) => client = created,
            );
          }
        },
      );

      if (client == null) return;

      // Step 2: Create one SaleEntity per item (updates stock for each product)
      SaleEntity? firstSale;
      for (final item in event.items) {
        final saleResult = await createSaleUseCase(
          productId: item.productId,
          quantity: item.quantity,
          sellingPrice: item.unitPrice,
          purchasePrice: item.purchasePrice,
          referenceCode: item.referenceCode,
          productName: item.productName,
          clientId: client!.id,
        );
        final didFail = saleResult.fold(
          (failure) {
            emit(SaleErrorState(
                'Échec de la vente pour ${item.productName}: ${failure.message}'));
            return true;
          },
          (sale) {
            firstSale ??= sale;
            return false;
          },
        );
        if (didFail) return;
      }

      if (firstSale == null) return;

      // Step 3: Create one invoice grouping all items
      final invoiceResult = await createInvoiceUseCase(
        items: event.items,
        client: client!,
      );

      invoiceResult.fold(
        (failure) => emit(SaleErrorState(
            'Ventes créées mais facture échouée: ${failure.message}')),
        (invoice) => emit(SaleCreatedState(
          sale: firstSale!,
          invoice: invoice,
          client: client!,
        )),
      );
    } catch (e) {
      emit(SaleErrorState('Erreur inattendue: ${e.toString()}'));
    }
  }

  Future<void> _onLookupClient(
    LookupClientEvent event,
    Emitter<SaleState> emit,
  ) async {
    final result = await getClientByCinUseCase(event.cin);
    result.fold(
      (failure) => emit(SaleErrorState(failure.message)),
      (client) {
        if (client != null) {
          emit(ClientFoundState(client));
        } else {
          emit(const ClientNotFoundState());
        }
      },
    );
  }

  Future<void> _onLoadInvoices(
    LoadInvoicesEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoadingState());
    final result = await getAllInvoicesUseCase();
    result.fold(
      (failure) => emit(SaleErrorState(failure.message)),
      (invoices) => emit(InvoicesLoadedState(invoices)),
    );
  }

  Future<void> _onLoadClientInvoices(
    LoadClientInvoicesEvent event,
    Emitter<SaleState> emit,
  ) async {
    emit(const SaleLoadingState());
    final result = await getInvoicesByClientUseCase(event.clientId);
    result.fold(
      (failure) => emit(SaleErrorState(failure.message)),
      (invoices) => emit(InvoicesLoadedState(invoices)),
    );
  }
}
