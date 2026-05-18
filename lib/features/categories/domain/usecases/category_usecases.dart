import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';
import 'package:gestion_stock/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;
  GetCategoriesUseCase(this.repository);
  Future<Either<Failure, List<CategoryEntity>>> call() =>
      repository.getCategories();
}

class AddCategoryUseCase {
  final CategoryRepository repository;
  AddCategoryUseCase(this.repository);
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) =>
      repository.addCategory(category);
}

class UpdateCategoryUseCase {
  final CategoryRepository repository;
  UpdateCategoryUseCase(this.repository);
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) =>
      repository.updateCategory(category);
}

class DeleteCategoryUseCase {
  final CategoryRepository repository;
  DeleteCategoryUseCase(this.repository);
  Future<Either<Failure, void>> call(String id) =>
      repository.deleteCategory(id);
}
