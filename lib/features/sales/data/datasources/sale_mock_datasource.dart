import 'package:gestion_stock/features/sales/data/models/client_model.dart';
import 'package:gestion_stock/features/sales/data/models/invoice_model.dart';
import 'package:gestion_stock/features/sales/data/models/sale_model.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';

/// Fake datasource — returns realistic mock sales/clients/invoices data.
/// Used when APP_ENV=test (no Supabase needed).
class SaleMockDataSource {
  static final _now = DateTime.now();
  static DateTime _daysAgo(int d) => _now.subtract(Duration(days: d));

  // ─── CLIENTS ─────────────────────────────────────────────────────────

  final List<ClientModel> _clients = [
    ClientModel(
      id: 'cli-001',
      firstName: 'Mohamed',
      lastName: 'Ben Ali',
      mobileNumber: '0661234567',
      cin: 'AB123456',
      createdAt: _daysAgo(90),
    ),
    ClientModel(
      id: 'cli-002',
      firstName: 'Fatima',
      lastName: 'Zahra',
      mobileNumber: '0677654321',
      cin: 'CD789012',
      createdAt: _daysAgo(80),
    ),
    ClientModel(
      id: 'cli-003',
      firstName: 'Karim',
      lastName: 'Mansouri',
      mobileNumber: '0654321098',
      cin: 'EF345678',
      createdAt: _daysAgo(70),
    ),
    ClientModel(
      id: 'cli-004',
      firstName: 'Laila',
      lastName: 'Haddad',
      mobileNumber: '0698765432',
      cin: 'GH901234',
      createdAt: _daysAgo(60),
    ),
    ClientModel(
      id: 'cli-005',
      firstName: 'Youssef',
      lastName: 'Benomar',
      mobileNumber: '0612345678',
      cin: 'IJ567890',
      createdAt: _daysAgo(50),
    ),
  ];

  // ─── SALES ───────────────────────────────────────────────────────────

