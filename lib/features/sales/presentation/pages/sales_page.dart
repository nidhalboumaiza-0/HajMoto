import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/app_snack_bar.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/sales/domain/entities/sale_entity.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_event.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_state.dart';
import 'package:gestion_stock/features/sales/presentation/widgets/sale_form.dart';
import 'package:gestion_stock/features/sales/presentation/widgets/invoice_preview_dialog.dart';

/// Sales Page - Create sales, view sales history filtered by month/period,
/// and see most sold products per selected timeframe
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ─── Period State ──────────────────────────────────────────────
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  bool _isCustomRange = false;
  DateTimeRange? _customRange;
  String _periodLabel = '';

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _loadFilteredSales();
      }
    });
    _periodLabel = '${_monthNames[_currentMonth - 1]} $_currentYear';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFilteredSales() {
    if (_isCustomRange && _customRange != null) {
      context.read<SaleBloc>().add(LoadSalesEvent(
            startDate: _customRange!.start,
            endDate: _customRange!.end.add(const Duration(days: 1)),
          ));
    } else {
      final start = DateTime(_currentYear, _currentMonth, 1);
      final end = DateTime(_currentYear, _currentMonth + 1, 1);
      context.read<SaleBloc>().add(LoadSalesEvent(startDate: start, endDate: end));
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _isCustomRange = false;
      _currentMonth--;
      if (_currentMonth < 1) {
        _currentMonth = 12;
        _currentYear--;
      }
      _periodLabel = '${_monthNames[_currentMonth - 1]} $_currentYear';
    });
    _loadFilteredSales();
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    if (_currentYear == now.year && _currentMonth >= now.month) return;
    setState(() {
      _isCustomRange = false;
      _currentMonth++;
      if (_currentMonth > 12) {
        _currentMonth = 1;
        _currentYear++;
      }
      _periodLabel = '${_monthNames[_currentMonth - 1]} $_currentYear';
    });
    _loadFilteredSales();
  }

  void _selectCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _customRange,
    );
    if (range != null && mounted) {
      setState(() {
        _isCustomRange = true;
        _customRange = range;
        _periodLabel =
            '${DateFormat('dd MMM yyyy').format(range.start)} – ${DateFormat('dd MMM yyyy').format(range.end)}';
      });
      _loadFilteredSales();
    }
  }

  void _switchToMonthMode() {
    setState(() {
      _isCustomRange = false;
      _currentMonth = DateTime.now().month;
      _currentYear = DateTime.now().year;
      _periodLabel = '${_monthNames[_currentMonth - 1]} $_currentYear';
    });
    _loadFilteredSales();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleCreatedState) {
          AppSnackBar.success(
            context,
            'Vente effectuée avec succès !',
            title: 'Vente validée',
          );
          showDialog(
            context: context,
            builder: (_) => InvoicePreviewDialog(
              invoice: state.invoice,
              client: state.client,
            ),
          );
        }
        if (state is SaleErrorState) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppPageHeader(
                title: 'Ventes',
                subtitle: 'Créer des ventes et consulter l\'historique',
              ),
              SizedBox(height: 20.h),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp),
                  unselectedLabelStyle:
                      TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 18.sp),
                          SizedBox(width: 8.w),
                          const Text('Nouvelle Vente'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, size: 18.sp),
                          SizedBox(width: 8.w),
                          const Text('Historique des Ventes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const SaleForm(),
                    _buildSalesHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Sales History Tab — with month nav, summary, most sold, table
  // ════════════════════════════════════════════════════════════════

  Widget _buildSalesHistoryTab() {
    return Column(
      children: [
        // ─── Period Controls ───────────────────────────────────
        _buildPeriodControls(),
        SizedBox(height: 16.h),

        // ─── Content (summary + table) ────────────────────────
        Expanded(
          child: BlocBuilder<SaleBloc, SaleState>(
            builder: (context, state) {
              if (state is SaleLoadingState) {
                return const SalesHistoryShimmer();
              }
              if (state is SaleEmptyState) {
                return AppEmptyState(
                  icon: Icons.receipt_long_outlined,
                  message: 'Aucune vente pour $_periodLabel',
                );
              }
              if (state is SalesLoadedState) {
                return _buildSalesContent(state.sales);
              }
              // Initial state — show a "load" prompt
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 48.sp, color: AppTheme.textSecondary),
                    SizedBox(height: 12.h),
                    Text(
                      'Sélectionnez une période pour voir les ventes',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: _loadFilteredSales,
                      child: const Text('Charger les Ventes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Period Navigation Bar ────────────────────────────────────

  Widget _buildPeriodControls() {
    final now = DateTime.now();
    final isCurrentMonth =
        _currentYear == now.year && _currentMonth == now.month;

    return Row(
      children: [
        if (!_isCustomRange) ...[
          // Month navigation
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _navButton(Icons.chevron_left_rounded, _goToPreviousMonth),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Text(
                    '${_monthNames[_currentMonth - 1]} $_currentYear',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                _navButton(
                  Icons.chevron_right_rounded,
                  isCurrentMonth ? null : _goToNextMonth,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),

          // Quick month jumps
          _buildQuickMonthChips(),
        ] else ...[
          // Custom range label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.date_range_rounded,
                    size: 18.sp, color: AppTheme.primaryColor),
                SizedBox(width: 8.w),
                Text(
                  _periodLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          TextButton.icon(
            onPressed: _switchToMonthMode,
            icon: Icon(Icons.calendar_month_rounded, size: 16.sp),
            label: const Text('Vue Mensuelle'),
          ),
        ],

        const Spacer(),

        // Custom date range button
        OutlinedButton.icon(
          onPressed: _selectCustomRange,
          icon: Icon(Icons.date_range_rounded, size: 16.sp),
          label: Text('Période Personnalisée', style: TextStyle(fontSize: 12.sp)),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          ),
        ),
      ],
    );
  }

  Widget _navButton(IconData icon, VoidCallback? onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            size: 22.sp,
            color: onTap != null ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMonthChips() {
    final now = DateTime.now();
    final quickMonths = <_QuickMonth>[];
    for (int i = 0; i < 3; i++) {
      var m = now.month - i;
      var y = now.year;
      if (m < 1) {
        m += 12;
        y--;
      }
      final label = i == 0
          ? 'Ce Mois'
          : i == 1
              ? 'Mois Dernier'
              : _monthNames[m - 1].substring(0, 3);
      quickMonths.add(_QuickMonth(y, m, label));
    }

    return Row(
      children: quickMonths.map((qm) {
        final isActive =
            !_isCustomRange && _currentMonth == qm.month && _currentYear == qm.year;
        return Padding(
          padding: EdgeInsets.only(right: 6.w),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
              onTap: () {
                setState(() {
                  _isCustomRange = false;
                  _currentMonth = qm.month;
                  _currentYear = qm.year;
                  _periodLabel = '${_monthNames[_currentMonth - 1]} $_currentYear';
                });
                _loadFilteredSales();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  qm.label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Sales Content (Summary + Most Sold + Table) ──────────────

  Widget _buildSalesContent(List<SaleEntity> sales) {
    // Compute summary aggregates
    final totalRevenue = sales.fold<double>(0, (s, e) => s + e.totalWithoutTVA);
    final totalProfit = sales.fold<double>(0, (s, e) => s + e.profit);
    final totalTVA = sales.fold<double>(0, (s, e) => s + e.tvaAmount);
    final totalTTC = sales.fold<double>(0, (s, e) => s + e.totalWithTVA);
    final avgOrder = sales.isNotEmpty ? totalRevenue / sales.length : 0.0;

    // Compute most sold products
    final Map<String, _ProductAgg> productMap = {};
    for (final sale in sales) {
      if (productMap.containsKey(sale.referenceCode)) {
        productMap[sale.referenceCode]!.totalQty += sale.quantity;
        productMap[sale.referenceCode]!.totalRevenue += sale.totalWithoutTVA;
        productMap[sale.referenceCode]!.totalProfit += sale.profit;
      } else {
        productMap[sale.referenceCode] = _ProductAgg(
          name: sale.productName,
          refCode: sale.referenceCode,
          totalQty: sale.quantity,
          totalRevenue: sale.totalWithoutTVA,
          totalProfit: sale.profit,
        );
      }
    }
    final mostSold = productMap.values.toList()
      ..sort((a, b) => b.totalQty.compareTo(a.totalQty));

    return SingleChildScrollView(
      child: Column(
        children: [
          // ─── Summary Cards (staggered animation) ──────────
          Row(
            children: [
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(0, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'Nombre de Ventes',
                    sales.length.toString(),
                    Icons.receipt_rounded,
                    AppTheme.accentColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(1, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'CA HT',
                    appCurrencyFormat.format(totalRevenue),
                    Icons.attach_money_rounded,
                    AppTheme.successColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(2, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'Bénéfice Net',
                    appCurrencyFormat.format(totalProfit),
                    Icons.trending_up_rounded,
                    AppTheme.secondaryColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(3, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'Total TVA',
                    appCurrencyFormat.format(totalTVA),
                    Icons.account_balance_rounded,
                    AppTheme.warningColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(4, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'Total TTC',
                    appCurrencyFormat.format(totalTTC),
                    Icons.payments_rounded,
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AnimatedFadeSlide(
                  delay: staggerDelay(5, baseMs: 60),
                  offset: const Offset(0, 30),
                  child: _miniSummaryCard(
                    'Commande Moy.',
                    appCurrencyFormat.format(avgOrder),
                    Icons.analytics_rounded,
                    const Color(0xFF8E44AD),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // ─── Most Sold Products + Sales Table ─────────────
          AnimatedFadeSlide(
            delay: staggerDelay(6, baseMs: 60),
            duration: const Duration(milliseconds: 700),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Most Sold Products
                SizedBox(
                  width: 320.w,
                  child: _buildMostSoldCard(mostSold),
                ),
                SizedBox(width: 16.w),
                // Sales Table
                Expanded(
                  child: _buildSalesTable(sales),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniSummaryCard(
      String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style:
                      TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Most Sold Products Card ──────────────────────────────────

  Widget _buildMostSoldCard(List<_ProductAgg> products) {
    return AppCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events_rounded,
                  size: 20.sp, color: AppTheme.accentColor),
              SizedBox(width: 8.w),
              Text(
                'Most Sold — $_periodLabel',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Produits classés par quantité vendue',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 16.h),
          if (products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(
                child: Text(
                  'Aucun produit vendu',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13.sp),
                ),
              ),
            )
          else
            ...products.take(10).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final product = entry.value;
              final maxQty = products.first.totalQty;
              final progress = maxQty > 0 ? product.totalQty / maxQty : 0.0;

              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Rank badge
                        Container(
                          width: 24.w,
                          height: 24.h,
                          decoration: BoxDecoration(
                            gradient: idx < 3
                                ? LinearGradient(
                                    colors: [
                                      [
                                        const Color(0xFFFFD700),
                                        const Color(0xFFFFA000)
                                      ],
                                      [
                                        const Color(0xFFC0C0C0),
                                        const Color(0xFF9E9E9E)
                                      ],
                                      [
                                        const Color(0xFFCD7F32),
                                        const Color(0xFFA0522D)
                                      ],
                                    ][idx],
                                  )
                                : null,
                            color: idx >= 3 ? Colors.grey.shade100 : null,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: idx < 3
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                                fontSize: 12.sp, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${product.totalQty} unités',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        SizedBox(width: 32.w), // align with text
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(
                                idx < 3
                                    ? AppTheme.accentColor
                                    : AppTheme.secondaryColor
                                        .withValues(alpha: 0.6),
                              ),
                              minHeight: 5.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          appCurrencyFormat.format(product.totalRevenue),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ─── Sales Table ──────────────────────────────────────────────

  Widget _buildSalesTable(List<SaleEntity> sales) {
    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Liste des Ventes',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 10.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${sales.length} ventes',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 44.h,
              dataRowMinHeight: 40.h,
              dataRowMaxHeight: 48.h,
              columnSpacing: 14.w,
              horizontalMargin: 12.w,
              columns: [
                DataColumn(
                    label:
                        Text('Date', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label:
                        Text('Référence', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label:
                        Text('Produit', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label: Text('Qté', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label:
                        Text('Total HT', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label: Text('TVA', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label:
                        Text('Total TTC', style: TextStyle(fontSize: 12.sp))),
                DataColumn(
                    label:
                        Text('Bénéfice', style: TextStyle(fontSize: 12.sp))),
              ],
              rows: sales.map((sale) {
                final profitColor = sale.profit >= 0
                    ? AppTheme.successColor
                    : AppTheme.dangerColor;
                return DataRow(cells: [
                  DataCell(Text(
                    appDateTimeFormat.format(sale.createdAt),
                    style: TextStyle(fontSize: 11.sp),
                  )),
                  DataCell(Text(
                    sale.referenceCode,
                    style: TextStyle(
                        fontSize: 11.sp, fontWeight: FontWeight.w500),
                  )),
                  DataCell(
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 130.w),
                      child: Text(
                        sale.productName,
                        style: TextStyle(fontSize: 11.sp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(
                    sale.quantity.toString(),
                    style: TextStyle(fontSize: 11.sp),
                  )),
                  DataCell(Text(
                    appCurrencyFormat.format(sale.totalWithoutTVA),
                    style: TextStyle(fontSize: 11.sp),
                  )),
                  DataCell(Text(
                    appCurrencyFormat.format(sale.tvaAmount),
                    style: TextStyle(
                        fontSize: 11.sp, color: AppTheme.textSecondary),
                  )),
                  DataCell(Text(
                    appCurrencyFormat.format(sale.totalWithTVA),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
                  )),
                  DataCell(Text(
                    appCurrencyFormat.format(sale.profit),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: profitColor,
                    ),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Classes ─────────────────────────────────────────────

class _QuickMonth {
  final int year;
  final int month;
  final String label;
  _QuickMonth(this.year, this.month, this.label);
}

class _ProductAgg {
  final String name;
  final String refCode;
  int totalQty;
  double totalRevenue;
  double totalProfit;

  _ProductAgg({
    required this.name,
    required this.refCode,
    required this.totalQty,
    required this.totalRevenue,
    required this.totalProfit,
  });
}
