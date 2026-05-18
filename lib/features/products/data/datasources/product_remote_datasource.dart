import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/exceptions.dart';
import 'package:gestion_stock/core/network/dio_client.dart';
import 'package:gestion_stock/features/products/data/models/product_model.dart';

/// Product Remote Data Source
/// Handles all communication with Supabase REST API via Dio for product operations
class ProductRemoteDataSource {
  final DioClient _client;

  ProductRemoteDataSource(this._client);

  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final params = <String, dynamic>{
        'order': 'created_at.desc',
      };

      if (category != null) {
        params['category'] = 'eq.$category';
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        params['or'] =
            '(reference_code.ilike.%$searchQuery%,name.ilike.%$searchQuery%)';
      }

      final response = await _client.getAll(
        AppConstants.productsTable,
        queryParameters: params,
      );
      return response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to fetch products: ${e.toString()}');
    }
  }

  /// Get product by ID
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _client.getById(AppConstants.productsTable, id);
      return ProductModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Product not found: ${e.toString()}');
    }
  }

  /// Get product by reference code
  Future<ProductModel> getProductByReference(String referenceCode) async {
    try {
      final response = await _client.getByColumn(
        AppConstants.productsTable,
        'reference_code',
        referenceCode,
      );
      return ProductModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Product not found with reference: $referenceCode');
    }
  }

  /// Add a new product
  Future<ProductModel> addProduct(ProductModel product) async {
    try {
      final response = await _client.insert(
        AppConstants.productsTable,
        product.toInsertJson(),
      );
      return ProductModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Failed to add product: ${e.toString()}');
    }
  }

  /// Update product
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final response = await _client.update(
        AppConstants.productsTable,
        product.id,
        product.toJson(),
      );
      return ProductModel.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to update product: ${e.toString()}');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String id) async {
    try {
      await _client.delete(AppConstants.productsTable, id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to delete product: ${e.toString()}');
    }
  }

  /// Bulk insert products (for CSV import)
  Future<int> bulkInsertProducts(List<ProductModel> products) async {
    try {
      final data = products.map((p) => p.toInsertJson()).toList();
      await _client.bulkInsert(AppConstants.productsTable, data);
      return products.length;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to import products: ${e.toString()}');
    }
  }

  /// Get low stock products
  Future<List<ProductModel>> getLowStockProducts() async {
    try {
      final response = await _client.getAll(
        AppConstants.productsTable,
        queryParameters: {
          'quantity': 'gt.0',
          'order': 'quantity.asc',
        },
      );
      final products = response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return products.where((p) => p.quantity <= p.lowStockThreshold).toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch low stock products: ${e.toString()}');
    }
  }

  /// Get out of stock products
  Future<List<ProductModel>> getOutOfStockProducts() async {
    try {
      final response = await _client.getAll(
        AppConstants.productsTable,
        queryParameters: {
          'quantity': 'lte.0',
          'order': 'name.asc',
        },
      );
      return response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to fetch out of stock products: ${e.toString()}');
    }
  }

  /// Update stock quantity
  Future<void> updateStock(String productId, int newQuantity) async {
    try {
      await _client.update(
        AppConstants.productsTable,
        productId,
        {
          'quantity': newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: 'Failed to update stock: ${e.toString()}');
    }
  }
}
