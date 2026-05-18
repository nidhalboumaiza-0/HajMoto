import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';
import 'package:gestion_stock/features/dashboard/domain/repositories/statistics_repository.dart';

/// Fake implementation of [StatisticsRepository] — builds realistic statistics
/// from in-memory data. Used when APP_ENV=test (no Supabase needed).
class MockStatisticsRepository implements StatisticsRepository {
  static final _now = DateTime.now();
  static DateTime _monthStart(int monthsAgo) {
    final m = _now.month - monthsAgo;
    final y = _now.year + (m <= 0 ? -1 : 0);
    final month = m <= 0 ? m + 12 : m;
    return DateTime(y, month, 1);
  }

  // ─── MONTHLY DATA ────────────────────────────────────────────────────
  static final List<MonthlySalesData> _monthly = [
    MonthlySalesData(year: _monthStart(11).year, month: _monthStart(11).month, revenue: 18500, profit:  5200, salesCount: 41),
    MonthlySalesData(year: _monthStart(10).year, month: _monthStart(10).month, revenue: 21300, profit:  6100, salesCount: 47),
    MonthlySalesData(year: _monthStart(9).year,  month: _monthStart(9).month,  revenue: 19800, profit:  5700, salesCount: 44),
    MonthlySalesData(year: _monthStart(8).year,  month: _monthStart(8).month,  revenue: 24700, profit:  7400, salesCount: 53),
    MonthlySalesData(year: _monthStart(7).year,  month: _monthStart(7).month,  revenue: 22100, profit:  6600, salesCount: 49),
    MonthlySalesData(year: _monthStart(6).year,  month: _monthStart(6).month,  revenue: 26400, profit:  8200, salesCount: 58),
    MonthlySalesData(year: _monthStart(5).year,  month: _monthStart(5).month,  revenue: 28900, profit:  9100, salesCount: 63),
    MonthlySalesData(year: _monthStart(4).year,  month: _monthStart(4).month,  revenue: 25600, profit:  7800, salesCount: 56),
    MonthlySalesData(year: _monthStart(3).year,  month: _monthStart(3).month,  revenue: 31200, profit: 10100, salesCount: 69),
    MonthlySalesData(year: _monthStart(2).year,  month: _monthStart(2).month,  revenue: 29400, profit:  9400, salesCount: 65),
    MonthlySalesData(year: _monthStart(1).year,  month: _monthStart(1).month,  revenue: 34700, profit: 11500, salesCount: 74),
    MonthlySalesData(year: _monthStart(0).year,  month: _monthStart(0).month,  revenue: 38100, profit: 12900, salesCount: 82),
  ];

  // ─── DAILY TREND (last 30 days) ──────────────────────────────────────
  static List<SalesDataPoint> _buildDailyTrend() {
    final points = <SalesDataPoint>[];
    final revenues = [
      850, 1200, 980, 1450, 760, 1100, 1380, 920, 1650, 840,
      1290, 1540, 1080, 720, 1420, 1670, 990, 1360, 1520, 880,
      1240, 1780, 1030, 1590, 1450, 1210, 1680, 940, 1320, 1870,
    ];
    for (int i = 29; i >= 0; i--) {
      points.add(SalesDataPoint(
        date: _now.subtract(Duration(days: i)),
        value: revenues[29 - i].toDouble(),
      ));
    }
    return points;
  }

  static List<SalesDataPoint> _buildDailyProfit() {
    final points = <SalesDataPoint>[];
    final profits = [
      220, 350, 290, 430, 210, 320, 410, 270, 490, 240,
      380, 460, 315, 200, 420, 500, 290, 400, 450, 255,
      365, 530, 300, 475, 425, 350, 500, 275, 390, 560,
    ];
    for (int i = 29; i >= 0; i--) {
      points.add(SalesDataPoint(
        date: _now.subtract(Duration(days: i)),
        value: profits[29 - i].toDouble(),
      ));
    }
    return points;
  }

  // ─── CATEGORIES ──────────────────────────────────────────────────────
  static final List<CategorySalesData> _categories = [
    CategorySalesData(category: 'vespa_parts',   revenue: 86400, profit: 29500, quantity: 312),
    CategorySalesData(category: 'forza_parts',   revenue: 71200, profit: 24100, quantity: 248),
    CategorySalesData(category: 'vespa_scooter', revenue: 71700, profit: 16200, quantity:   3),
    CategorySalesData(category: 'forza_scooter', revenue: 67400, profit: 15100, quantity:   2),
  ];

