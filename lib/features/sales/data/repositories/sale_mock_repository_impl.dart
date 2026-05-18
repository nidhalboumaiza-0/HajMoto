import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/sales/data/datasources/sale_mock_datasource.dart';
import 'package:gestion_stock/features/sales/data/models/client_model.dart';
import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';
import 'package:gestion_stock/features/sales/domain/repositories/sale_repository.dart';

/// Mock implementation of [SaleRepository].
/// Delegates to [SaleMockDataSource] — no network/database required.
class SaleMockRepositoryImpl implements SaleRepository {
  final SaleMockDataSource _ds;
  SaleMockRepositoryImpl(this._ds);

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
      final result = await _ds.createSale(
        productId: productId,
        clientId: clientId,
        referenceCode: referenceCode,
        productName: productName,
        quantity: quantity,
        sellingPrice: sellingPrice,
        purchasePrice: purchasePrice,
        tvaRate: AppConstants.tvaRate,
      );
      return Right(result);
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
      return Right(await _ds.getSales(startDate: startDate, endDate: endDate));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SaleEntity>> getSaleById(String id) async {
    try {
      return Right(await _ds.getSaleById(id));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientEntity>> createClient(
      ClientEntity client) async {
    try {
      final model = ClientModel.fromEntity(client);
      final result = await _ds.createClient(
        firstName: model.firstName,
        lastName: model.lastName,
        mobileNumber: model.mobileNumber,
        cin: model.cin,
      );
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ClientEntity?>> getClientByCin(String cin) async {
    try {
      return Right(await _ds.getClientByCin(cin));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ClientEntity>>> getClients() async {
    try {
      return Right(await _ds.getClients());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> createInvoice({
    required List<InvoiceItemEntity> items,
    required ClientEntity client,
    required double totalWithoutTVA,
    required double tvaAmount,
    required double totalWithTVA,
  }) async {
    try {
      final clientModel = ClientModel.fromEntity(client);
      final result = await _ds.createInvoice(
        items: items,
        client: clientModel,
        totalWithoutTVA: totalWithoutTVA,
        tvaAmount: tvaAmount,
        totalWithTVA: totalWithTVA,
      );
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvoiceEntity>> getInvoiceById(String id) async {
    try {
      final all = await _ds.getAllInvoices();
      final inv = all.firstWhere((i) => i.id == id);
      return Right(inv);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getInvoicesByClient(
      String clientId) async {
    try {
      return Right(await _ds.getInvoicesByClient(clientId));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceEntity>>> getAllInvoices() async {
    try {
      return Right(await _ds.getAllInvoices());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
