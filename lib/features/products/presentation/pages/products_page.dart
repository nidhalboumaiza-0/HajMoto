import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/app_snack_bar.dart';
import 'package:gestion_stock/core/utils/formatters.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_event.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_state.dart';
import 'package:gestion_stock/features/categories/presentation/pages/categories_page.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_bloc.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_event.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_state.dart';
import 'package:gestion_stock/features/products/presentation/widgets/add_product_dialog.dart';
import 'package:gestion_stock/features/products/presentation/widgets/import_csv_dialog.dart';

/// Products Page - Manage inventory
/// Shows all products in a DataTable with search, filter, add, edit, delete
class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _searchController = TextEditingController();
  String? _activeCategory;
  String _stockFilter = 'all'; // all, low, out
  int _currentPage = 0;
  int _pageSize = 15;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(const LoadCategoriesEvent());
    context.read<ProductBloc>().add(const LoadProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() => _currentPage = 0);
    context.read<ProductBloc>().add(
          LoadProductsEvent(category: _activeCategory, searchQuery: query.isNotEmpty ? query : null),
        );
  }

  void _onCategoryChanged(String? category) {
    setState(() {
      _activeCategory = category;
      _currentPage = 0;
    });
    context.read<ProductBloc>().add(LoadProductsEvent(category: category));
  }

  void _onStockFilterChanged(String filter) {
    setState(() {
      _stockFilter = filter;
      _currentPage = 0;
    });
    switch (filter) {
      case 'low':
        context.read<ProductBloc>().add(const LoadLowStockProductsEvent());
        break;
      case 'out':
        context.read<ProductBloc>().add(const LoadOutOfStockProductsEvent());
        break;
      default:
        context.read<ProductBloc>().add(LoadProductsEvent(category: _activeCategory));
    }
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
              title: 'Produits',
              subtitle: 'Gérer votre inventaire',
              trailing: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ImportCsvDialog(
                          onImport: (data) {
                            context.read<ProductBloc>().add(ImportProductsCsvEvent(data));
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.upload_file_rounded, size: 18.sp),
                    label: const Text('Importer CSV'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AddProductDialog(
                          onSave: (product) {
                            context.read<ProductBloc>().add(AddProductEvent(product));
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.add_rounded, size: 18.sp),
                    label: const Text('Ajouter Produit'),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const CategoriesDialog(),
                      );
                    },
                    icon: Icon(Icons.category_rounded, size: 18.sp),
                    label: const Text('Catégories'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Filters Row
            Row(
              children: [
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom ou référence...',
                      prefixIcon: Icon(Icons.search_rounded, size: 20.sp),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                    ),
                    onChanged: _onSearch,
                  ),
                ),
                SizedBox(width: 16.w),

                // Category Filter
                Expanded(
                  flex: 2,
                  child: BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, catState) {
                      final cats = catState is CategoryLoadedState
                          ? catState.categories
                          : catState is CategoryOperationSuccessState
                              ? catState.categories
                              : <dynamic>[];
                      return DropdownButtonFormField<String?>(
                        initialValue: _activeCategory,
                        decoration:
                            const InputDecoration(labelText: 'Catégorie'),
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Toutes les Catégories')),
                          ...cats.map((cat) => DropdownMenuItem(
                                value: cat.value as String,
                                child: Text(cat.displayName as String),
                              )),
                        ],
                        onChanged: _onCategoryChanged,
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.w),

                // Stock Filter
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _stockFilter,
                    decoration: const InputDecoration(labelText: 'État du Stock'),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tout le Stock')),
                      DropdownMenuItem(value: 'low', child: Text('Stock Faible')),
                      DropdownMenuItem(value: 'out', child: Text('Rupture de Stock')),
                    ],
                    onChanged: (v) => _onStockFilterChanged(v ?? 'all'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Products Table
            Expanded(
              child: BlocConsumer<ProductBloc, ProductState>(
                listener: (context, state) {
                  if (state is ProductOperationSuccessState) {
                    AppSnackBar.success(context, state.message);
                  }
                  if (state is ProductImportSuccessState) {
                    AppSnackBar.success(
                      context,
                      '${state.importedCount} produits importés avec succès',
                      title: 'Import CSV',
                    );
                  }
                  if (state is ProductErrorState) {
                    AppSnackBar.error(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ProductLoadingState) {
                    return const ProductsTableShimmer();
                  }
                  if (state is ProductEmptyState) {
                    return AppEmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: state.message,
                    );
                  }
                  if (state is ProductLoadedState) {
                    return AnimatedFadeSlide(
                      duration: const Duration(milliseconds: 600),
                      child: _buildProductsTable(state.products),
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

  Widget _buildProductsTable(List<ProductEntity> products) {
    final totalItems = products.length;
    final totalPages = (totalItems / _pageSize).ceil().clamp(1, 999999);
    final safePage = _currentPage.clamp(0, totalPages - 1);
    final pageItems = products.skip(safePage * _pageSize).take(_pageSize).toList();

    return Column(
      children: [
        Expanded(
          child: AppCard(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
          child: DataTable(
            headingRowHeight: 48.h,
            dataRowMinHeight: 48.h,
            dataRowMaxHeight: 56.h,
            columnSpacing: 16.w,
            horizontalMargin: 16.w,
            columns: [
              DataColumn(label: Text('Référence', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Nom', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Catégorie', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Achat', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Vente', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Stock', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('État', style: TextStyle(fontSize: 12.sp))),
              DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12.sp))),
            ],
            rows: pageItems.map((product) {
              return DataRow(
                cells: [
                  DataCell(
                    _copyableReference(context, product.referenceCode),
                  ),
                  DataCell(
                    SizedBox(
                      width: 150.w,
                      child: Text(product.name, style: TextStyle(fontSize: 12.sp), overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  DataCell(_categoriesChips(context, product.categories)),
                  DataCell(Text(appCurrencyFormat.format(product.purchasePrice), style: TextStyle(fontSize: 12.sp))),
                  DataCell(Text(appCurrencyFormat.format(product.sellingPrice), style: TextStyle(fontSize: 12.sp))),
                  DataCell(Text(product.quantity.toString(), style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600))),
                  DataCell(_stockStatusBadge(product)),
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 16.sp, color: AppTheme.secondaryColor),
                        tooltip: 'Modifier',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddProductDialog(
                              product: product,
                              onSave: (updated) {
                                context.read<ProductBloc>().add(UpdateProductEvent(updated));
                              },
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, size: 16.sp, color: AppTheme.dangerColor),
                        tooltip: 'Supprimer',
                        onPressed: () => _showDeleteConfirmation(product),
                      ),
                    ],
                  )),
                ],
              );
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
    );
  }

  Widget _copyableReference(BuildContext context, String reference) {
    return Tooltip(
      message: 'Copier la référence',
      child: InkWell(
        borderRadius: BorderRadius.circular(6.r),
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: reference));
          if (context.mounted) {
            AppSnackBar.success(
              context,
              'Référence "$reference" copiée',
              title: 'Copié',
              duration: const Duration(seconds: 2),
            );
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                reference,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.copy_rounded, size: 13.sp, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _categoriesChips(BuildContext context, List<String> categoryValues) {
    if (categoryValues.isEmpty) return const SizedBox.shrink();
    final catState = context.read<CategoryBloc>().state;
    final cats = catState is CategoryLoadedState
        ? catState.categories
        : catState is CategoryOperationSuccessState
            ? catState.categories
            : <dynamic>[];
    return Wrap(
      spacing: 4.w,
      runSpacing: 2.h,
      children: categoryValues.map((val) {
        final cat = cats.cast<dynamic>().firstWhere(
              (c) => (c.value as String) == val,
              orElse: () => null,
            );
        final displayName = cat != null
            ? (cat.displayName as String)
            : val.replaceAll('_', ' ');
        final Color color;
        if (cat != null) {
          color = cat.color as Color;
        } else {
          color = val.startsWith('vespa') ? AppTheme.vespaColor : AppTheme.forzaColor;
        }
        return AppStatusBadge(label: displayName, color: color);
      }).toList(),
    );
  }

  Widget _stockStatusBadge(ProductEntity product) {
    final Color color;
    final String label;
    if (product.isOutOfStock) {
      color = AppTheme.dangerColor;
      label = 'Rupture de Stock';
    } else if (product.isLowStock) {
      color = AppTheme.warningColor;
      label = 'Stock Faible';
    } else {
      color = AppTheme.successColor;
      label = 'En Stock';
    }
    return AppStatusBadge(label: label, color: color);
  }

  void _showDeleteConfirmation(ProductEntity product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer Produit'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${product.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProductBloc>().add(DeleteProductEvent(product.id));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerColor),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
