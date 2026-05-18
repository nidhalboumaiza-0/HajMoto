import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';
import 'package:gestion_stock/features/categories/domain/repositories/category_repository.dart';

class CategoryMockRepositoryImpl implements CategoryRepository {
  final CategoryMockDataSource _ds;
  CategoryMockRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      return Right(await _ds.getCategories());
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> addCategory(
      CategoryEntity category) async {
    try {
      return Right(await _ds.addCategory(category));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(
      CategoryEntity category) async {
    try {
      return Right(await _ds.updateCategory(category));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await _ds.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
