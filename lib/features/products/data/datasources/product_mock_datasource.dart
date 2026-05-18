import 'package:gestion_stock/features/products/data/models/product_model.dart';

/// Fake datasource — returns realistic mock data for the Vespa/Forza
/// motorcycle spare-parts shop. Used when APP_ENV=test (no Supabase needed).
class ProductMockDataSource {
  static final _now = DateTime.now();
  static DateTime _daysAgo(int d) => _now.subtract(Duration(days: d));

  // Category string constants matching CategoryMockDataSource seeds
  static const _vespaParts = 'vespa_parts';
  static const _forzaParts = 'forza_parts';
  static const _vespaScooter = 'vespa_scooter';
  static const _forzaScooter = 'forza_scooter';

  static final List<ProductModel> _products = [
    // ── Pièces Vespa ────────────────────────────────────────────────
    ProductModel(
      id: 'prod-001',
      referenceCode: 'VSP-HM-10W40',
      name: 'Huile Moteur Vespa 10W40 – 1L',
      categories: [_vespaParts],
      purchasePrice: 320,
      sellingPrice: 450,
      quantity: 48,
      lowStockThreshold: 10,
      createdAt: _daysAgo(120),
      updatedAt: _daysAgo(2),
    ),
    ProductModel(
      id: 'prod-002',
      referenceCode: 'VSP-PF-AV-GTS',
      name: 'Plaquettes Frein Avant – Vespa GTS',
      categories: [_vespaParts],
      purchasePrice: 180,
      sellingPrice: 280,
      quantity: 22,
      lowStockThreshold: 5,
      createdAt: _daysAgo(100),
      updatedAt: _daysAgo(5),
    ),
    ProductModel(
      id: 'prod-003',
      referenceCode: 'VSP-BA-NGK-CR8E',
      name: 'Bougie NGK CR8E – Vespa',
      categories: [_vespaParts],
      purchasePrice: 85,
      sellingPrice: 140,
      quantity: 60,
      lowStockThreshold: 15,
      createdAt: _daysAgo(90),
      updatedAt: _daysAgo(1),
    ),
    ProductModel(
      id: 'prod-004',
      referenceCode: 'VSP-CH-GTS300',
      name: 'Kit Transmission – Vespa GTS 300',
      categories: [_vespaParts],
      purchasePrice: 650,
      sellingPrice: 950,
      quantity: 12,
      lowStockThreshold: 4,
      createdAt: _daysAgo(85),
      updatedAt: _daysAgo(10),
    ),
    ProductModel(
      id: 'prod-005',
      referenceCode: 'VSP-FA-125',
      name: 'Filtre à Air – Vespa 125',
      categories: [_vespaParts],
      purchasePrice: 120,
      sellingPrice: 190,
      quantity: 40,
      lowStockThreshold: 10,
      createdAt: _daysAgo(75),
      updatedAt: _daysAgo(2),
    ),
    ProductModel(
      id: 'prod-006',
      referenceCode: 'VSP-FH-LX150',
      name: 'Filtre Huile – Vespa LX 150',
      categories: [_vespaParts],
      purchasePrice: 95,
      sellingPrice: 150,
      quantity: 55,
      lowStockThreshold: 10,
      createdAt: _daysAgo(72),
      updatedAt: _daysAgo(1),
    ),
    ProductModel(
      id: 'prod-007',
      referenceCode: 'VSP-PN-110-70-11',
      name: 'Pneu Avant 110/70-11 – Vespa',
      categories: [_vespaParts],
      purchasePrice: 480,
      sellingPrice: 720,
      quantity: 15,
      lowStockThreshold: 4,
      createdAt: _daysAgo(68),
      updatedAt: _daysAgo(8),
    ),
    ProductModel(
      id: 'prod-008',
      referenceCode: 'VSP-PN-120-70-12',
      name: 'Pneu Arrière 120/70-12 – Vespa',
      categories: [_vespaParts],
      purchasePrice: 530,
      sellingPrice: 790,
      quantity: 13,
      lowStockThreshold: 4,
      createdAt: _daysAgo(65),
      updatedAt: _daysAgo(9),
    ),
    ProductModel(
      id: 'prod-009',
      referenceCode: 'VSP-BAT-YTX5L',
      name: 'Batterie YTX5L-BS – Vespa 125',
      categories: [_vespaParts],
      purchasePrice: 380,
      sellingPrice: 580,
      quantity: 20,
      lowStockThreshold: 5,
      createdAt: _daysAgo(60),
      updatedAt: _daysAgo(12),
    ),
    ProductModel(
      id: 'prod-010',
      referenceCode: 'VSP-DF-GTS-AV',
      name: 'Disque Frein Avant – Vespa GTS',
      categories: [_vespaParts],
      purchasePrice: 420,
      sellingPrice: 650,
      quantity: 3,
      lowStockThreshold: 4,
      createdAt: _daysAgo(50),
      updatedAt: _daysAgo(15),
    ),
    // ── Pièces Forza ────────────────────────────────────────────────
    ProductModel(
      id: 'prod-011',
      referenceCode: 'FRZ-HM-10W30',
      name: 'Huile Moteur Honda Forza 10W30 – 1L',
      categories: [_forzaParts],
      purchasePrice: 340,
      sellingPrice: 490,
      quantity: 35,
      lowStockThreshold: 10,
      createdAt: _daysAgo(115),
      updatedAt: _daysAgo(3),
    ),
    ProductModel(
      id: 'prod-012',
      referenceCode: 'FRZ-PF-AV-300',
      name: 'Plaquettes Frein Avant – Forza 300',
      categories: [_forzaParts],
      purchasePrice: 210,
      sellingPrice: 330,
      quantity: 18,
      lowStockThreshold: 5,
      createdAt: _daysAgo(98),
      updatedAt: _daysAgo(4),
    ),
    ProductModel(
      id: 'prod-013',
      referenceCode: 'FRZ-BA-IU24',
      name: 'Bougie Iridium IU24 – Forza 350',
      categories: [_forzaParts],
      purchasePrice: 120,
      sellingPrice: 195,
      quantity: 30,
      lowStockThreshold: 8,
      createdAt: _daysAgo(80),
      updatedAt: _daysAgo(6),
    ),
    ProductModel(
      id: 'prod-014',
      referenceCode: 'FRZ-PN-AV-120-70-14',
      name: 'Pneu Avant 120/70-14 – Forza 300',
      categories: [_forzaParts],
      purchasePrice: 650,
      sellingPrice: 980,
      quantity: 10,
      lowStockThreshold: 3,
      createdAt: _daysAgo(70),
      updatedAt: _daysAgo(7),
    ),
    ProductModel(
      id: 'prod-015',
      referenceCode: 'FRZ-BAT-YTX12',
      name: 'Batterie YTX12-BS – Forza 300',
      categories: [_forzaParts],
      purchasePrice: 550,
      sellingPrice: 820,
      quantity: 2,
      lowStockThreshold: 4,
      createdAt: _daysAgo(45),
      updatedAt: _daysAgo(20),
    ),
    ProductModel(
      id: 'prod-016',
      referenceCode: 'FRZ-FA-350',
      name: 'Filtre à Air – Forza 350',
      categories: [_forzaParts],
      purchasePrice: 145,
      sellingPrice: 220,
      quantity: 25,
      lowStockThreshold: 6,
      createdAt: _daysAgo(40),
      updatedAt: _daysAgo(5),
    ),
    // ── Scooters Vespa ───────────────────────────────────────────────
    ProductModel(
      id: 'prod-017',
      referenceCode: 'VSP-GTS-125-BLK',
      name: 'Vespa GTS 125 – Noir Mat',
      categories: [_vespaScooter],
      purchasePrice: 18500,
      sellingPrice: 23900,
      quantity: 4,
      lowStockThreshold: 2,
      createdAt: _daysAgo(35),
      updatedAt: _daysAgo(18),
    ),
    ProductModel(
      id: 'prod-018',
      referenceCode: 'VSP-GTS-300-RED',
      name: 'Vespa GTS 300 HPE – Rouge',
      categories: [_vespaScooter],
      purchasePrice: 28000,
      sellingPrice: 35500,
      quantity: 2,
      lowStockThreshold: 1,
      createdAt: _daysAgo(30),
      updatedAt: _daysAgo(10),
    ),
    // ── Scooters Forza ───────────────────────────────────────────────
    ProductModel(
      id: 'prod-019',
      referenceCode: 'FRZ-300-WHT',
      name: 'Honda Forza 300 – Blanc Perle',
      categories: [_forzaScooter],
      purchasePrice: 24000,
      sellingPrice: 30500,
      quantity: 0,
      lowStockThreshold: 1,
      createdAt: _daysAgo(25),
      updatedAt: _daysAgo(25),
    ),
    ProductModel(
      id: 'prod-020',
      referenceCode: 'FRZ-350-GRY',
      name: 'Honda Forza 350 – Gris Métallisé',
      categories: [_forzaScooter],
      purchasePrice: 29000,
      sellingPrice: 36800,
      quantity: 1,
      lowStockThreshold: 1,
      createdAt: _daysAgo(20),
      updatedAt: _daysAgo(8),
    ),
  ];