  static List<SaleModel> _buildSales() {
    final now = DateTime.now();
    DateTime ago(int d) => now.subtract(Duration(days: d));

    final rows = <Map<String, dynamic>>[
      // ── Last 30 days (recent activity) ──────────────────────────────
      {'id': 's-001', 'prodId': 'prod-005', 'ref': 'BA-NGK-CR8E',  'name': 'Bougie NGK CR8E',            'qty': 3,  'sell': 140,  'buy': 85,   'cli': 'cli-001', 'day': 1},
      {'id': 's-002', 'prodId': 'prod-001', 'ref': 'HM-10W40-1L',  'name': 'Huile Moteur 10W40 – 1L',   'qty': 4,  'sell': 450,  'buy': 320,  'cli': 'cli-002', 'day': 2},
      {'id': 's-003', 'prodId': 'prod-010', 'ref': 'FH-H125-G',    'name': 'Filtre Huile – Honda 125',  'qty': 2,  'sell': 150,  'buy': 95,   'cli': 'cli-003', 'day': 3},
      {'id': 's-004', 'prodId': 'prod-003', 'ref': 'PF-AV-Y125',   'name': 'Plaquettes Frein Avant',    'qty': 1,  'sell': 280,  'buy': 180,  'cli': 'cli-001', 'day': 4},
      {'id': 's-005', 'prodId': 'prod-009', 'ref': 'FA-UNI-38MM',  'name': 'Filtre à Air 38mm',         'qty': 2,  'sell': 190,  'buy': 120,  'cli': 'cli-004', 'day': 5},
      {'id': 's-006', 'prodId': 'prod-006', 'ref': 'CH-420-116M',  'name': 'Chaîne 420 – 116 Maillons', 'qty': 1,  'sell': 340,  'buy': 220,  'cli': 'cli-005', 'day': 6},
      {'id': 's-007', 'prodId': 'prod-016', 'ref': 'SP-14T-428',   'name': 'Pignon Moteur 14 Dents',    'qty': 2,  'sell': 180,  'buy': 110,  'cli': 'cli-002', 'day': 7},
      {'id': 's-008', 'prodId': 'prod-013', 'ref': 'BAT-YTX5L-BS', 'name': 'Batterie YTX5L-BS 12V',    'qty': 1,  'sell': 580,  'buy': 380,  'cli': 'cli-003', 'day': 8},
      {'id': 's-009', 'prodId': 'prod-002', 'ref': 'HM-20W50-1L',  'name': 'Huile Moteur 20W50 – 1L',  'qty': 3,  'sell': 420,  'buy': 290,  'cli': 'cli-001', 'day': 10},
      {'id': 's-010', 'prodId': 'prod-011', 'ref': 'PN-AV-90-90-17','name': 'Pneu Avant 90/90-17',      'qty': 1,  'sell': 720,  'buy': 480,  'cli': 'cli-004', 'day': 11},
      {'id': 's-011', 'prodId': 'prod-015', 'ref': 'DF-H150-AV',   'name': 'Disque Frein Avant',        'qty': 1,  'sell': 650,  'buy': 420,  'cli': 'cli-005', 'day': 12},
      {'id': 's-012', 'prodId': 'prod-018', 'ref': 'RB-6301-2RS',  'name': 'Roulement Roue 6301-2RS',   'qty': 4,  'sell': 120,  'buy': 70,   'cli': 'cli-002', 'day': 14},
      {'id': 's-013', 'prodId': 'prod-005', 'ref': 'BA-NGK-CR8E',  'name': 'Bougie NGK CR8E',            'qty': 5,  'sell': 140,  'buy': 85,   'cli': 'cli-003', 'day': 15},
      {'id': 's-014', 'prodId': 'prod-001', 'ref': 'HM-10W40-1L',  'name': 'Huile Moteur 10W40 – 1L',   'qty': 6,  'sell': 450,  'buy': 320,  'cli': 'cli-001', 'day': 16},
      {'id': 's-015', 'prodId': 'prod-008', 'ref': 'KT-CH-520-Y',  'name': 'Kit Chaîne 520 – Yamaha',   'qty': 1,  'sell': 950,  'buy': 650,  'cli': 'cli-004', 'day': 18},
      {'id': 's-016', 'prodId': 'prod-014', 'ref': 'CE-Y125-ST',   'name': 'Câble Embrayage',            'qty': 2,  'sell': 110,  'buy': 65,   'cli': 'cli-005', 'day': 19},
      {'id': 's-017', 'prodId': 'prod-012', 'ref': 'PN-AR-100-90-17','name': 'Pneu Arrière 100/90-17',   'qty': 1,  'sell': 790,  'buy': 530,  'cli': 'cli-002', 'day': 20},
      {'id': 's-018', 'prodId': 'prod-007', 'ref': 'CH-428-120M',  'name': 'Chaîne 428 – 120 Maillons', 'qty': 1,  'sell': 380,  'buy': 250,  'cli': 'cli-003', 'day': 21},
      {'id': 's-019', 'prodId': 'prod-010', 'ref': 'FH-H125-G',    'name': 'Filtre Huile – Honda 125',  'qty': 3,  'sell': 150,  'buy': 95,   'cli': 'cli-001', 'day': 22},
      {'id': 's-020', 'prodId': 'prod-004', 'ref': 'PF-AR-H150',   'name': 'Plaquettes Frein Arrière',  'qty': 2,  'sell': 250,  'buy': 160,  'cli': 'cli-004', 'day': 24},
      // ── 30–60 days ago ──────────────────────────────────────────────
      {'id': 's-021', 'prodId': 'prod-001', 'ref': 'HM-10W40-1L',  'name': 'Huile Moteur 10W40 – 1L',   'qty': 8,  'sell': 450,  'buy': 320,  'cli': 'cli-002', 'day': 31},
      {'id': 's-022', 'prodId': 'prod-005', 'ref': 'BA-NGK-CR8E',  'name': 'Bougie NGK CR8E',            'qty': 6,  'sell': 140,  'buy': 85,   'cli': 'cli-005', 'day': 33},
      {'id': 's-023', 'prodId': 'prod-013', 'ref': 'BAT-YTX5L-BS', 'name': 'Batterie YTX5L-BS 12V',    'qty': 2,  'sell': 580,  'buy': 380,  'cli': 'cli-003', 'day': 35},
      {'id': 's-024', 'prodId': 'prod-009', 'ref': 'FA-UNI-38MM',  'name': 'Filtre à Air 38mm',         'qty': 4,  'sell': 190,  'buy': 120,  'cli': 'cli-001', 'day': 37},
      {'id': 's-025', 'prodId': 'prod-011', 'ref': 'PN-AV-90-90-17','name': 'Pneu Avant 90/90-17',      'qty': 2,  'sell': 720,  'buy': 480,  'cli': 'cli-004', 'day': 40},
      {'id': 's-026', 'prodId': 'prod-016', 'ref': 'SP-14T-428',   'name': 'Pignon Moteur 14 Dents',    'qty': 3,  'sell': 180,  'buy': 110,  'cli': 'cli-002', 'day': 42},
      {'id': 's-027', 'prodId': 'prod-006', 'ref': 'CH-420-116M',  'name': 'Chaîne 420 – 116 Maillons', 'qty': 2,  'sell': 340,  'buy': 220,  'cli': 'cli-005', 'day': 45},
      {'id': 's-028', 'prodId': 'prod-015', 'ref': 'DF-H150-AV',   'name': 'Disque Frein Avant',        'qty': 1,  'sell': 650,  'buy': 420,  'cli': 'cli-003', 'day': 48},
      // ── 60–90 days ago ──────────────────────────────────────────────
      {'id': 's-029', 'prodId': 'prod-002', 'ref': 'HM-20W50-1L',  'name': 'Huile Moteur 20W50 – 1L',  'qty': 7,  'sell': 420,  'buy': 290,  'cli': 'cli-001', 'day': 62},
      {'id': 's-030', 'prodId': 'prod-008', 'ref': 'KT-CH-520-Y',  'name': 'Kit Chaîne 520 – Yamaha',   'qty': 2,  'sell': 950,  'buy': 650,  'cli': 'cli-004', 'day': 65},
      {'id': 's-031', 'prodId': 'prod-012', 'ref': 'PN-AR-100-90-17','name': 'Pneu Arrière 100/90-17',   'qty': 2,  'sell': 790,  'buy': 530,  'cli': 'cli-002', 'day': 68},
      {'id': 's-032', 'prodId': 'prod-005', 'ref': 'BA-NGK-CR8E',  'name': 'Bougie NGK CR8E',            'qty': 10, 'sell': 140,  'buy': 85,   'cli': 'cli-003', 'day': 70},
      {'id': 's-033', 'prodId': 'prod-018', 'ref': 'RB-6301-2RS',  'name': 'Roulement Roue 6301-2RS',   'qty': 6,  'sell': 120,  'buy': 70,   'cli': 'cli-005', 'day': 72},
      {'id': 's-034', 'prodId': 'prod-001', 'ref': 'HM-10W40-1L',  'name': 'Huile Moteur 10W40 – 1L',   'qty': 10, 'sell': 450,  'buy': 320,  'cli': 'cli-001', 'day': 75},
      {'id': 's-035', 'prodId': 'prod-007', 'ref': 'CH-428-120M',  'name': 'Chaîne 428 – 120 Maillons', 'qty': 3,  'sell': 380,  'buy': 250,  'cli': 'cli-004', 'day': 78},
      {'id': 's-036', 'prodId': 'prod-010', 'ref': 'FH-H125-G',    'name': 'Filtre Huile – Honda 125',  'qty': 5,  'sell': 150,  'buy': 95,   'cli': 'cli-002', 'day': 80},
      // ── 90–180 days ago ─────────────────────────────────────────────
      {'id': 's-037', 'prodId': 'prod-013', 'ref': 'BAT-YTX5L-BS', 'name': 'Batterie YTX5L-BS 12V',    'qty': 3,  'sell': 580,  'buy': 380,  'cli': 'cli-003', 'day': 92},
      {'id': 's-038', 'prodId': 'prod-003', 'ref': 'PF-AV-Y125',   'name': 'Plaquettes Frein Avant',    'qty': 4,  'sell': 280,  'buy': 180,  'cli': 'cli-001', 'day': 98},
      {'id': 's-039', 'prodId': 'prod-009', 'ref': 'FA-UNI-38MM',  'name': 'Filtre à Air 38mm',         'qty': 6,  'sell': 190,  'buy': 120,  'cli': 'cli-004', 'day': 105},
      {'id': 's-040', 'prodId': 'prod-001', 'ref': 'HM-10W40-1L',  'name': 'Huile Moteur 10W40 – 1L',   'qty': 12, 'sell': 450,  'buy': 320,  'cli': 'cli-005', 'day': 115},
      {'id': 's-041', 'prodId': 'prod-005', 'ref': 'BA-NGK-CR8E',  'name': 'Bougie NGK CR8E',            'qty': 15, 'sell': 140,  'buy': 85,   'cli': 'cli-002', 'day': 120},
      {'id': 's-042', 'prodId': 'prod-011', 'ref': 'PN-AV-90-90-17','name': 'Pneu Avant 90/90-17',      'qty': 3,  'sell': 720,  'buy': 480,  'cli': 'cli-003', 'day': 130},
      {'id': 's-043', 'prodId': 'prod-008', 'ref': 'KT-CH-520-Y',  'name': 'Kit Chaîne 520 – Yamaha',   'qty': 3,  'sell': 950,  'buy': 650,  'cli': 'cli-001', 'day': 140},
      {'id': 's-044', 'prodId': 'prod-014', 'ref': 'CE-Y125-ST',   'name': 'Câble Embrayage',            'qty': 5,  'sell': 110,  'buy': 65,   'cli': 'cli-004', 'day': 150},
      {'id': 's-045', 'prodId': 'prod-002', 'ref': 'HM-20W50-1L',  'name': 'Huile Moteur 20W50 – 1L',  'qty': 8,  'sell': 420,  'buy': 290,  'cli': 'cli-002', 'day': 160},
    ];

    return rows.map((r) {
      final qty = r['qty'] as int;
      final sell = (r['sell'] as int).toDouble();
      final buy = (r['buy'] as int).toDouble();
      const tvaRate = 0.19;
      final totalHT = sell * qty;
      final tva = totalHT * tvaRate;
      final totalTTC = totalHT + tva;
      return SaleModel(
        id: r['id'] as String,
        productId: r['prodId'] as String,
        clientId: r['cli'] as String,
        referenceCode: r['ref'] as String,
        productName: r['name'] as String,
        quantity: qty,
        sellingPrice: sell,
        purchasePrice: buy,
        totalWithoutTVA: totalHT,
        tvaAmount: tva,
        totalWithTVA: totalTTC,
        createdAt: ago(r['day'] as int),
      );
    }).toList();
  }

