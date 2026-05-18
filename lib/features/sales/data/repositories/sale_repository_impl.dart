import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/exceptions.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/sales/data/datasources/sale_remote_datasource.dart';
import 'package:gestion_stock/features/sales/data/models/sale_model.dart';
import 'package:gestion_stock/features/sales/data/models/client_model.dart';
import 'package:gestion_stock/features/sales/data/models/invoice_model.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';
import 'package:gestion_stock/features/sales/domain/repositories/sale_repository.dart';

/// Sale Repository Implementation - Data Layer
/// Handles TVA calculations and atomic sale + stock operations
class SaleRepositoryImpl implements SaleRepository {
  final SaleRemoteDataSource remoteDataSource;
  final Uuid _uuid = const Uuid();

  SaleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, SaleEntity>> createSale({
    required String productId,
    required int quantity,
    required double sellingPrice,
    required double purchasePrice,
    required String referenceCode,
    required String productName,
    String? clientId,
  }) async {
    try {
      // Calculate TVA amounts
      final totalWithoutTVA = sellingPrice * quantity;
      final tvaAmount = totalWithoutTVA * AppConstants.tvaRate;
      final totalWithTVA = totalWithoutTVA + tvaAmount;

      final sale = SaleModel(
        id: '',
        productId: productId,
        clientId: clientId,
        referenceCode: referenceCode,
        productName: productName,
        quantity: quantity,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        totalWithoutTVA: totalWithoutTVA,
        tvaAmount: tvaAmount,
        totalWithTVA: totalWithTVA,
        createdAt: DateTime.now(),
      );

      // This handles both sale creation and stock update atomically
      final result = await remoteDataSource.createSale(sale);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SaleEntity>>> getSales({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await remoteDataSource.getSales(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(sales);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SaleEntity>> getSaleById(String id) async {
    try {
      final sale = await remoteDataSource.getSaleById(id);
      return Right(sale);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // === Clients ===

  @override
  Future<Either<Failure, ClientEntity>> createClient(ClientEntity client) async {
    try {
      final model = ClientModel.fromEntity(client);
      final result = await remoteDataSource.createClient(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientEntity?>> getClientByCin(String cin) async {
    try {
      final client = await remoteDataSource.getClientByCin(cin);
      return Right(client);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getClients() async {
    try {
      final clients = await remoteDataSource.getClients();
      return Right(clients);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // === Invoices ===

  @override
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required List<InvoiceItemEntity> items,
    required ClientEntity client,
    required double totalWithoutTVA,
    required double tvaAmount,
    required double totalWithTVA,
  }) async {
    try {
      final now = DateTime.now();
      final invoiceNumber =
          'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${_uuid.v4().substring(0, 4).toUpperCase()}';

      final invoice = InvoiceModel(
        id: '',
        invoiceNumber: invoiceNumber,
        clientId: client.id,
        clientName: client.fullName,
        clientCin: client.cin,
        clientMobile: client.mobileNumber,
        items: items
            .map((i) => InvoiceItemModel.fromEntity(i))
            .toList(),
        totalWithoutTVA: totalWithoutTVA,
        tvaAmount: tvaAmount,
        totalWithTVA: totalWithTVA,
        createdAt: now,
      );

      final result = await remoteDataSource.createInvoice(invoice);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoiceById(String id) async {
    try {
      final invoice = await remoteDataSource.getInvoiceById(id);
      return Right(invoice);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByClient(String clientId) async {
    try {
      final invoices = await remoteDataSource.getInvoicesByClient(clientId);
      return Right(invoices);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices() async {
    try {
      final invoices = await remoteDataSource.getAllInvoices();
      return Right(invoices);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