  final List<ProductModel> _data = List.from(_products);

  // ─── READ ────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts({
    String? category,
    String? searchQuery,
  }) async {
    await _delay();
    var result = List<ProductModel>.from(_data);
    if (category != null) {
      result = result.where((p) => p.categories.contains(category)).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.referenceCode.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  Future<ProductModel> getProductById(String id) async {
    await _delay();
    return _data.firstWhere((p) => p.id == id,
        orElse: () => throw Exception('Produit introuvable: $id'));
  }

  Future<ProductModel> getProductByReference(String ref) async {
    await _delay();
    return _data.firstWhere((p) => p.referenceCode == ref,
        orElse: () => throw Exception('Référence introuvable: $ref'));
  }

  // ─── WRITE ───────────────────────────────────────────────────────────

  Future<ProductModel> addProduct(ProductModel product) async {
    await _delay();
    final newProduct = product.copyWith(
      id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _data.add(newProduct);
    return newProduct;
  }

  Future<ProductModel> updateProduct(ProductModel product) async {
    await _delay();
    final idx = _data.indexWhere((p) => p.id == product.id);
    if (idx == -1) throw Exception('Produit introuvable: ${product.id}');
    final updated = product.copyWith(updatedAt: DateTime.now());
    _data[idx] = updated;
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    await _delay();
    _data.removeWhere((p) => p.id == id);
  }

  Future<int> bulkInsertProducts(List<ProductModel> products) async {
    await _delay();
    final now = DateTime.now();
    final inserted = products
        .map((p) => p.copyWith(
              id: 'prod-${now.millisecondsSinceEpoch}-${p.referenceCode}',
              createdAt: now,
              updatedAt: now,
            ))
        .toList();
    _data.addAll(inserted);
    return products.length;
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    await _delay();
    return _data.where((p) => p.isLowStock).toList();
  }

  Future<List<ProductModel>> getOutOfStockProducts() async {
    await _delay();
    return _data.where((p) => p.isOutOfStock).toList();
  }

  Future<void> updateStock(String productId, int newQuantity) async {
    await _delay();
    final idx = _data.indexWhere((p) => p.id == productId);
    if (idx == -1) return;
    _data[idx] = _data[idx].copyWith(
      quantity: newQuantity,
      updatedAt: DateTime.now(),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────

  // Simulates network latency for a realistic feel in the UI
  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));
}