  // ─── BEST SELLERS ────────────────────────────────────────────────────
  static final List<BestSellingProduct> _bestSellers = [
    BestSellingProduct(productName: 'Huile Moteur Vespa 10W40 – 1L',      referenceCode: 'VSP-HM-10W40',      totalQuantitySold: 48, totalRevenue: 21600),
    BestSellingProduct(productName: 'Bougie NGK CR8E – Vespa',            referenceCode: 'VSP-BA-NGK-CR8E',   totalQuantitySold: 42, totalRevenue:  5880),
    BestSellingProduct(productName: 'Huile Moteur Honda Forza 10W30 – 1L',referenceCode: 'FRZ-HM-10W30',      totalQuantitySold: 39, totalRevenue: 19110),
    BestSellingProduct(productName: 'Filtre Huile – Vespa LX 150',        referenceCode: 'VSP-FH-LX150',      totalQuantitySold: 35, totalRevenue:  5250),
    BestSellingProduct(productName: 'Plaquettes Frein Avant – Vespa GTS', referenceCode: 'VSP-PF-AV-GTS',     totalQuantitySold: 28, totalRevenue:  7840),
    BestSellingProduct(productName: 'Filtre à Air – Vespa 125',           referenceCode: 'VSP-FA-125',        totalQuantitySold: 26, totalRevenue:  4940),
    BestSellingProduct(productName: 'Pneu Avant 110/70-11 – Vespa',       referenceCode: 'VSP-PN-110-70-11',  totalQuantitySold: 18, totalRevenue: 12960),
    BestSellingProduct(productName: 'Kit Transmission – Vespa GTS 300',   referenceCode: 'VSP-CH-GTS300',     totalQuantitySold: 12, totalRevenue: 11400),
  ];

  // ─── HELPER: build StatisticsEntity ─────────────────────────────────

  StatisticsEntity _buildStats({
    required double revenue,
    required double cost,
    required int sales,
    double revenueGrowth = 9.5,
    double salesGrowth = 8.2,
    double profitGrowth = 11.3,
  }) {
    return StatisticsEntity(
      totalRevenue: revenue,
      totalPurchaseCost: cost,
      netProfit: revenue - cost,
      totalSales: sales,
      totalProducts: 20,
      lowStockCount: 3,
      outOfStockCount: 2,
      salesOverTime: _buildDailyTrend(),
      profitOverTime: _buildDailyProfit(),
      bestSellingProducts: _bestSellers,
      averageOrderValue: revenue / (sales > 0 ? sales : 1),
      profitMarginPercent: ((revenue - cost) / revenue) * 100,
      revenueGrowthPercent: revenueGrowth,
      salesGrowthPercent: salesGrowth,
      profitGrowthPercent: profitGrowth,
      salesByCategory: _categories,
      monthlySalesData: _monthly,
    );
  }

  // ─── StatisticsRepository IMPLEMENTATION ─────────────────────────────

  @override
  Future<Either<Failure, StatisticsEntity>> getOverallStatistics() async {
    await _delay();
    return Right(_buildStats(revenue: 251500, cost: 165200, sales: 687));
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatisticsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _delay();
    return Right(_buildStats(revenue: 62800, cost: 41400, sales: 171));
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getDailyStatistics() async {
    await _delay();
    return Right(_buildStats(revenue: 1870, cost: 1230, sales: 5,
        revenueGrowth: 14.2, salesGrowth: 11.5, profitGrowth: 17.8));
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getMonthlyStatistics() async {
    await _delay();
    return Right(_buildStats(revenue: 38100, cost: 25200, sales: 82,
        revenueGrowth: 9.8, salesGrowth: 10.8, profitGrowth: 12.2));
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getYearlyStatistics() async {
    await _delay();
    return Right(_buildStats(revenue: 251500, cost: 165200, sales: 687));
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatisticsForMonth({
    required int year,
    required int month,
  }) async {
    await _delay();
    try {
      final data = _monthly.firstWhere(
          (m) => m.year == year && m.month == month);
      return Right(_buildStats(
          revenue: data.revenue,
          cost: data.revenue - data.profit,
          sales: data.salesCount));
    } catch (_) {
      return Right(_buildStats(revenue: 28000, cost: 18500, sales: 60));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatsForLastNDays(
      int days) async {
    await _delay();
    final factor = days / 30.0;
    return Right(_buildStats(
      revenue: (38100 * factor).roundToDouble(),
      cost: (25200 * factor).roundToDouble(),
      sales: (82 * factor).round(),
    ));
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────
  Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 400));
}
