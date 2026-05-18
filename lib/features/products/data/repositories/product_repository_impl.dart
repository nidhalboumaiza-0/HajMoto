import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/exceptions.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/products/data/datasources/product_remote_datasource.dart';
import 'package:gestion_stock/features/products/data/models/product_model.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';
import 'package:gestion_stock/features/products/domain/repositories/product_repository.dart';

/// Product Repository Implementation - Data Layer
/// Implements the domain's ProductRepository interface
/// Handles error mapping from exceptions to failures
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        category: category,
        searchQuery: searchQuery,
      );
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductByReference(String referenceCode) async {
    try {
      final product = await remoteDataSource.getProductByReference(referenceCode);
      return Right(product);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final result = await remoteDataSource.addProduct(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product) async {
    try {
      final model = ProductModel.fromEntity(product);
      final result = await remoteDataSource.updateProduct(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await remoteDataSource.deleteProduct(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> importProductsFromCsv(List<Map<String, dynamic>> csvData) async {
    try {
      final now = DateTime.now();
      final products = csvData.map((data) {
        return ProductModel(
          id: '',
          referenceCode: data['referenceCode'] as String? ?? '',
          name: data['name'] as String? ?? '',
          categories: [data['category'] as String? ?? 'vespa_parts'],
          purchasePrice: double.tryParse(data['purchasePrice']?.toString() ?? '0') ?? 0,
          sellingPrice: double.tryParse(data['sellingPrice']?.toString() ?? '0') ?? 0,
          quantity: int.tryParse(data['quantity']?.toString() ?? '0') ?? 0,
          createdAt: now,
          updatedAt: now,
        );
      }).toList();

      final count = await remoteDataSource.bulkInsertProducts(products);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ImportFailure(message: e.message));
    } catch (e) {
      return Left(ImportFailure(message: 'CSV import failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts() async {
    try {
      final products = await remoteDataSource.getLowStockProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getOutOfStockProducts() async {
    try {
      final products = await remoteDataSource.getOutOfStockProducts();
      return Right(products);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateStock(String productId, int newQuantity) async {
    try {
      await remoteDataSource.updateStock(productId, newQuantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(StockFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
