import 'package:flutter/material.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';

/// In-memory category store.
/// Seeded with the 4 default Vespa / Forza categories.
/// All CRUD operations mutate the in-memory list so changes persist for
/// the lifetime of the app session (test mode).
class CategoryMockDataSource {
  final List<CategoryEntity> _categories = [
    CategoryEntity(
      id: 'cat-001',
      value: 'vespa_parts',
      displayName: 'Pièces Vespa',
      colorValue: const Color(0xFF1565C0).toARGB32(), // blue
      createdAt: DateTime(2024, 1, 1),
    ),
    CategoryEntity(
      id: 'cat-002',
      value: 'forza_parts',
      displayName: 'Pièces Forza',
      colorValue: const Color(0xFF2E7D32).toARGB32(), // green
      createdAt: DateTime(2024, 1, 1),
    ),
    CategoryEntity(
      id: 'cat-003',
      value: 'vespa_scooter',
      displayName: 'Scooter Vespa',
      colorValue: const Color(0xFF6A1B9A).toARGB32(), // purple
      createdAt: DateTime(2024, 1, 1),
    ),
    CategoryEntity(
      id: 'cat-004',
      value: 'forza_scooter',
      displayName: 'Scooter Forza',
      colorValue: const Color(0xFFE65100).toARGB32(), // orange
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  int _idCounter = 5;

  Future<List<CategoryEntity>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_categories);
  }

  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final newCat = category.copyWith(
        id: 'cat-${_idCounter.toString().padLeft(3, '0')}');
    _idCounter++;
    _categories.add(newCat);
    return newCat;
  }

  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _categories.indexWhere((c) => c.id == category.id);
    if (idx == -1) throw Exception('Catégorie introuvable');
    _categories[idx] = category;
    return category;
  }

  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _categories.removeWhere((c) => c.id == id);
  }

  /// Convenient lookup used by product widgets
  CategoryEntity? findByValue(String value) {
    try {
      return _categories.firstWhere((c) => c.value == value);
    } catch (_) {
      return null;
    }
  }
}
