import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_state.dart';
import 'package:gestion_stock/features/products/domain/entities/product_entity.dart';

/// Add/Edit Product Dialog
/// Supports dynamic categories from CategoryBloc and up to 3 product images.
class AddProductDialog extends StatefulWidget {
  final ProductEntity? product;
  final Function(ProductEntity) onSave;

  const AddProductDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late final TextEditingController _referenceController;
  late final TextEditingController _nameController;
  late final TextEditingController _purchasePriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _quantityController;
  late final TextEditingController _thresholdController;

  List<String> _selectedCategories = [];
  List<String> _imagePaths = [];

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _referenceController = TextEditingController(text: p?.referenceCode ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _purchasePriceController = TextEditingController(
      text: p != null ? p.purchasePrice.toStringAsFixed(2) : '',
    );
    _sellingPriceController = TextEditingController(
      text: p != null ? p.sellingPrice.toStringAsFixed(2) : '',
    );
    _quantityController = TextEditingController(
      text: p != null ? p.quantity.toString() : '',
    );
    _thresholdController = TextEditingController(
      text: p != null ? p.lowStockThreshold.toString() : '5',
    );
    if (p != null) {
      _selectedCategories = List.from(p.categories);
      _imagePaths = List.from(p.imagePaths);
    }
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  // ─── Image picking ────────────────────────────────────────────────

  Future<void> _pickImage() async {
    if (_imagePaths.length >= 3) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _imagePaths.add(result.files.single.path!));
    }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  // ─── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 540.w,
        constraints: BoxConstraints(maxHeight: 0.9 * MediaQuery.of(context).size.height),
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Modifier Produit' : 'Ajouter un Nouveau Produit',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Reference Code ──
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Code Référence *',
                    hintText: 'ex. VSP-001',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatoire' : null,
                ),
                SizedBox(height: 16.h),

                // ── Name ──
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du Produit *',
                    hintText: 'ex. Plaquette de Frein Vespa',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Obligatoire' : null,
                ),
                SizedBox(height: 16.h),

                // ── Categories (multi-select checkboxes) ──
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, catState) {
                    final cats = catState is CategoryLoadedState
                        ? catState.categories
                        : catState is CategoryOperationSuccessState
                            ? catState.categories
                            : const [];
                    if (cats.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catégorie(s) *',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _selectedCategories.isEmpty
                                ? AppTheme.dangerColor
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedCategories.isEmpty
                                  ? AppTheme.dangerColor
                                  : Colors.grey.shade400,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Column(
                            children: cats.map((cat) {
                              final val = cat.value as String;
                              final selected = _selectedCategories.contains(val);
                              return CheckboxListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Text(
                                  cat.displayName as String,
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                                secondary: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: BoxDecoration(
                                    color: cat.color as Color,
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                                value: selected,
                                activeColor: AppTheme.primaryColor,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      if (!_selectedCategories.contains(val)) {
                                        _selectedCategories.add(val);
                                      }
                                    } else {
                                      _selectedCategories.remove(val);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                        if (_selectedCategories.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h, left: 12.w),
                            child: Text(
                              'Choisir au moins une catégorie',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppTheme.dangerColor),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16.h),

                // ── Prices row ──
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        decoration: const InputDecoration(
                          labelText: "Prix d'Achat (TND) *",
                          hintText: '0.00',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatoire';
                          if (double.tryParse(v) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Prix de Vente (TND) *',
                          hintText: '0.00',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatoire';
                          if (double.tryParse(v) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // ── Quantity and threshold ──
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantité *',
                          hintText: '0',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Obligatoire';
                          if (int.tryParse(v) == null) {
                            return 'Nombre invalide';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: TextFormField(
                        controller: _thresholdController,
                        decoration: const InputDecoration(
                          labelText: 'Seuil de Stock Faible',
                          hintText: '5',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // ── Images (max 3) ──
                Text(
                  'Photos du produit (max 3)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Thumbnail slots
                    ..._imagePaths.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final path = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: SizedBox(
                                width: 72.w,
                                height: 72.w,
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: GestureDetector(
                                onTap: () => _removeImage(idx),
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.dangerColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      size: 12, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Add button (only when < 3 images)
                    if (_imagePaths.length < 3)
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(8.r),
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  size: 22.sp,
                                  color: AppTheme.primaryColor),
                              SizedBox(height: 4.h),
                              Text(
                                'Ajouter',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Actions ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: _onSave,
                      child: Text(
                          isEditing ? 'Mettre à jour' : 'Ajouter Produit'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      setState(() {}); // trigger rebuild to show validation
      return;
    }

    final now = DateTime.now();
    final product = ProductEntity(
      id: widget.product?.id ?? _uuid.v4(),
      referenceCode: _referenceController.text.trim(),
      name: _nameController.text.trim(),
      categories: List.unmodifiable(_selectedCategories),
      purchasePrice: double.parse(_purchasePriceController.text),
      sellingPrice: double.parse(_sellingPriceController.text),
      quantity: int.parse(_quantityController.text),
      lowStockThreshold: int.tryParse(_thresholdController.text) ?? 5,
      createdAt: widget.product?.createdAt ?? now,
      updatedAt: now,
      imagePaths: List.unmodifiable(_imagePaths),
    );

    widget.onSave(product);
    Navigator.pop(context);
  }
}
