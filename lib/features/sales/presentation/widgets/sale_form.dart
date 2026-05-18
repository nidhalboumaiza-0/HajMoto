import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gestion_stock/core/constants/app_constants.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/app_snack_bar.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_state.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_bloc.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_event.dart';
import 'package:gestion_stock/features/products/presentation/bloc/product_state.dart';
import 'package:gestion_stock/features/sales/domain/entities/invoice_item_entity.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_bloc.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_event.dart';
import 'package:gestion_stock/features/sales/presentation/bloc/sale_state.dart';

/// Sale Form – cart-based UI.
/// The client can add multiple products (items) to the cart,
/// then validate the whole session as one invoice.
class SaleForm extends StatefulWidget {
  const SaleForm({super.key});

  @override
  State<SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends State<SaleForm> {
  final _formKey = GlobalKey<FormState>();
  // Smart product search
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  List<ProductEntity> _searchResults = [];
  Timer? _searchDebounce;

  final _quantityController = TextEditingController();
  final _clientFirstNameController = TextEditingController();
  final _clientLastNameController = TextEditingController();
  final _clientMobileController = TextEditingController();
  final _clientCinController = TextEditingController();

  ProductEntity? _selectedProduct;

  /// Items already added to the cart
  final List<InvoiceItemEntity> _cartItems = [];

  // Cart totals (recomputed whenever cart changes)
  double _totalHT = 0;
  double _tvaAmount = 0;
  double _totalTTC = 0;

  @override
  void initState() {
    super.initState();
    // Pre-load products so the list is ready when the user starts typing
    context.read<ProductBloc>().add(const LoadProductsEvent());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    _clientFirstNameController.dispose();
    _clientLastNameController.dispose();
    _clientMobileController.dispose();
    _clientCinController.dispose();
    super.dispose();
  }

  // ── Product search helpers ──────────────────────────────────────────

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchQuery = query;
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      context.read<ProductBloc>().add(
            LoadProductsEvent(
              searchQuery: query.isNotEmpty ? query : null,
              category: _selectedCategoryFilter,
            ),
          );
    });
    setState(() {});
  }

  void _onCategoryFilterChanged(String? category) {
    setState(() => _selectedCategoryFilter = category);
    context.read<ProductBloc>().add(
          LoadProductsEvent(
            searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
            category: category,
          ),
        );
  }

  void _onProductSelected(ProductEntity product) {
    setState(() {
      _selectedProduct = product;
      _searchResults = [];
      _searchQuery = '';
      _searchController.clear();
    });
    if (product.isOutOfStock) {
      AppSnackBar.warning(
        context,
        'ATTENTION : Ce produit est en rupture de stock !',
        title: 'Rupture de Stock',
      );
    } else if (product.isLowStock) {
      AppSnackBar.warning(
        context,
        'ATTENTION : Stock faible ! Seulement ${product.quantity} restant(s)',
        title: 'Stock Faible',
      );
    }
  }

  void _recomputeTotals() {
    final ht = _cartItems.fold<double>(0, (s, i) => s + i.lineTotalHT);
    setState(() {
      _totalHT = ht;
      _tvaAmount = ht * AppConstants.tvaRate;
      _totalTTC = ht + _tvaAmount;
    });
  }

  void _addToCart() {
    if (_selectedProduct == null) {
      AppSnackBar.warning(
        context,
        'Sélectionnez d\'abord un produit dans la liste',
      );
      return;
    }
    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (qty <= 0) {
      AppSnackBar.warning(context, 'Quantité invalide');
      return;
    }
    // Check against available stock minus already-carted qty for same product
    final alreadyInCart = _cartItems
        .where((i) => i.productId == _selectedProduct!.id)
        .fold<int>(0, (s, i) => s + i.quantity);
    final remaining = _selectedProduct!.quantity - alreadyInCart;
    if (qty > remaining) {
      AppSnackBar.error(
        context,
        'Stock insuffisant : seulement $remaining unité(s) disponible(s)',
      );
      return;
    }

    // Merge with existing same-product line or add new line
    final existingIdx =
        _cartItems.indexWhere((i) => i.productId == _selectedProduct!.id);
    if (existingIdx >= 0) {
      final old = _cartItems[existingIdx];
      _cartItems[existingIdx] = InvoiceItemEntity(
        productId: old.productId,
        referenceCode: old.referenceCode,
        productName: old.productName,
        quantity: old.quantity + qty,
        unitPrice: old.unitPrice,
        purchasePrice: old.purchasePrice,
      );
    } else {
      _cartItems.add(InvoiceItemEntity(
        productId: _selectedProduct!.id,
        referenceCode: _selectedProduct!.referenceCode,
        productName: _selectedProduct!.name,
        quantity: qty,
        unitPrice: _selectedProduct!.sellingPrice,
        purchasePrice: _selectedProduct!.purchasePrice,
      ));
    }

    // Reset product search fields
    setState(() {
      _selectedProduct = null;
      _quantityController.clear();
    });
    _recomputeTotals();
  }

  void _removeFromCart(int index) {
    setState(() => _cartItems.removeAt(index));
    _recomputeTotals();
  }

  void _submitSale() {
    if (!_formKey.currentState!.validate()) return;
    if (_cartItems.isEmpty) {
      AppSnackBar.warning(
        context,
        'Le panier est vide – ajoutez au moins un article',
      );
      return;
    }

    context.read<SaleBloc>().add(CreateSaleEvent(
          items: List.unmodifiable(_cartItems),
          clientFirstName: _clientFirstNameController.text.trim(),
          clientLastName: _clientLastNameController.text.trim(),
          clientMobile: _clientMobileController.text.trim(),
          clientCin: _clientCinController.text.trim(),
        ));
  }

  // \u2500\u2500 Smart Product Search UI \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500

  Widget _buildProductSearchSection(BuildContext context) {
    final showResults =
        (_searchQuery.isNotEmpty || _selectedCategoryFilter != null) &&
            _searchResults.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // \u2500 Search line + category filter \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search text field
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom ou r\u00e9f\u00e9rence\u2026',
                  prefixIcon: Icon(Icons.search_rounded,
                      size: 20.sp, color: AppTheme.textSecondary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              size: 18.sp, color: AppTheme.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  ),
                ),
                onChanged: _onSearchChanged,
                style: TextStyle(fontSize: 13.sp),
              ),
            ),
            SizedBox(width: 10.w),

            // Category filter dropdown
            Expanded(
              flex: 2,
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, catState) {
                  final cats = catState is CategoryLoadedState
                      ? catState.categories
                      : catState is CategoryOperationSuccessState
                          ? catState.categories
                          : <dynamic>[];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: _selectedCategoryFilter != null
                            ? AppTheme.primaryColor
                            : Colors.grey.shade300,
                        width: _selectedCategoryFilter != null ? 1.5 : 1.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedCategoryFilter,
                        hint: Text(
                          'Toutes cat\u00e9gories',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: AppTheme.textSecondary),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down_rounded,
                            size: 20.sp,
                            color: _selectedCategoryFilter != null
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary),
                        isExpanded: true,
                        style: TextStyle(
                            fontSize: 12.sp, color: AppTheme.textPrimary),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Toutes',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary)),
                          ),
                          ...cats.map((cat) => DropdownMenuItem<String?>(
                                value: (cat as dynamic).value as String,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10.w,
                                      height: 10.h,
                                      decoration: BoxDecoration(
                                        color: (cat as dynamic).color as Color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        (cat as dynamic).displayName as String,
                                        style: TextStyle(fontSize: 12.sp),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                        onChanged: _onCategoryFilterChanged,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        // \u2500 Results dropdown panel \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
        if (showResults) ...[
          SizedBox(height: 6.h),
          Container(
            constraints: BoxConstraints(maxHeight: 220.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                shrinkWrap: true,
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final p = _searchResults[index];
                  final isOut = p.isOutOfStock;
                  final isLow = p.isLowStock && !isOut;
                  return InkWell(
                    onTap: isOut ? null : () => _onProductSelected(p),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      color: isOut
                          ? Colors.grey.shade50
                          : Colors.transparent,
                      child: Row(
                        children: [
                          // Stock indicator dot
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOut
                                  ? AppTheme.dangerColor
                                  : isLow
                                      ? AppTheme.warningColor
                                      : AppTheme.successColor,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          // Product info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isOut
                                        ? AppTheme.textSecondary
                                        : AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  p.referenceCode,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppTheme.textSecondary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Price + stock
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${p.sellingPrice.toStringAsFixed(2)} TND',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                isOut
                                    ? 'Rupture'
                                    : 'Stock : ${p.quantity}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: isOut
                                      ? AppTheme.dangerColor
                                      : isLow
                                          ? AppTheme.warningColor
                                          : AppTheme.textSecondary,
                                  fontWeight: isOut || isLow
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ] else if ((_searchQuery.isNotEmpty || _selectedCategoryFilter != null) &&
            _searchResults.isEmpty) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Aucun produit trouv\u00e9 pour cette recherche',
              style: TextStyle(
                  fontSize: 12.sp, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductLoadedState) {
          setState(() => _searchResults = state.products);
        }
        if (state is ProductEmptyState) {
          setState(() => _searchResults = []);
        }
        if (state is ProductErrorState) {
          setState(() => _searchResults = []);
        }
      },
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LEFT: Product search + Cart ───────────────────────────
              Expanded(
                flex: 3,
                child: AppCard(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Product Search ──────────────────────────────
                      Text(
                        'Ajouter un Article',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 16.h),

                      // Smart product search (name / reference / category)
                      _buildProductSearchSection(context),
                      SizedBox(height: 12.h),

                      // Product info card (when product is found)
                      if (_selectedProduct != null) ...[
                        Container(
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.successColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                                color: AppTheme.successColor
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedProduct!.name,
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      _selectedProduct!.categories.isEmpty
                                          ? ''
                                          : _selectedProduct!.categories.join('  •  '),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppTheme.primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'Prix : ${_selectedProduct!.sellingPrice.toStringAsFixed(2)} TND  |  Stock : ${_selectedProduct!.quantity}',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // Quantity + Add button
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                  labelText: 'Quantité'),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          ElevatedButton.icon(
                            onPressed: _addToCart,
                            icon: const Icon(Icons.add_shopping_cart_rounded,
                                size: 18),
                            label: const Text('Ajouter'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),
                      const Divider(),
                      SizedBox(height: 12.h),

                      // ── Cart list ───────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Panier',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          if (_cartItems.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '${_cartItems.length} article${_cartItems.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      if (_cartItems.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: Text(
                            'Aucun article – recherchez et ajoutez des produits',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.textSecondary),
                          ),
                        )
                      else ...[
                        // Cart header
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Text('Produit',
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary))),
                              Expanded(
                                  child: Text('Qté',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary))),
                              Expanded(
                                  child: Text('P.U.',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary))),
                              Expanded(
                                  child: Text('Total',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary))),
                              SizedBox(width: 32.w),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),

                        // Cart rows
                        ...List.generate(_cartItems.length, (i) {
                          final item = _cartItems[i];
                          return Container(
                            margin: EdgeInsets.only(bottom: 4.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6.r),
                              border:
                                  Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500),
                                          overflow: TextOverflow.ellipsis),
                                      Text(item.referenceCode,
                                          style: TextStyle(
                                              fontSize: 10.sp,
                                              color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.quantity.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.unitPrice.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppTheme.textSecondary),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    item.lineTotalHT.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      size: 16.sp,
                                      color: AppTheme.dangerColor),
                                  tooltip: 'Retirer',
                                  onPressed: () => _removeFromCart(i),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                      minWidth: 28.w, minHeight: 28.h),
                                ),
                              ],
                            ),
                          );
                        }),
                        SizedBox(height: 16.h),

                        // Cart totals
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              AppLabelValueRow(
                                  label: 'Sous-total (HT)',
                                  value:
                                      '${_totalHT.toStringAsFixed(2)} TND'),
                              SizedBox(height: 8.h),
                              AppLabelValueRow(
                                  label: 'TVA (19%)',
                                  value:
                                      '${_tvaAmount.toStringAsFixed(2)} TND'),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6),
                                  child: Divider()),
                              AppLabelValueRow(
                                label: 'Total TTC',
                                value:
                                    '${_totalTTC.toStringAsFixed(2)} TND',
                                isBold: true,
                                isLarge: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // ── RIGHT: Client info + Submit ───────────────────────────
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    AppCard(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations Client',
                            style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Entrez les détails du client pour la facture',
                            style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.textSecondary),
                          ),
                          SizedBox(height: 20.h),

                          // CIN + lookup button
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _clientCinController,
                                  decoration: const InputDecoration(
                                    labelText: 'CIN *',
                                    hintText: 'ex. 12345678',
                                  ),
                                  validator: (v) =>
                                      v == null || v.isEmpty
                                          ? 'Obligatoire'
                                          : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: const Icon(Icons.search),
                                tooltip: 'Rechercher client',
                                onPressed: () {
                                  if (_clientCinController.text.isNotEmpty) {
                                    context.read<SaleBloc>().add(
                                        LookupClientEvent(
                                            _clientCinController.text
                                                .trim()));
                                  }
                                },
                              ),
                            ],
                          ),

                          // Listen for client lookup result
                          BlocListener<SaleBloc, SaleState>(
                            listener: (context, state) {
                              if (state is ClientFoundState) {
                                _clientFirstNameController.text =
                                    state.client.firstName;
                                _clientLastNameController.text =
                                    state.client.lastName;
                                _clientMobileController.text =
                                    state.client.mobileNumber;
                                AppSnackBar.success(
                                  context,
                                  'Client trouvé : ${state.client.firstName} ${state.client.lastName}',
                                  title: 'Client Identifié',
                                );
                              }
                            },
                            child: const SizedBox.shrink(),
                          ),
                          SizedBox(height: 12.h),

                          TextFormField(
                            controller: _clientFirstNameController,
                            decoration:
                                const InputDecoration(labelText: 'Prénom *'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obligatoire' : null,
                          ),
                          SizedBox(height: 12.h),

                          TextFormField(
                            controller: _clientLastNameController,
                            decoration:
                                const InputDecoration(labelText: 'Nom *'),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obligatoire' : null,
                          ),
                          SizedBox(height: 12.h),

                          TextFormField(
                            controller: _clientMobileController,
                            decoration: const InputDecoration(
                              labelText: 'N° Téléphone *',
                              hintText: 'ex. +216 XX XXX XXX',
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Obligatoire' : null,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: BlocBuilder<SaleBloc, SaleState>(
                        builder: (context, state) {
                          final isLoading = state is SaleLoadingState;
                          return ElevatedButton.icon(
                            onPressed: isLoading ? null : _submitSale,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : const Icon(Icons.point_of_sale_rounded),
                            label: Text(
                              isLoading
                                  ? 'Traitement...'
                                  : 'Valider la Vente\n(${_cartItems.length} article${_cartItems.length > 1 ? 's' : ''})',
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _cartItems.isEmpty
                                  ? Colors.grey
                                  : AppTheme.successColor,
                              padding:
                                  EdgeInsets.symmetric(vertical: 16.h),
                              textStyle: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
