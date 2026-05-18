import 'package:equatable/equatable.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
}

class CategoryInitialState extends CategoryState {
  const CategoryInitialState();
}

class CategoryLoadingState extends CategoryState {
  const CategoryLoadingState();
}

class CategoryLoadedState extends CategoryState {
  final List<CategoryEntity> categories;
  const CategoryLoadedState(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoryOperationSuccessState extends CategoryState {
  final List<CategoryEntity> categories;
  final String message;
  const CategoryOperationSuccessState(
      {required this.categories, required this.message});
  @override
  List<Object?> get props => [categories, message];
}

class CategoryErrorState extends CategoryState {
  final String message;
  const CategoryErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
