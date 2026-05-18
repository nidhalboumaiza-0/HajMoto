import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';

/// Product Repository Interface - Domain Layer
/// Defines the contract for product data operations
/// Following dependency inversion: domain depends on abstractions, not implementations
abstract class ProductRepository {
  /// Get all products with optional filtering by category slug and search query
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    String? category,
    String? searchQuery,
  });

  /// Get a single product by ID
  Future<Either<Failure, ProductEntity>> getProductById(String id);

  /// Get product by reference code (for sales lookup)
  Future<Either<Failure, ProductEntity>> getProductByReference(String referenceCode);

  /// Add a new product
  Future<Either<Failure, ProductEntity>> addProduct(ProductEntity product);

  /// Update an existing product
  Future<Either<Failure, ProductEntity>> updateProduct(ProductEntity product);

  /// Delete a product by ID
  Future<Either<Failure, void>> deleteProduct(String id);

  /// Import products from CSV data
  Future<Either<Failure, int>> importProductsFromCsv(List<Map<String, dynamic>> csvData);

  /// Get low stock products (quantity <= threshold)
  Future<Either<Failure, List<ProductEntity>>> getLowStockProducts();

  /// Get out of stock products (quantity == 0)
  Future<Either<Failure, List<ProductEntity>>> getOutOfStockProducts();

  /// Update product stock quantity
  Future<Either<Failure, void>> updateStock(String productId, int newQuantity);
}
