import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';

/// Product BLoC States
/// Represents all possible states of the product feature
abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class ProductInitialState extends ProductState {
  const ProductInitialState();
}

/// Loading state while fetching data
class ProductLoadingState extends ProductState {
  const ProductLoadingState();
}

/// Products loaded successfully
class ProductLoadedState extends ProductState {
  final List<ProductEntity> products;
  final String? activeCategory;
  final String? searchQuery;

  const ProductLoadedState({
    required this.products,
    this.activeCategory,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [products, activeCategory, searchQuery];
}

/// Single product loaded (for detail/edit)
class ProductDetailState extends ProductState {
  final ProductEntity product;

  const ProductDetailState(this.product);

  @override
  List<Object?> get props => [product];
}

/// Product operation successful (add, update, delete)
class ProductOperationSuccessState extends ProductState {
  final String message;

  const ProductOperationSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

/// CSV import success
class ProductImportSuccessState extends ProductState {
  final int importedCount;

  const ProductImportSuccessState(this.importedCount);

  @override
  List<Object?> get props => [importedCount];
}

/// Error state
class ProductErrorState extends ProductState {
  final String message;

  const ProductErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no products match filter)
class ProductEmptyState extends ProductState {
  final String message;

  const ProductEmptyState({this.message = 'No products found'});

  @override
  List<Object?> get props => [message];
}
