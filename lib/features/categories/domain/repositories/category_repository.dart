import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';

/// Category Repository Interface - Domain Layer
abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();
  Future<Either<Failure, CategoryEntity>> addCategory(CategoryEntity category);
  Future<Either<Failure, CategoryEntity>> updateCategory(CategoryEntity category);
  Future<Either<Failure, void>> deleteCategory(String id);
}
