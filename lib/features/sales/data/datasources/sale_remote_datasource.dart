import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/exceptions.dart';
import 'package:gestion_stock/core/network/dio_client.dart';
import 'package:gestion_stock/features/sales/data/models/sale_model.dart';
import 'package:gestion_stock/features/sales/data/models/client_model.dart';
import 'package:gestion_stock/features/sales/data/models/invoice_model.dart';

/// Sale Remote Data Source
/// Handles Supabase REST API communication via Dio for sales, clients, and invoices
class SaleRemoteDataSource {
  final DioClient _client;

  SaleRemoteDataSource(this._client);

  // === Sales ===

  /// Create a sale and update stock
  Future<SaleModel> createSale(SaleModel sale) async {
    try {
      // First, get current stock
      final product = await _client.getById(
        AppConstants.productsTable,
        sale.productId,
      );

      final currentQuantity = product['quantity'] as int;
      final newQuantity = currentQuantity - sale.quantity;

      if (newQuantity < 0) {
        throw const ServerException(message: 'Insufficient stock');
      }

      // Update stock
      await _client.update(
        AppConstants.productsTable,
        sale.productId,
        {
          'quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );

      // Create the sale record
      final response = await _client.insert(
        AppConstants.salesTable,
        sale.toInsertJson(),
      );

      return SaleModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to create sale: ${e.toString()}');
    }
  }

  /// Get sales with optional date filtering
  Future<List<SaleModel>> getSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'order': 'created_at.desc',
      };

      if (startDate != null) {
        params['created_at'] = 'gte.${startDate.toIso8601String()}';
      }
      // If both dates, use and() or chain filters
      if (endDate != null) {
        if (startDate != null) {
          // PostgREST supports multiple filters with and
          params.remove('created_at');
          params['and'] =
              '(created_at.gte.${startDate.toIso8601String()},created_at.lte.${endDate.toIso8601String()})';
        } else {
          params['created_at'] = 'lte.${endDate.toIso8601String()}';
        }
      }

      final response = await _client.getAll(
        AppConstants.salesTable,
        queryParameters: params,
      );
      return response
          .map((json) => SaleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch sales: ${e.toString()}');
    }
  }

  /// Get sale by ID
  Future<SaleModel> getSaleById(String id) async {
    try {
      final response = await _client.getById(AppConstants.salesTable, id);
      return SaleModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Sale not found: ${e.toString()}');
    }
  }

  // === Clients ===

  /// Create a new client
  Future<ClientModel> createClient(ClientModel client) async {
    try {
      final response = await _client.insert(
        AppConstants.clientsTable,
        client.toInsertJson(),
      );
      return ClientModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to create client: ${e.toString()}');
    }
  }

  /// Get client by CIN
  Future<ClientModel?> getClientByCin(String cin) async {
    try {
      final response = await _client.getByColumnOrNull(
        AppConstants.clientsTable,
        'cin',
        cin,
      );
      if (response == null) return null;
      return ClientModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch client: ${e.toString()}');
    }
  }

  /// Get all clients
  Future<List<ClientModel>> getClients() async {
    try {
      final response = await _client.getAll(
        AppConstants.clientsTable,
        queryParameters: {'order': 'created_at.desc'},
      );
      return response
          .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch clients: ${e.toString()}');
    }
  }

  // === Invoices ===

  /// Create invoice
  Future<InvoiceModel> createInvoice(InvoiceModel invoice) async {
    try {
      final response = await _client.insert(
        AppConstants.invoicesTable,
        invoice.toInsertJson(),
      );
      return InvoiceModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to create invoice: ${e.toString()}');
    }
  }

  /// Get invoice by ID
  Future<InvoiceModel> getInvoiceById(String id) async {
    try {
      final response = await _client.getById(AppConstants.invoicesTable, id);
      return InvoiceModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Invoice not found: ${e.toString()}');
    }
  }

  /// Get invoices by client
  Future<List<InvoiceModel>> getInvoicesByClient(String clientId) async {
    try {
      final response = await _client.getAll(
        AppConstants.invoicesTable,
        queryParameters: {
          'client_id': 'eq.$clientId',
          'order': 'created_at.desc',
        },
      );
      return response
          .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch invoices: ${e.toString()}');
    }
  }

  /// Get all invoices
  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      final response = await _client.getAll(
        AppConstants.invoicesTable,
        queryParameters: {'order': 'created_at.desc'},
      );
      return response
          .map((json) => InvoiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch invoices: ${e.toString()}');
    }
  }
}
