import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';

/// Product BLoC Events
/// Each event represents a user action or system trigger
abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Load all products (with optional filters)
class LoadProductsEvent extends ProductEvent {
  final String? category;
  final String? searchQuery;

  const LoadProductsEvent({this.category, this.searchQuery});

  @override
  List<Object?> get props => [category, searchQuery];
}

/// Add a new product
class AddProductEvent extends ProductEvent {
  final ProductEntity product;

  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Update an existing product
class UpdateProductEvent extends ProductEvent {
  final ProductEntity product;

  const UpdateProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

/// Delete a product
class DeleteProductEvent extends ProductEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Import products from CSV
class ImportProductsCsvEvent extends ProductEvent {
  final List<Map<String, dynamic>> csvData;

  const ImportProductsCsvEvent(this.csvData);

  @override
  List<Object?> get props => [csvData];
}

/// Search product by reference code
class SearchProductByReferenceEvent extends ProductEvent {
  final String referenceCode;

  const SearchProductByReferenceEvent(this.referenceCode);

  @override
  List<Object?> get props => [referenceCode];
}

/// Load low stock products
class LoadLowStockProductsEvent extends ProductEvent {
  const LoadLowStockProductsEvent();
}

/// Load out of stock products
class LoadOutOfStockProductsEvent extends ProductEvent {
  const LoadOutOfStockProductsEvent();
}

/// Filter products by category
class FilterByCategoryEvent extends ProductEvent {
  final String? category;

  const FilterByCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}
