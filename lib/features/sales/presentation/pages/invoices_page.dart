import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/app_snack_bar.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_entity.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_event.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_state.dart';
import 'package:gestion_stock/features/sales/presentation/widgets/invoice_pdf_generator.dart';
import 'package:printing/printing.dart';

/// Invoices Page - View and manage invoices
/// Shows all generated invoices with print/PDF functionality + client/date filters
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String _searchQuery = '';
  int _currentPage = 0;
  int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>().add(const LoadInvoicesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InvoiceEntity> _applyFilters(List<InvoiceEntity> invoices) {
    return invoices.where((inv) {
      // Client name filter (case-insensitive)
      if (_searchQuery.isNotEmpty) {
        if (!inv.clientName.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      // Date from filter
      if (_dateFrom != null) {
        if (inv.createdAt.isBefore(_dateFrom!)) return false;
      }
      // Date to filter (include the full day)
      if (_dateTo != null) {
        final endOfDay = DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day, 23, 59, 59);
        if (inv.createdAt.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _dateFrom : _dateTo) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
        } else {
          _dateTo = picked;
        }
        _currentPage = 0;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _dateFrom = null;
      _dateTo = null;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppPageHeader(
              title: 'Factures',
              subtitle: 'Voir et imprimer toutes les factures générées',
              trailing: ElevatedButton.icon(
                onPressed: () => context.read<SaleBloc>().add(const LoadInvoicesEvent()),
                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                label: const Text('Actualiser'),
              ),
            ),
            SizedBox(height: 16.h),

            // Filter bar
            AppCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  // Client name search
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom du client…',
                        prefixIcon: Icon(Icons.search_rounded, size: 18.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: 13.sp),
                      onChanged: (v) => setState(() {
                        _searchQuery = v;
                        _currentPage = 0;
                      }),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Date from
                  _datePicker(
                    label: _dateFrom != null ? appDateFormat.format(_dateFrom!) : 'Date début',
                    icon: Icons.calendar_today_rounded,
                    active: _dateFrom != null,
                    onTap: () => _pickDate(isFrom: true),
                  ),
                  SizedBox(width: 8.w),
                  Text('→', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp)),
                  SizedBox(width: 8.w),
                  // Date to
                  _datePicker(
                    label: _dateTo != null ? appDateFormat.format(_dateTo!) : 'Date fin',
                    icon: Icons.calendar_month_rounded,
                    active: _dateTo != null,
                    onTap: () => _pickDate(isFrom: false),
                  ),
                  SizedBox(width: 12.w),
                  // Clear button (only when filters active)
                  if (_searchQuery.isNotEmpty || _dateFrom != null || _dateTo != null)
                    TextButton.icon(
                      onPressed: _clearFilters,
                      icon: Icon(Icons.clear_rounded, size: 16.sp),
                      label: const Text('Effacer'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.dangerColor,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // Invoices List
            Expanded(
              child: BlocBuilder<SaleBloc, SaleState>(
                builder: (context, state) {
                  if (state is SaleLoadingState) {
                    return const InvoicesTableShimmer();
                  }
                  if (state is InvoicesLoadedState) {
                    final filtered = _applyFilters(state.invoices);
                    if (state.invoices.isEmpty) {
                      return const AppEmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'Aucune facture',
                      );
                    }
                    if (filtered.isEmpty) {
                      return AppEmptyState(
                        icon: Icons.search_off_rounded,
                        message: 'Aucun résultat pour ce filtre',
                        subtitle: 'Essayez un autre nom ou une autre période',
                      );
                    }
                    final totalItems = filtered.length;
                    final totalPages = (totalItems / _pageSize).ceil().clamp(1, 999999);
                    final safePage = _currentPage.clamp(0, totalPages - 1);
                    final pageItems = filtered.skip(safePage * _pageSize).take(_pageSize).toList();
                    return AnimatedFadeSlide(
                      duration: const Duration(milliseconds: 600),
                      child: Column(
                        children: [
                          Expanded(
                            child: AppCard(
                              child: SizedBox(
                                width: double.infinity,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                  headingRowHeight: 48.h,
                            dataRowMinHeight: 44.h,
                            dataRowMaxHeight: 52.h,
                            columnSpacing: 16.w,
                            horizontalMargin: 16.w,
                            columns: [
                              DataColumn(label: Text('N\u00b0 Facture', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('Date', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('Client', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('CIN', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('Articles', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('Total TTC', style: TextStyle(fontSize: 12.sp))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12.sp))),
                            ],
                            rows: pageItems.map((invoice) {
                              return DataRow(cells: [
                                DataCell(Text(
                                  invoice.invoiceNumber,
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                                )),
                                DataCell(Text(appDateTimeFormat.format(invoice.createdAt), style: TextStyle(fontSize: 12.sp))),
                                DataCell(Text(invoice.clientName, style: TextStyle(fontSize: 12.sp))),
                                DataCell(Text(invoice.clientCin, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary))),
                                DataCell(
                                  SizedBox(
                                    width: 140.w,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          invoice.itemsSummary,
                                          style: TextStyle(fontSize: 12.sp),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${invoice.totalQuantity} unité${invoice.totalQuantity > 1 ? 's' : ''}',
                                          style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                  appCurrencyFormat.format(invoice.totalWithTVA),
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.successColor),
                                )),
                                DataCell(
                                  IconButton(
                                    icon: Icon(Icons.print_rounded, size: 18.sp, color: AppTheme.primaryColor),
                                    tooltip: 'Imprimer / Sauv. PDF',
                                    onPressed: () => _printInvoice(invoice),
                                  ),
                                ),
                              ]);
                            }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          AppPaginationBar(
                            currentPage: safePage,
                            totalItems: totalItems,
                            pageSize: _pageSize,
                            onPageChanged: (p) => setState(() => _currentPage = p),
                            onPageSizeChanged: (s) => setState(() {
                              _pageSize = s;
                              _currentPage = 0;
                            }),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is SaleErrorState) {
                    return AppErrorState(
                      message: state.message,
                      onRetry: () => context.read<SaleBloc>().add(const LoadInvoicesEvent()),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: active ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8.r),
          color: active ? AppTheme.primaryColor.withValues(alpha: 0.06) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15.sp, color: active ? AppTheme.primaryColor : AppTheme.textSecondary),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: active ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printInvoice(InvoiceEntity invoice) async {
    try {
      final pdfData = await InvoicePdfGenerator.generateInvoicePdf(invoice: invoice);
      await Printing.layoutPdf(onLayout: (_) => pdfData);
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'Échec de génération du PDF : ${e.toString()}',
          title: 'Erreur PDF',
        );
      }
    }
  }
}
