import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';
import 'package:gestion_stock/features/products/domain/repositories/product_repository.dart';

/// Get Products Use Case
/// Retrieves products with optional filtering by category slug and search query
class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call({
    String? category,
    String? searchQuery,
  }) {
    return repository.getProducts(category: category, searchQuery: searchQuery);
  }
}

/// Get Product By Reference Use Case
/// Used during sales to look up product by reference code
class GetProductByReferenceUseCase {
  final ProductRepository repository;

  GetProductByReferenceUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(String referenceCode) {
    return repository.getProductByReference(referenceCode);
  }
}

/// Add Product Use Case
class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductEntity product) {
    return repository.addProduct(product);
  }
}

/// Update Product Use Case
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(ProductEntity product) {
    return repository.updateProduct(product);
  }
}

/// Delete Product Use Case
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteProduct(id);
  }
}

/// Import Products from CSV Use Case
class ImportProductsCsvUseCase {
  final ProductRepository repository;

  ImportProductsCsvUseCase(this.repository);

  Future<Either<Failure, int>> call(List<Map<String, dynamic>> csvData) {
    return repository.importProductsFromCsv(csvData);
  }
}

/// Get Low Stock Products Use Case
class GetLowStockProductsUseCase {
  final ProductRepository repository;

  GetLowStockProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() {
    return repository.getLowStockProducts();
  }
}

/// Get Out of Stock Products Use Case
class GetOutOfStockProductsUseCase {
  final ProductRepository repository;

  GetOutOfStockProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call() {
    return repository.getOutOfStockProducts();
  }
}