  final List<SaleModel> _sales = _buildSales();

  // ─── INVOICES ────────────────────────────────────────────────────────

  List<InvoiceModel> get _invoices {
    final clientMap = {for (final c in _clients) c.id: c};
    return _sales.where((s) => s.clientId != null).map((s) {
      final c = clientMap[s.clientId!];
      return InvoiceModel(
        id: 'inv-${s.id}',
        invoiceNumber:
            'INV-${s.createdAt.year}${s.createdAt.month.toString().padLeft(2, '0')}${s.createdAt.day.toString().padLeft(2, '0')}-${s.id.split('-').last}',
        clientId: s.clientId!,
        clientName: c?.fullName ?? 'Client Inconnu',
        clientCin: c?.cin ?? '',
        clientMobile: c?.mobileNumber ?? '',
        items: [
          InvoiceItemModel(
            productId: s.productId,
            referenceCode: s.referenceCode,
            productName: s.productName,
            quantity: s.quantity,
            unitPrice: s.sellingPrice,
            purchasePrice: s.purchasePrice,
          ),
        ],
        totalWithoutTVA: s.totalWithoutTVA,
        tvaAmount: s.tvaAmount,
        totalWithTVA: s.totalWithTVA,
        createdAt: s.createdAt,
      );
    }).toList();
  }

