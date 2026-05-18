import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

// ─── Base shimmer colors ──────────────────────────────────────────────────────
const _baseColor = Color(0xFFE8ECF0);
const _highlightColor = Color(0xFFF8FAFC);

// ─── Primitives ───────────────────────────────────────────────────────────────

/// A single shimmer rectangle.
class _SBox extends StatelessWidget {
  const _SBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// A shimmer "text line" with natural text proportions.
class _SText extends StatelessWidget {
  const _SText({required this.width, this.height = 13});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) =>
      _SBox(width: width, height: height, radius: 5);
}

// ─── Public wrapper ───────────────────────────────────────────────────────────

/// Wraps [child] in a shimmer animation.
class AppShimmerWrap extends StatelessWidget {
  const AppShimmerWrap({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTS / INVOICES TABLE  (generic DataTable skeleton)
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerProductsTable extends StatelessWidget {
  const ShimmerProductsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table header row
          _tableHeader(const [130, 160, 90, 70, 70, 50, 80, 60]),
          const Divider(height: 1),
          // 9 data rows
          ...List.generate(
            9,
            (i) => Column(
              children: [
                _productRow(i),
                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productRow(int i) {
    final nameLengths  = [120.0, 140.0, 100.0, 130.0, 110.0, 145.0, 118.0, 135.0, 105.0];
    final nameW = nameLengths[i % nameLengths.length];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          // reference
          _SText(width: 110.w),
          SizedBox(width: 30.w),
          // name
          _SText(width: nameW.w),
          SizedBox(width: 30.w),
          // category chip
          _SBox(width: 72.w, height: 22.h, radius: 10),
          SizedBox(width: 30.w),
          // achat
          _SText(width: 55.w),
          SizedBox(width: 30.w),
          // vente
          _SText(width: 55.w),
          SizedBox(width: 30.w),
          // stock
          _SText(width: 28.w),
          SizedBox(width: 40.w),
          // état badge
          _SBox(width: 68.w, height: 22.h, radius: 10),
          SizedBox(width: 30.w),
          // actions
          _SBox(width: 22.w, height: 22.h, radius: 4),
          SizedBox(width: 10.w),
          _SBox(width: 22.w, height: 22.h, radius: 4),
        ],
      ),
    );
  }
}

class ShimmerInvoicesTable extends StatelessWidget {
  const ShimmerInvoicesTable({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tableHeader(const [110, 110, 100, 70, 120, 80, 40]),
          const Divider(height: 1),
          ...List.generate(
            9,
            (i) => Column(
              children: [
                _invoiceRow(i),
                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _invoiceRow(int i) {
    final clientW = [90.0, 100.0, 80.0, 110.0, 95.0, 85.0, 105.0, 92.0, 98.0];
    final articleW = [100.0, 130.0, 95.0, 118.0, 88.0, 125.0, 108.0, 95.0, 115.0];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          // N° facture
          _SText(width: 120.w, height: 13),
          SizedBox(width: 18.w),
          // date
          _SText(width: 100.w),
          SizedBox(width: 18.w),
          // client
          _SText(width: clientW[i % clientW.length].w),
          SizedBox(width: 18.w),
          // CIN
          _SText(width: 65.w),
          SizedBox(width: 18.w),
          // articles column (2 lines)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SText(width: articleW[i % articleW.length].w),
              SizedBox(height: 4.h),
              _SText(width: 50.w, height: 10),
            ],
          ),
          SizedBox(width: 18.w),
          // total TTC
          _SText(width: 72.w, height: 14),
          SizedBox(width: 18.w),
          // action icon
          _SBox(width: 24.w, height: 24.h, radius: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerDashboard extends StatelessWidget {
  const ShimmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerWrap(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 4 KPI cards
            Row(
              children: List.generate(4, (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 12.w : 0),
                  child: _kpiCard(),
                ),
              )),
            ),
            SizedBox(height: 20.h),
            // Area chart card
            _chartCard(height: 200.h),
            SizedBox(height: 20.h),
            // Monthly + category row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _chartCard(height: 180.h)),
                SizedBox(width: 16.w),
                Expanded(flex: 2, child: _chartCard(height: 180.h)),
              ],
            ),
            SizedBox(height: 20.h),
            // Best sellers table card
            _bestSellersCard(),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SBox(width: 40.w, height: 40.h, radius: 10),
              _SBox(width: 44.w, height: 20.h, radius: 10),
            ],
          ),
          SizedBox(height: 14.h),
          _SText(width: 80.w, height: 11),
          SizedBox(height: 8.h),
          _SText(width: 110.w, height: 20),
          SizedBox(height: 8.h),
          _SText(width: 90.w, height: 10),
        ],
      ),
    );
  }

