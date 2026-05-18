import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';
import 'package:gestion_stock/features/sales/domain/repositories/sale_repository.dart';

/// Create Sale Use Case
/// Handles the single-line sale flow: create sale + update stock atomically.
/// Called once per cart item.
class CreateSaleUseCase {
  final SaleRepository repository;

  CreateSaleUseCase(this.repository);

  Future<Either<Failure, SaleEntity>> call({
    required String productId,
    required int quantity,
    required double sellingPrice,
    required double purchasePrice,
    required String referenceCode,
    required String productName,
    String? clientId,
  }) {
    return repository.createSale(
      productId: productId,
      quantity: quantity,
      sellingPrice: sellingPrice,
      purchasePrice: purchasePrice,
      referenceCode: referenceCode,
      productName: productName,
      clientId: clientId,
    );
  }
}


/// Get Sales Use Case
class GetSalesUseCase {
  final SaleRepository repository;

  GetSalesUseCase(this.repository);

  Future<Either<Failure, List<SaleEntity>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return repository.getSales(startDate: startDate, endDate: endDate);
  }
}

/// Create Client Use Case
class CreateClientUseCase {
  final SaleRepository repository;

  CreateClientUseCase(this.repository);

  Future<Either<Failure, ClientEntity>> call(ClientEntity client) {
    return repository.createClient(client);
  }
}

/// Get Client By CIN Use Case
class GetClientByCinUseCase {
  final SaleRepository repository;

  GetClientByCinUseCase(this.repository);

  Future<Either<Failure, ClientEntity?>> call(String cin) {
    return repository.getClientByCin(cin);
  }
}

/// Create Invoice Use Case
/// Accepts a list of InvoiceItemEntity items and a client,
/// computes totals, and delegates to the repository.
class CreateInvoiceUseCase {
  final SaleRepository repository;

  CreateInvoiceUseCase(this.repository);

  Future<Either<Failure, InvoiceEntity>> call({
    required List<InvoiceItemEntity> items,
    required ClientEntity client,
  }) {
    final totalHT = items.fold<double>(0.0, (s, i) => s + i.lineTotalHT);
    final tva = totalHT * AppConstants.tvaRate;
    return repository.createInvoice(
      items: items,
      client: client,
      totalWithoutTVA: totalHT,
      tvaAmount: tva,
      totalWithTVA: totalHT + tva,
    );
  }
}


/// Get All Invoices Use Case
class GetAllInvoicesUseCase {
  final SaleRepository repository;

  GetAllInvoicesUseCase(this.repository);

  Future<Either<Failure, List<InvoiceEntity>>> call() {
    return repository.getAllInvoices();
  }
}

/// Get Invoices By Client Use Case
class GetInvoicesByClientUseCase {
  final SaleRepository repository;

  GetInvoicesByClientUseCase(this.repository);

  Future<Either<Failure, List<InvoiceEntity>>> call(String clientId) {
    return repository.getInvoicesByClient(clientId);
  }
}
