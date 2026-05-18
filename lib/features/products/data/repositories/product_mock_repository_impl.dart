import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/products/data/datasources/product_mock_datasource.dart';
import 'package:gestion_stock/features/products/data/models/product_model.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';
import 'package:gestion_stock/features/products/domain/repositories/product_repository.dart';

/// Mock implementation of [ProductRepository].
/// Delegates to [ProductMockDataSource] — no network/database required.
class ProductMockRepositoryImpl implements ProductRepository {
  final ProductMockDataSource _ds;
  ProductMockRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final result = await _ds.getProducts(
          category: category, searchQuery: searchQuery);
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      return Right(await _ds.getProductById(id));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductByReference(
      String referenceCode) async {
    try {
      return Right(await _ds.getProductByReference(referenceCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(
      ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return Right(await _ds.addProduct(model));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(
      ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      return Right(await _ds.updateProduct(model));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _ds.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> importProductsFromCsv(
      List<Map<String, dynamic>> csvData) async {
    try {
      final models = csvData.map((row) {
        return ProductModel(
          id: '',
          referenceCode: row['reference_code']?.toString() ?? '',
          name: row['name']?.toString() ?? '',
          categories: [row['category']?.toString() ?? 'vespa_parts'],
          purchasePrice: double.tryParse(row['purchase_price']?.toString() ?? '0') ?? 0,
          sellingPrice: double.tryParse(row['selling_price']?.toString() ?? '0') ?? 0,
          quantity: int.tryParse(row['quantity']?.toString() ?? '0') ?? 0,
          lowStockThreshold: int.tryParse(row['low_stock_threshold']?.toString() ?? '5') ?? 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
      return Right(await _ds.bulkInsertProducts(models));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts() async {
    try {
      return Right(await _ds.getLowStockProducts());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getOutOfStockProducts() async {
    try {
      return Right(await _ds.getOutOfStockProducts());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(
      String productId, int newQuantity) async {
    try {
      await _ds.updateStock(productId, newQuantity);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
