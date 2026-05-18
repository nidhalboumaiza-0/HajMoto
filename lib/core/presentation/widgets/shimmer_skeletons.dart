import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BASE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] in a shimmer sweep using the app's color palette.
class _ShimmerWrap extends StatelessWidget {
  const _ShimmerWrap({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E9F0),
      highlightColor: const Color(0xFFF8FAFC),
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

/// A plain shimmer placeholder box.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius,
    this.color = Colors.white,
  });

  final double width;
  final double height;
  final double? radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? 6.r),
      ),
    );
  }
}

/// A shimmer text stand-in of given width and implicit height.
class ShimmerText extends StatelessWidget {
  const ShimmerText({super.key, required this.width, this.height});
  final double width;
  final double? height;

  @override
  Widget build(BuildContext context) =>
      ShimmerBox(width: width, height: height ?? 12.h, radius: 4.r);
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTS TABLE SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Mimics the products DataTable:
/// Référence | Nom | Catégorie | Achat | Vente | Stock | État | Actions
class ProductsTableShimmer extends StatelessWidget {
  const ProductsTableShimmer({super.key, this.rowCount = 10});
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    // ✅ Card stays white (outside shimmer). Shimmer only affects the shapes inside.
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _ShimmerWrap(
        child: Column(
          children: [
            _headerRow(),
            Divider(height: 1, color: Colors.grey.shade200),
            ...List.generate(rowCount, (i) => _dataRow(i)),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(
        children: [
          ShimmerBox(width: 100.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 130.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 90.w, height: 10.h),
          const Spacer(),
          ShimmerBox(width: 60.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 60.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 40.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 60.w, height: 10.h),
          SizedBox(width: 24.w),
          ShimmerBox(width: 60.w, height: 10.h),
        ],
      ),
    );
  }

  Widget _dataRow(int index) {
    // ✅ Padding (transparent) → white card bg shows through gaps between shapes
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      child: Row(
        children: [
          // Reference (monospace pill)
          ShimmerBox(width: 110.w, height: 14.h, radius: 4.r),
          SizedBox(width: 16.w),
          // Icon beside reference
          ShimmerBox(width: 16.w, height: 16.h, radius: 4.r),
          SizedBox(width: 16.w),
          // Name
          ShimmerBox(width: 130.w, height: 12.h),
          SizedBox(width: 16.w),
          // Category chip
          ShimmerBox(width: 80.w, height: 22.h, radius: 20.r),
          const Spacer(),
          // Achat
          ShimmerBox(width: 70.w, height: 12.h),
          SizedBox(width: 32.w),
          // Vente
          ShimmerBox(width: 70.w, height: 12.h),
          SizedBox(width: 32.w),
          // Stock number
          ShimmerBox(width: 28.w, height: 14.h),
          SizedBox(width: 32.w),
          // Status badge
          ShimmerBox(width: 72.w, height: 24.h, radius: 20.r),
          SizedBox(width: 24.w),
          // Edit icon
          ShimmerBox(width: 22.w, height: 22.h, radius: 4.r),
          SizedBox(width: 8.w),
          // Delete icon
          ShimmerBox(width: 22.w, height: 22.h, radius: 4.r),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INVOICES TABLE SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Mimics: N° Facture | Date | Client | CIN | Articles | Total TTC | Actions
class InvoicesTableShimmer extends StatelessWidget {
  const InvoicesTableShimmer({super.key, this.rowCount = 10});
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _ShimmerWrap(
        child: Column(
          children: [
            _headerRow(),
            Divider(height: 1, color: Colors.grey.shade200),
            ...List.generate(rowCount, (i) => _dataRow(i)),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
      child: Row(children: [
        ShimmerBox(width: 110.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 90.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 90.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 70.w, height: 10.h),
        const Spacer(),
        ShimmerBox(width: 110.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 80.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 60.w, height: 10.h),
      ]),
    );
  }

  Widget _dataRow(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 16.w),
      child: Row(children: [
        // Invoice number (bold navy)
        ShimmerBox(width: 120.w, height: 13.h, radius: 4.r),
        SizedBox(width: 24.w),
        // Date
        ShimmerBox(width: 90.w, height: 12.h),
        SizedBox(width: 24.w),
        // Client name
        ShimmerBox(width: 100.w, height: 12.h),
        SizedBox(width: 24.w),
        // CIN
        ShimmerBox(width: 70.w, height: 12.h),
        const Spacer(),
        // Articles column (2 lines)
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 120.w, height: 12.h),
          SizedBox(height: 4.h),
          ShimmerBox(width: 60.w, height: 10.h),
        ]),
        SizedBox(width: 32.w),
        // Total TTC (green bold)
        ShimmerBox(width: 80.w, height: 14.h, radius: 4.r),
        SizedBox(width: 32.w),
        // Print icon
        ShimmerBox(width: 28.w, height: 28.h, radius: 6.r),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// 4 stat cards + area chart + (bar chart + pie chart) + best-sellers table
class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ No single shimmer wrapping everything — each card has its own shimmer
    //    so the card white background stays white, and only shapes inside shimmer
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(children: [
            _statCard(),
            SizedBox(width: 12.w),
            _statCard(),
            SizedBox(width: 12.w),
            _statCard(),
            SizedBox(width: 12.w),
            _statCard(),
          ]),
          SizedBox(height: 20.h),
          _chartCard(height: 200.h),
          SizedBox(height: 20.h),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: _chartCard(height: 220.h)),
            SizedBox(width: 16.w),
            Expanded(flex: 2, child: _chartCard(height: 220.h)),
          ]),
          SizedBox(height: 20.h),
          _bestSellersCard(),
        ],
      ),
    );
  }

  Widget _statCard() {
    return Expanded(
      child: Container(
        // ✅ White card OUTSIDE shimmer — no fixed height, auto-sized by content
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: _ShimmerWrap(
          // ✅ Shimmer wraps only the shapes inside
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ShimmerBox(width: 36.w, height: 36.h, radius: 10.r),
              const Spacer(),
              ShimmerBox(width: 50.w, height: 20.h, radius: 10.r),
            ]),
            SizedBox(height: 10.h),
            ShimmerBox(width: 80.w, height: 10.h),
            SizedBox(height: 8.h),
            ShimmerBox(width: 110.w, height: 18.h),
            SizedBox(height: 6.h),
            ShimmerBox(width: 70.w, height: 9.h),
          ]),
        ),
      ),
    );
  }

  Widget _chartCard({required double height}) {
    return Container(
      height: height,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _ShimmerWrap(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 160.w, height: 14.h),
          SizedBox(height: 6.h),
          ShimmerBox(width: 100.w, height: 10.h),
          SizedBox(height: 16.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final heights = [0.45, 0.6, 0.35, 0.75, 0.55, 0.8, 0.5, 0.65, 0.4, 0.9, 0.7, 0.6];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: (height - 80.h) * heights[i % heights.length],
                      radius: 4.r,
                    ),
                  ),
                );
              }),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _bestSellersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(18.w),
      child: _ShimmerWrap(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 160.w, height: 14.h),
          SizedBox(height: 16.h),
          ...List.generate(5, (i) => _tableRow(i)),
        ]),
      ),
    );
  }

  Widget _tableRow(int i) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(children: [
        ShimmerBox(width: 24.w, height: 24.h, radius: 12.r),
        SizedBox(width: 12.w),
        ShimmerBox(width: 100.w + (i * 8.0).w, height: 12.h),
        const Spacer(),
        ShimmerBox(width: 50.w, height: 12.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 60.w, height: 24.h, radius: 6.r),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATISTICS PAGE SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// 4 summary cards + big bar chart + line chart + category pie
class StatisticsShimmer extends StatelessWidget {
  const StatisticsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Row(children: [
            _summaryCard(),
            SizedBox(width: 12.w),
            _summaryCard(),
            SizedBox(width: 12.w),
            _summaryCard(),
            SizedBox(width: 12.w),
            _summaryCard(),
          ]),
          SizedBox(height: 20.h),
          _chartBlock(height: 250.h),
          SizedBox(height: 20.h),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 3, child: _chartBlock(height: 220.h)),
            SizedBox(width: 16.w),
            Expanded(flex: 2, child: _chartBlock(height: 220.h)),
          ]),
          SizedBox(height: 20.h),
          _chartBlock(height: 160.h),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Expanded(
      child: Container(
        // no fixed height — auto-sized by content
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: _ShimmerWrap(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ShimmerBox(width: 32.w, height: 32.h, radius: 8.r),
              const Spacer(),
              ShimmerBox(width: 40.w, height: 18.h, radius: 8.r),
            ]),
            SizedBox(height: 8.h),
            ShimmerBox(width: 70.w, height: 10.h),
            SizedBox(height: 6.h),
            ShimmerBox(width: 100.w, height: 16.h),
          ]),
        ),
      ),
    );
  }

  Widget _chartBlock({required double height}) {
    return Container(
      height: height,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: _ShimmerWrap(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ShimmerBox(width: 150.w, height: 13.h),
          SizedBox(height: 6.h),
          ShimmerBox(width: 90.w, height: 10.h),
          SizedBox(height: 18.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(8, (i) {
                final h = [0.5, 0.7, 0.4, 0.85, 0.55, 0.75, 0.6, 0.9][i];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ShimmerBox(
                      width: double.infinity,
                      height: (height - 90.h) * h,
                      radius: 4.r,
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              8,
              (_) => ShimmerBox(width: 30.w, height: 8.h),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SALES HISTORY SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Mimics the sales history tab: stats row + table rows
class SalesHistoryShimmer extends StatelessWidget {
  const SalesHistoryShimmer({super.key, this.rowCount = 8});
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Summary pills row — each pill card is OUTSIDE shimmer
        Row(children: [
          _summaryPill(),
          SizedBox(width: 12.w),
          _summaryPill(),
          SizedBox(width: 12.w),
          _summaryPill(),
        ]),
        SizedBox(height: 16.h),
        // Table card — white container OUTSIDE shimmer
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: _ShimmerWrap(
              child: Column(
                children: [
                  _headerRow(),
                  Divider(height: 1, color: Colors.grey.shade200),
                  ...List.generate(rowCount, (i) => _dataRow(i)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryPill() {
    return Expanded(
      child: Container(
        // ✅ Card outside shimmer
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: _ShimmerWrap(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(width: 70.w, height: 10.h),
              SizedBox(height: 6.h),
              ShimmerBox(width: 90.w, height: 14.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(children: [
        ShimmerBox(width: 80.w, height: 10.h),
        SizedBox(width: 16.w),
        ShimmerBox(width: 80.w, height: 10.h),
        const Spacer(),
        ShimmerBox(width: 100.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 60.w, height: 10.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 60.w, height: 10.h),
      ]),
    );
  }

  Widget _dataRow(int index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(children: [
        ShimmerBox(width: 80.w, height: 12.h),
        SizedBox(width: 16.w),
        ShimmerBox(width: 90.w, height: 12.h),
        const Spacer(),
        ShimmerBox(width: 110.w, height: 12.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 50.w, height: 12.h),
        SizedBox(width: 24.w),
        ShimmerBox(width: 70.w, height: 24.h, radius: 6.r),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORIES SKELETON
// ─────────────────────────────────────────────────────────────────────────────

/// Mimics the categories list: color dot + name + edit/delete
class CategoriesShimmer extends StatelessWidget {
  const CategoriesShimmer({super.key, this.itemCount = 8});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    // ✅ ONE shimmer = synchronized sweep across all tiles.
    // Tiles use Padding (transparent) → the dialog's white background shows
    // through the gaps, so each individual shape (circle, text lines, buttons)
    // is clearly visible as a grey box on white.
    return _ShimmerWrap(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, i) => _categoryTile(i),
      ),
    );
  }

  Widget _categoryTile(int index) {
    final titleWidths = [98.0, 118.0, 84.0, 108.0, 94.0, 78.0, 112.0, 100.0];
    final titleW = titleWidths[index % titleWidths.length];
    // ✅ Padding → transparent background → white dialog bg shows through gaps
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Row(
        children: [
          // Leading: CircleAvatar shape
          Container(
            width: 34.w,
            height: 34.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 14.w),
          // Title + subtitle (slug)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: titleW.w, height: 13.h),
                SizedBox(height: 5.h),
                ShimmerBox(width: (titleW * 0.65).w, height: 10.h),
              ],
            ),
          ),
          // Color swatch circle
          Container(
            width: 20.w,
            height: 20.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          // Edit icon button
          ShimmerBox(width: 30.w, height: 30.h, radius: 6.r),
          SizedBox(width: 4.w),
          // Delete icon button
          ShimmerBox(width: 30.w, height: 30.h, radius: 6.r),
        ],
      ),
    );
  }
}
