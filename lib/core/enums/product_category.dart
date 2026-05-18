/// Product categories enum
/// Represents the 4 types of products sold in the shop:
/// - Vespa spare parts
/// - Forza spare parts
/// - Complete Vespa scooters
/// - Complete Forza scooters
enum ProductCategory {
  vespaParts('vespa_parts', 'Pièces Vespa'),
  forzaParts('forza_parts', 'Pièces Forza'),
  vespaScooter('vespa_scooter', 'Scooter Vespa'),
  forzaScooter('forza_scooter', 'Scooter Forza');

  final String value;
  final String displayName;

  const ProductCategory(this.value, this.displayName);

  /// Convert from string value to enum
  static ProductCategory fromValue(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProductCategory.vespaParts,
    );
  }
}
