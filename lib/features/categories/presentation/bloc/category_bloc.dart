import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_stock/features/categories/domain/usecases/category_usecases.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_event.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoryInitialState()) {
    on<LoadCategoriesEvent>(_onLoad);
    on<AddCategoryEvent>(_onAdd);
    on<UpdateCategoryEvent>(_onUpdate);
    on<DeleteCategoryEvent>(_onDelete);
  }

  Future<void> _onLoad(
      LoadCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(const CategoryLoadingState());
    final result = await getCategoriesUseCase();
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (categories) => emit(CategoryLoadedState(categories)),
    );
  }

  Future<void> _onAdd(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await addCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (_) async {
        final listResult = await getCategoriesUseCase();
        listResult.fold(
          (f) => emit(CategoryErrorState(f.message)),
          (cats) => emit(CategoryOperationSuccessState(
              categories: cats, message: 'Catégorie ajoutée avec succès')),
        );
      },
    );
  }

  Future<void> _onUpdate(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await updateCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (_) async {
        final listResult = await getCategoriesUseCase();
        listResult.fold(
          (f) => emit(CategoryErrorState(f.message)),
          (cats) => emit(CategoryOperationSuccessState(
              categories: cats, message: 'Catégorie mise à jour')),
        );
      },
    );
  }

  Future<void> _onDelete(
      DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await deleteCategoryUseCase(event.categoryId);
    result.fold(
      (failure) => emit(CategoryErrorState(failure.message)),
      (_) async {
        final listResult = await getCategoriesUseCase();
        listResult.fold(
          (f) => emit(CategoryErrorState(f.message)),
          (cats) => emit(CategoryOperationSuccessState(
              categories: cats, message: 'Catégorie supprimée')),
        );
      },
    );
  }
}
