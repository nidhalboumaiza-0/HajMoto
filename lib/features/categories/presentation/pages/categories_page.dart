import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';
import 'package:gestion_stock/core/presentation/widgets/core_widgets.dart';
import 'package:gestion_stock/core/theme/app_theme.dart';
import 'package:gestion_stock/core/utils/app_snack_bar.dart';
import 'package:gestion_stock/features/categories/domain/entities/category_entity.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_bloc.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_event.dart';
import 'package:gestion_stock/features/categories/presentation/bloc/category_state.dart';

/// A dialog that lets the user view, add, edit and delete product categories.
/// Shown via `showDialog(builder: (_) => const CategoriesDialog())`.
class CategoriesDialog extends StatelessWidget {
  const CategoriesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 560.w,
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gérer les Catégories',
                  style: TextStyle(
                      fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showCategoryForm(context, null),
                      icon: Icon(Icons.add_rounded, size: 16.sp),
                      label: const Text('Nouvelle Catégorie'),
                      style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h)),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // ── Category list ──
            Flexible(
              child: BlocConsumer<CategoryBloc, CategoryState>(
                listener: (context, state) {
                  if (state is CategoryOperationSuccessState) {
                    AppSnackBar.success(context, state.message);
                  }
                  if (state is CategoryErrorState) {
                    AppSnackBar.error(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is CategoryLoadingState) {
                    return const CategoriesShimmer();
                  }

                  final cats = state is CategoryLoadedState
                      ? state.categories
                      : state is CategoryOperationSuccessState
                          ? state.categories
                          : const <CategoryEntity>[];

                  if (cats.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Text(
                          'Aucune catégorie pour l\'instant.\nCliquez sur "+ Nouvelle Catégorie" pour en créer une.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13.sp),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: cats.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        leading: CircleAvatar(
                          radius: 16.r,
                          backgroundColor: cat.color.withValues(alpha: 0.15),
                          child: Icon(Icons.category_rounded,
                              size: 16.sp, color: cat.color),
                        ),
                        title: Text(
                          cat.displayName,
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          cat.value,
                          style: TextStyle(
                              fontSize: 11.sp, color: AppTheme.textSecondary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Color swatch
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: cat.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 1),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            IconButton(
                              icon: Icon(Icons.edit_outlined,
                                  size: 16.sp,
                                  color: AppTheme.secondaryColor),
                              tooltip: 'Modifier',
                              onPressed: () =>
                                  _showCategoryForm(context, cat),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline,
                                  size: 16.sp, color: AppTheme.dangerColor),
                              tooltip: 'Supprimer',
                              onPressed: () =>
                                  _confirmDelete(context, cat),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Category Form ────────────────────────────────────────────────

  void _showCategoryForm(BuildContext context, CategoryEntity? existing) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryBloc>(),
        child: _CategoryFormDialog(existing: existing),
      ),
    );
  }

  // ─── Delete Confirmation ──────────────────────────────────────────

  void _confirmDelete(BuildContext context, CategoryEntity cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer Catégorie'),
        content: Text(
            'Supprimer "${cat.displayName}" ? Les produits associés garderont leur valeur de catégorie actuelle.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerColor),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<CategoryBloc>()
                  .add(DeleteCategoryEvent(cat.id));
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ─── Category Add / Edit dialog ──────────────────────────────────────────

/// Pre-defined colors the user can pick from
const _kColorOptions = [
  Color(0xFF1565C0), // blue
  Color(0xFF2E7D32), // green
  Color(0xFF6A1B9A), // purple
  Color(0xFFE65100), // orange
  Color(0xFFC62828), // red
  Color(0xFF00695C), // teal
  Color(0xFFF9A825), // amber
  Color(0xFF37474F), // blue-grey
];

class _CategoryFormDialog extends StatefulWidget {
  final CategoryEntity? existing;
  const _CategoryFormDialog({this.existing});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late final TextEditingController _displayNameController;
  late final TextEditingController _valueController;
  late Color _selectedColor;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _displayNameController =
        TextEditingController(text: e?.displayName ?? '');
    _valueController = TextEditingController(text: e?.value ?? '');
    _selectedColor =
        e != null ? Color(e.colorValue) : _kColorOptions.first;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  /// Auto-generate slug from display name when not manually edited
  void _onDisplayNameChanged(String value) {
    if (!isEditing) {
      final slug = value
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
          .trim()
          .replaceAll(RegExp(r'\s+'), '_');
      _valueController.text = slug;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 400.w,
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Modifier Catégorie' : 'Nouvelle Catégorie',
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              SizedBox(height: 16.h),

              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                    labelText: 'Nom affiché *',
                    hintText: 'ex. Pièces Yamaha'),
                onChanged: _onDisplayNameChanged,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Obligatoire' : null,
              ),
              SizedBox(height: 14.h),

              // Slug / value
              TextFormField(
                controller: _valueController,
                decoration: const InputDecoration(
                  labelText: 'Identifiant (slug) *',
                  hintText: 'ex. pieces_yamaha',
                  helperText: 'Lettres minuscules, chiffres et _ uniquement',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obligatoire';
                  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(v)) {
                    return 'Caractères invalides';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Color picker
              Text('Couleur',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: _kColorOptions.map((color) {
                  final selected = color.toARGB32() == _selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(
                                color:
                                    AppTheme.primaryColor, width: 3)
                            : Border.all(
                                color: Colors.grey.shade300, width: 1),
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              size: 14, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),

              // Actions
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
                    child: Text(isEditing ? 'Mettre à jour' : 'Créer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final category = CategoryEntity(
      id: widget.existing?.id ?? _uuid.v4(),
      displayName: _displayNameController.text.trim(),
      value: _valueController.text.trim(),
      colorValue: _selectedColor.toARGB32(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    final bloc = context.read<CategoryBloc>();
    if (isEditing) {
      bloc.add(UpdateCategoryEvent(category));
    } else {
      bloc.add(AddCategoryEvent(category));
    }
    Navigator.pop(context);
  }
}
