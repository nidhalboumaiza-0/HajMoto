import 'package:dartz/dartz.dart';
import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/error/exceptions.dart';
import 'package:gestion_stock/core/error/failures.dart';
import 'package:gestion_stock/core/network/dio_client.dart';
import 'package:gestion_stock/features/dashboard/domain/entities/statistics_entity.dart';
import 'package:gestion_stock/features/dashboard/domain/repositories/statistics_repository.dart';

/// Statistics Repository Implementation
/// Aggregates data from sales and products tables for dashboard
/// Computes growth indicators, category breakdowns, and monthly trends
class StatisticsRepositoryImpl implements StatisticsRepository {
  final DioClient _client;

  StatisticsRepositoryImpl(this._client);

  @override
  Future<Either<Failure, StatisticsEntity>> getOverallStatistics() async {
    try {
      final stats = await _fetchStatistics();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getDailyStatistics() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final previousStart = startOfDay.subtract(const Duration(days: 1));
      final stats = await _fetchStatistics(
        startDate: startOfDay,
        endDate: endOfDay,
        previousStartDate: previousStart,
        previousEndDate: startOfDay,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getMonthlyStatistics() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1);
      final previousStart = DateTime(now.year, now.month - 1, 1);
      final stats = await _fetchStatistics(
        startDate: startOfMonth,
        endDate: endOfMonth,
        previousStartDate: previousStart,
        previousEndDate: startOfMonth,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getYearlyStatistics() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year + 1, 1, 1);
      final previousStart = DateTime(now.year - 1, 1, 1);
      final stats = await _fetchStatistics(
        startDate: startOfYear,
        endDate: endOfYear,
        previousStartDate: previousStart,
        previousEndDate: startOfYear,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatisticsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final duration = endDate.difference(startDate);
      final previousStart = startDate.subtract(duration);
      final stats = await _fetchStatistics(
        startDate: startDate,
        endDate: endDate,
        previousStartDate: previousStart,
        previousEndDate: startDate,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatisticsForMonth({
    required int year,
    required int month,
  }) async {
    try {
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1);
      final previousStart = DateTime(year, month - 1, 1);
      final stats = await _fetchStatistics(
        startDate: startOfMonth,
        endDate: endOfMonth,
        previousStartDate: previousStart,
        previousEndDate: startOfMonth,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getStatsForLastNDays(int days) async {
    try {
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month, now.day + 1);
      final startDate = endDate.subtract(Duration(days: days));
      final previousStart = startDate.subtract(Duration(days: days));
      final stats = await _fetchStatistics(
        startDate: startDate,
        endDate: endDate,
        previousStartDate: previousStart,
        previousEndDate: startDate,
      );
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // ─── Core Fetch Logic ────────────────────────────────────────────────

  /// Fetches statistics for a period and optionally compares with previous period.
  /// Computes growth percentages, category breakdowns, and monthly trends.
  Future<StatisticsEntity> _fetchStatistics({
    DateTime? startDate,
    DateTime? endDate,
    DateTime? previousStartDate,
    DateTime? previousEndDate,
  }) async {
    try {
      // Fetch sales for current period
      final salesData = await _fetchSalesData(startDate: startDate, endDate: endDate);

      // Fetch sales for previous period (for growth comparison)
      List<dynamic> previousSalesData = [];
      if (previousStartDate != null && previousEndDate != null) {
        previousSalesData = await _fetchSalesData(
          startDate: previousStartDate,
          endDate: previousEndDate,
        );
      }

      // Fetch all sales for monthly trend (last 12 months)
      final now = DateTime.now();
      final twelveMonthsAgo = DateTime(now.year - 1, now.month, 1);
      final allRecentSales = await _fetchSalesData(
        startDate: twelveMonthsAgo,
        endDate: DateTime(now.year, now.month + 1, 1),
      );

      // Fetch products data for stock info + category mapping
      final productsData = await _client.getAll(AppConstants.productsTable);

      // Build category map from products: reference_code -> category
      final Map<String, String> refToCategory = {};
      for (final product in productsData) {
        final ref = product['reference_code'] as String? ?? '';
        final cat = product['category'] as String? ?? 'Uncategorized';
        if (ref.isNotEmpty) refToCategory[ref] = cat;
      }

      // ─── Current Period Aggregates ───────────────────────────────
      final currentAgg = _aggregateSales(salesData, refToCategory);

      // ─── Previous Period Aggregates ──────────────────────────────
      final previousAgg = _aggregateSales(previousSalesData, refToCategory);

      // ─── Growth Percentages ──────────────────────────────────────
      final revenueGrowth = _calcGrowthPercent(currentAgg.revenue, previousAgg.revenue);
      final salesGrowth = _calcGrowthPercent(
        currentAgg.salesCount.toDouble(),
        previousAgg.salesCount.toDouble(),
      );
      final profitGrowth = _calcGrowthPercent(currentAgg.profit, previousAgg.profit);

      // ─── Stock Stats ─────────────────────────────────────────────
      int lowStockCount = 0;
      int outOfStockCount = 0;
      for (final product in productsData) {
        final qty = product['quantity'] as int;
        final threshold = product['low_stock_threshold'] as int? ?? 5;
        if (qty <= 0) {
          outOfStockCount++;
        } else if (qty <= threshold) {
          lowStockCount++;
        }
      }

      // ─── Sales Over Time (group by day) ──────────────────────────
      final Map<String, double> salesByDay = {};
      final Map<String, double> profitByDay = {};
      for (final sale in salesData) {
        final date = DateTime.parse(sale['created_at'] as String);
        final dayKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final totalWithoutTVA = (sale['total_without_tva'] as num).toDouble();
        final purchasePrice = (sale['purchase_price'] as num).toDouble();
        final qty = sale['quantity'] as int;

        salesByDay[dayKey] = (salesByDay[dayKey] ?? 0) + totalWithoutTVA;
        profitByDay[dayKey] = (profitByDay[dayKey] ?? 0) + (totalWithoutTVA - purchasePrice * qty);
      }

      final salesOverTime = salesByDay.entries.map((e) {
        return SalesDataPoint(date: DateTime.parse(e.key), value: e.value);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final profitOverTime = profitByDay.entries.map((e) {
        return SalesDataPoint(date: DateTime.parse(e.key), value: e.value);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // ─── Monthly Sales Data (last 12 months) ────────────────────
      final Map<String, _MonthlyAgg> monthlyMap = {};
      for (final sale in allRecentSales) {
        final date = DateTime.parse(sale['created_at'] as String);
        final key = '${date.year}-${date.month}';
        final totalWithoutTVA = (sale['total_without_tva'] as num).toDouble();
        final purchasePrice = (sale['purchase_price'] as num).toDouble();
        final qty = sale['quantity'] as int;

        if (!monthlyMap.containsKey(key)) {
          monthlyMap[key] = _MonthlyAgg(year: date.year, month: date.month);
        }
        monthlyMap[key]!.revenue += totalWithoutTVA;
        monthlyMap[key]!.profit += totalWithoutTVA - purchasePrice * qty;
        monthlyMap[key]!.salesCount++;
      }

      final monthlySalesData = monthlyMap.values.map((m) {
        return MonthlySalesData(
          year: m.year,
          month: m.month,
          revenue: m.revenue,
          profit: m.profit,
          salesCount: m.salesCount,
        );
      }).toList()
        ..sort((a, b) {
          final cmp = a.year.compareTo(b.year);
          return cmp != 0 ? cmp : a.month.compareTo(b.month);
        });

      // ─── Category Breakdown ──────────────────────────────────────
      final List<CategorySalesData> salesByCategory = currentAgg.categoryMap.entries.map((e) {
        return CategorySalesData(
          category: e.key,
          revenue: e.value['revenue'] as double,
          quantity: e.value['quantity'] as int,
          profit: e.value['profit'] as double,
        );
      }).toList()
        ..sort((a, b) => b.revenue.compareTo(a.revenue));

      // ─── Best Selling Products ───────────────────────────────────
      final bestSelling = currentAgg.productMap.values.map((data) {
        return BestSellingProduct(
          productName: data['name'] as String,
          referenceCode: data['referenceCode'] as String,
          totalQuantitySold: data['totalQty'] as int,
          totalRevenue: data['totalRevenue'] as double,
        );
      }).toList()
        ..sort((a, b) => b.totalQuantitySold.compareTo(a.totalQuantitySold));

      // ─── Derived Metrics ─────────────────────────────────────────
      final avgOrderValue = currentAgg.salesCount > 0
          ? currentAgg.revenue / currentAgg.salesCount
          : 0.0;
      final profitMargin = currentAgg.revenue > 0
          ? (currentAgg.profit / currentAgg.revenue) * 100
          : 0.0;

      return StatisticsEntity(
        totalRevenue: currentAgg.revenue,
        totalPurchaseCost: currentAgg.cost,
        netProfit: currentAgg.profit,
        totalSales: currentAgg.salesCount,
        totalProducts: productsData.length,
        lowStockCount: lowStockCount,
        outOfStockCount: outOfStockCount,
        salesOverTime: salesOverTime,
        profitOverTime: profitOverTime,
        bestSellingProducts: bestSelling.take(10).toList(),
        averageOrderValue: avgOrderValue,
        profitMarginPercent: profitMargin,
        revenueGrowthPercent: revenueGrowth,
        salesGrowthPercent: salesGrowth,
        profitGrowthPercent: profitGrowth,
        salesByCategory: salesByCategory,
        monthlySalesData: monthlySalesData,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to fetch statistics: ${e.toString()}');
    }
  }

  /// Fetch sales records with optional date filtering
  Future<List<dynamic>> _fetchSalesData({DateTime? startDate, DateTime? endDate}) async {
    final params = <String, dynamic>{'order': 'created_at.asc'};
    if (startDate != null && endDate != null) {
      params['and'] =
          '(created_at.gte.${startDate.toIso8601String()},created_at.lte.${endDate.toIso8601String()})';
    } else if (startDate != null) {
      params['created_at'] = 'gte.${startDate.toIso8601String()}';
    } else if (endDate != null) {
      params['created_at'] = 'lte.${endDate.toIso8601String()}';
    }
    return _client.getAll(AppConstants.salesTable, queryParameters: params);
  }

  /// Aggregate a list of sales into totals, product map, and category map
  _SalesAggregate _aggregateSales(
    List<dynamic> salesData,
    Map<String, String> refToCategory,
  ) {
    double revenue = 0;
    double cost = 0;
    final Map<String, Map<String, dynamic>> productMap = {};
    final Map<String, Map<String, dynamic>> categoryMap = {};

    for (final sale in salesData) {
      final totalWithoutTVA = (sale['total_without_tva'] as num).toDouble();
      final purchasePrice = (sale['purchase_price'] as num).toDouble();
      final qty = sale['quantity'] as int;
      final saleProfit = totalWithoutTVA - purchasePrice * qty;

      revenue += totalWithoutTVA;
      cost += purchasePrice * qty;

      // Product tracking
      final productName = sale['product_name'] as String? ?? 'Unknown';
      final refCode = sale['reference_code'] as String? ?? '';
      if (productMap.containsKey(refCode)) {
        productMap[refCode]!['totalQty'] += qty;
        productMap[refCode]!['totalRevenue'] += totalWithoutTVA;
      } else {
        productMap[refCode] = {
          'name': productName,
          'referenceCode': refCode,
          'totalQty': qty,
          'totalRevenue': totalWithoutTVA,
        };
      }

      // Category tracking
      final category = refToCategory[refCode] ?? 'Uncategorized';
      if (categoryMap.containsKey(category)) {
        categoryMap[category]!['revenue'] += totalWithoutTVA;
        categoryMap[category]!['quantity'] += qty;
        categoryMap[category]!['profit'] += saleProfit;
      } else {
        categoryMap[category] = {
          'revenue': totalWithoutTVA,
          'quantity': qty,
          'profit': saleProfit,
        };
      }
    }

    return _SalesAggregate(
      revenue: revenue,
      cost: cost,
      profit: revenue - cost,
      salesCount: salesData.length,
      productMap: productMap,
      categoryMap: categoryMap,
    );
  }

  /// Calculate growth percentage between current and previous values
  double _calcGrowthPercent(double current, double previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous.abs()) * 100;
  }
}

// ─── Helper Classes ──────────────────────────────────────────────────

class _SalesAggregate {
  final double revenue;
  final double cost;
  final double profit;
  final int salesCount;
  final Map<String, Map<String, dynamic>> productMap;
  final Map<String, Map<String, dynamic>> categoryMap;

  _SalesAggregate({
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.salesCount,
    required this.productMap,
    required this.categoryMap,
  });
}

class _MonthlyAgg {
  final int year;
  final int month;
  double revenue = 0;
  double profit = 0;
  int salesCount = 0;

  _MonthlyAgg({required this.year, required this.month});
}
