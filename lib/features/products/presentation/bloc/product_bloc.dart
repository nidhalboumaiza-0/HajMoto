import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_stock/features/products/domain/usecases/product_usecases.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_event.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_state.dart';

/// Product BLoC - Presentation Layer
/// Manages product feature state using events and states
/// No direct database calls - delegates to use cases (Clean Architecture)
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsUseCase getProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final ImportProductsCsvUseCase importProductsCsvUseCase;
  final GetProductByReferenceUseCase getProductByReferenceUseCase;
  final GetLowStockProductsUseCase getLowStockProductsUseCase;
  final GetOutOfStockProductsUseCase getOutOfStockProductsUseCase;

  ProductBloc({
    required this.getProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.importProductsCsvUseCase,
    required this.getProductByReferenceUseCase,
    required this.getLowStockProductsUseCase,
    required this.getOutOfStockProductsUseCase,
  }) : super(const ProductInitialState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<AddProductEvent>(_onAddProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<ImportProductsCsvEvent>(_onImportCsv);
    on<SearchProductByReferenceEvent>(_onSearchByReference);
    on<LoadLowStockProductsEvent>(_onLoadLowStock);
    on<LoadOutOfStockProductsEvent>(_onLoadOutOfStock);
    on<FilterByCategoryEvent>(_onFilterByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await getProductsUseCase(
      category: event.category,
      searchQuery: event.searchQuery,
    );
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(const ProductEmptyState());
        } else {
          emit(ProductLoadedState(
            products: products,
            activeCategory: event.category,
            searchQuery: event.searchQuery,
          ));
        }
      },
    );
  }

  Future<void> _onAddProduct(
    AddProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await addProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(const ProductOperationSuccessState('Product added successfully'));
        add(const LoadProductsEvent());
      },
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await updateProductUseCase(event.product);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(const ProductOperationSuccessState('Product updated successfully'));
        add(const LoadProductsEvent());
      },
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await deleteProductUseCase(event.productId);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (_) {
        emit(const ProductOperationSuccessState('Product deleted successfully'));
        add(const LoadProductsEvent());
      },
    );
  }

  Future<void> _onImportCsv(
    ImportProductsCsvEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await importProductsCsvUseCase(event.csvData);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (count) {
        emit(ProductImportSuccessState(count));
        add(const LoadProductsEvent());
      },
    );
  }

  Future<void> _onSearchByReference(
    SearchProductByReferenceEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await getProductByReferenceUseCase(event.referenceCode);
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (product) => emit(ProductDetailState(product)),
    );
  }

  Future<void> _onLoadLowStock(
    LoadLowStockProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await getLowStockProductsUseCase();
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(const ProductEmptyState(message: 'No low stock products'));
        } else {
          emit(ProductLoadedState(products: products));
        }
      },
    );
  }

  Future<void> _onLoadOutOfStock(
    LoadOutOfStockProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoadingState());
    final result = await getOutOfStockProductsUseCase();
    result.fold(
      (failure) => emit(ProductErrorState(failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(const ProductEmptyState(message: 'No out of stock products'));
        } else {
          emit(ProductLoadedState(products: products));
        }
      },
    );
  }

  Future<void> _onFilterByCategory(
    FilterByCategoryEvent event,
    Emitter<ProductState> emit,
  ) async {
    add(LoadProductsEvent(category: event.category));
  }
}