  Widget _chartCard({required double height}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      height: height + 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SText(width: 130.w, height: 14),
              _SText(width: 70.w, height: 11),
            ],
          ),
          SizedBox(height: 20.h),
          // Chart bars skeleton
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                12,
                (i) {
                  final heights = [0.5, 0.7, 0.4, 0.8, 0.6, 0.9, 0.5, 0.75, 0.65, 0.85, 0.55, 0.7];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (height * heights[i]).h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4.r)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bestSellersCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SText(width: 140.w, height: 14),
          SizedBox(height: 16.h),
          ...List.generate(5, (i) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                _SBox(width: 24.w, height: 24.h, radius: 4),
                SizedBox(width: 12.w),
                Expanded(child: _SText(width: 160.w)),
                _SText(width: 50.w),
                SizedBox(width: 24.w),
                _SText(width: 70.w),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATISTICS
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerStatistics extends StatelessWidget {
  const ShimmerStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerWrap(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 4 summary cards
            Row(
              children: List.generate(4, (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 3 ? 12.w : 0),
                  child: Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _SText(width: 70.w, height: 11),
                            _SBox(width: 28.w, height: 28.h, radius: 8),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        _SText(width: 100.w, height: 20),
                        SizedBox(height: 6.h),
                        _SText(width: 75.w, height: 10),
                      ],
                    ),
                  ),
                ),
              )),
            ),
            SizedBox(height: 20.h),
            // Big revenue bar chart
            _statChart(height: 220.h, bars: 7),
            SizedBox(height: 20.h),
            // Two smaller charts
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _statChart(height: 170.h, bars: 5)),
                SizedBox(width: 16.w),
                Expanded(flex: 3, child: _statChart(height: 170.h, bars: 6)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChart({required double height, required int bars}) {
    return Container(
      padding: EdgeInsets.all(20.w),
      height: height + 60.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SText(width: 120.w, height: 14),
          SizedBox(height: 20.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(bars, (i) {
                final h = [0.8, 0.55, 0.9, 0.65, 0.75, 0.5, 0.85][i % 7];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (height * h).h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(5.r)),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        _SText(width: 28.w, height: 9),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SALES HISTORY LIST
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerSalesList extends StatelessWidget {
  const ShimmerSalesList({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerWrap(
      child: Column(
        children: [
          // 4 summary stat cards
          Row(
            children: List.generate(4, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 12.w : 0),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SText(width: 80.w, height: 11),
                      SizedBox(height: 10.h),
                      _SText(width: 110.w, height: 19),
                    ],
                  ),
                ),
              ),
            )),
          ),
          SizedBox(height: 20.h),
          // Sales table card
          _shimmerCard(
            child: Column(
              children: [
                _tableHeader(const [120, 100, 90, 80, 80, 70]),
                const Divider(height: 1),
                ...List.generate(8, (i) => Column(
                  children: [
                    _salesRow(i),
                    Divider(height: 1, color: Colors.grey.shade100),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _salesRow(int i) {
    final clientWidths = [80.0, 100.0, 88.0, 95.0, 75.0, 110.0, 85.0, 92.0];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _SText(width: 95.w), SizedBox(width: 24.w),
          _SText(width: clientWidths[i % clientWidths.length].w), SizedBox(width: 24.w),
          _SBox(width: 68.w, height: 22.h, radius: 10), SizedBox(width: 24.w),
          _SText(width: 55.w), SizedBox(width: 24.w),
          _SText(width: 55.w), SizedBox(width: 24.w),
          _SText(width: 65.w, height: 14),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES LIST
// ─────────────────────────────────────────────────────────────────────────────

class ShimmerCategoryList extends StatelessWidget {
  const ShimmerCategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmerWrap(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, i) {
          final titleW = [90.0, 110.0, 80.0, 100.0, 95.0, 85.0][i];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
            child: Row(
              children: [
                // Circle avatar
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 14.w),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SText(width: titleW.w, height: 13),
                      SizedBox(height: 5.h),
                      _SText(width: (titleW * 0.7).w, height: 10),
                    ],
                  ),
                ),
                // Edit + delete icons
                _SBox(width: 24.w, height: 24.h, radius: 4),
                SizedBox(width: 10.w),
                _SBox(width: 24.w, height: 24.h, radius: 4),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers (private)
// ─────────────────────────────────────────────────────────────────────────────

Widget _shimmerCard({required Widget child}) {
  return AppShimmerWrap(
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    ),
  );
}

Widget _tableHeader(List<double> widths) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(14.r),
        topRight: Radius.circular(14.r),
      ),
    ),
    child: Row(
      children: widths.expand((w) => [
        _SText(width: w.w, height: 12),
        if (w != widths.last) SizedBox(width: 30.w),
      ]).toList(),
    ),
  );
}
