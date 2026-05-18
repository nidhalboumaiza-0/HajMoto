import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';

/// Sale Repository Interface - Domain Layer
/// Handles sales transactions, client management, and invoice generation
/// Uses transactions to ensure atomicity (sale + stock update)
abstract class SaleRepository {
  /// Create a new single-line sale with automatic stock update.
  /// Called once per item when processing a multi-item invoice.
  Future<Either<Failure, SaleEntity>> createSale({
    required String productId,
    required int quantity,
    required double sellingPrice,
    required double purchasePrice,
    required String referenceCode,
    required String productName,
    String? clientId,
  });

  /// Get all sales with optional date filtering
  Future<Either<Failure, List<SaleEntity>>> getSales({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get sale by ID
  Future<Either<Failure, SaleEntity>> getSaleById(String id);

  // === Client Management ===

  /// Create or get existing client
  Future<Either<Failure, ClientEntity>> createClient(ClientEntity client);

  /// Get client by CIN (national ID)
  Future<Either<Failure, ClientEntity?>> getClientByCin(String cin);

  /// Get all clients
  Future<Either<Failure, List<ClientEntity>>> getClients();

  // === Invoice Management ===

  /// Create a multi-item invoice for a complete sale session.
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required List<InvoiceItemEntity> items,
    required ClientEntity client,
    required double totalWithoutTVA,
    required double tvaAmount,
    required double totalWithTVA,
  });

  /// Get invoice by ID
  Future<Either<Failure, InvoiceEntity>> getInvoiceById(String id);

  /// Get invoices for a client
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByClient(String clientId);

  /// Get all invoices
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices();
}
