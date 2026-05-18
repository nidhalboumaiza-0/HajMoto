import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Category Entity - Domain Layer
/// Represents a product category that users can create, edit and delete.
/// The 4 default categories (Vespa/Forza parts & scooters) are seeded on
/// first run but behave exactly like user-created ones.
class CategoryEntity extends Equatable {
  final String id;

  /// URL-safe slug, e.g. 'vespa_parts'
  final String value;

  /// Human-readable label shown in the UI, e.g. 'Pièces Vespa'
  final String displayName;

  /// Stored as a Flutter Color.value int (ARGB) for persistence
  final int colorValue;

  final DateTime createdAt;

  const CategoryEntity({
    required this.id,
    required this.value,
    required this.displayName,
    required this.colorValue,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  CategoryEntity copyWith({
    String? id,
    String? value,
    String? displayName,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      value: value ?? this.value,
      displayName: displayName ?? this.displayName,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, value, displayName, colorValue, createdAt];
}
