import 'package:equatable/equatable.dart';

/// Statistics Entity - Domain Layer
/// Aggregated business statistics with growth indicators and breakdowns
class StatisticsEntity extends Equatable {
  final double totalRevenue;
  final double totalPurchaseCost;
  final double netProfit;
  final int totalSales;
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final List<SalesDataPoint> salesOverTime;
  final List<SalesDataPoint> profitOverTime;
  final List<BestSellingProduct> bestSellingProducts;

  // Advanced fields
  final double averageOrderValue;
  final double profitMarginPercent;
  final double revenueGrowthPercent;
  final double salesGrowthPercent;
  final double profitGrowthPercent;
  final List<CategorySalesData> salesByCategory;
  final List<MonthlySalesData> monthlySalesData;

  const StatisticsEntity({
    required this.totalRevenue,
    required this.totalPurchaseCost,
    required this.netProfit,
    required this.totalSales,
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.salesOverTime,
    required this.profitOverTime,
    required this.bestSellingProducts,
    this.averageOrderValue = 0,
    this.profitMarginPercent = 0,
    this.revenueGrowthPercent = 0,
    this.salesGrowthPercent = 0,
    this.profitGrowthPercent = 0,
    this.salesByCategory = const [],
    this.monthlySalesData = const [],
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        totalPurchaseCost,
        netProfit,
        totalSales,
        totalProducts,
        lowStockCount,
        outOfStockCount,
        averageOrderValue,
        revenueGrowthPercent,
      ];
}

/// Data point for time-series charts
class SalesDataPoint extends Equatable {
  final DateTime date;
  final double value;

  const SalesDataPoint({required this.date, required this.value});

  @override
  List<Object?> get props => [date, value];
}

/// Best selling product data
class BestSellingProduct extends Equatable {
  final String productName;
  final String referenceCode;
  final int totalQuantitySold;
  final double totalRevenue;

  const BestSellingProduct({
    required this.productName,
    required this.referenceCode,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [productName, referenceCode, totalQuantitySold, totalRevenue];
}

/// Revenue breakdown by product category
class CategorySalesData extends Equatable {
  final String category;
  final double revenue;
  final int quantity;
  final double profit;

  const CategorySalesData({
    required this.category,
    required this.revenue,
    required this.quantity,
    required this.profit,
  });

  @override
  List<Object?> get props => [category, revenue, quantity, profit];
}

/// Monthly aggregated data for trend charts
class MonthlySalesData extends Equatable {
  final int year;
  final int month;
  final double revenue;
  final double profit;
  final int salesCount;

  const MonthlySalesData({
    required this.year,
    required this.month,
    required this.revenue,
    required this.profit,
    required this.salesCount,
  });

  String get label {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month - 1]} $year';
  }

  String get shortLabel {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [year, month, revenue, profit, salesCount];
}