  // ─── API ─────────────────────────────────────────────────────────────

  Future<SaleModel> createSale({
    required String productId,
    required String? clientId,
    required String referenceCode,
    required String productName,
    required int quantity,
    required double sellingPrice,
    required double purchasePrice,
    required double tvaRate,
  }) async {
    await _delay();
    final totalHT = sellingPrice * quantity;
    final tva = totalHT * tvaRate;
    final newSale = SaleModel(
      id: 'sale-${DateTime.now().millisecondsSinceEpoch}',
      productId: productId,
      clientId: clientId,
      referenceCode: referenceCode,
      productName: productName,
      quantity: quantity,
      sellingPrice: sellingPrice,
      purchasePrice: purchasePrice,
      totalWithoutTVA: totalHT,
      tvaAmount: tva,
      totalWithTVA: totalHT + tva,
      createdAt: DateTime.now(),
    );
    _sales.add(newSale);
    return newSale;
  }

  Future<List<SaleModel>> getSales({DateTime? startDate, DateTime? endDate}) async {
    await _delay();
    var result = List<SaleModel>.from(_sales);
    if (startDate != null) result = result.where((s) => s.createdAt.isAfter(startDate)).toList();
    if (endDate != null) result = result.where((s) => s.createdAt.isBefore(endDate)).toList();
    return result..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<SaleModel> getSaleById(String id) async {
    await _delay();
    return _sales.firstWhere((s) => s.id == id);
  }

  // Clients
  Future<ClientModel> createClient({
    required String firstName,
    required String lastName,
    required String mobileNumber,
    required String cin,
  }) async {
    await _delay();
    final c = ClientModel(
      id: 'cli-${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      mobileNumber: mobileNumber,
      cin: cin,
      createdAt: DateTime.now(),
    );
    _clients.add(c);
    return c;
  }

  Future<ClientModel?> getClientByCin(String cin) async {
    await _delay();
    try {
      return _clients.firstWhere(
          (c) => c.cin.toLowerCase() == cin.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  Future<List<ClientModel>> getClients() async {
    await _delay();
    return List.from(_clients);
  }

  // Invoices
  Future<InvoiceModel> createInvoice({
    required List<InvoiceItemEntity> items,
    required ClientModel client,
    required double totalWithoutTVA,
    required double tvaAmount,
    required double totalWithTVA,
  }) async {
    await _delay();
    final now = DateTime.now();
    final inv = InvoiceModel(
      id: 'inv-${now.millisecondsSinceEpoch}',
      invoiceNumber:
          'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}',
      clientId: client.id,
      clientName: client.fullName,
      clientCin: client.cin,
      clientMobile: client.mobileNumber,
      items: items
          .map((i) => InvoiceItemModel(
                productId: i.productId,
                referenceCode: i.referenceCode,
                productName: i.productName,
                quantity: i.quantity,
                unitPrice: i.unitPrice,
                purchasePrice: i.purchasePrice,
              ))
          .toList(),
      totalWithoutTVA: totalWithoutTVA,
      tvaAmount: tvaAmount,
      totalWithTVA: totalWithTVA,
      createdAt: now,
    );
    return inv;
  }

  Future<List<InvoiceModel>> getAllInvoices() async {
    await _delay();
    return _invoices..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<InvoiceModel>> getInvoicesByClient(String clientId) async {
    await _delay();
    return _invoices
        .where((i) => i.clientId == clientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────
  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));
}
