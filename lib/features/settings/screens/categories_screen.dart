import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../widgets/category_card.dart';
import '../widgets/category_type_filter.dart';
import '../widgets/add_custom_category_button.dart';
import '../widgets/category_details_bottom_sheet.dart';
import '../dialogs/add_category_dialog.dart';
import '../dialogs/edit_category_dialog.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService.instance;
  List<Category> _categories = [];
  bool _isLoading = true;
  CategoryType _selectedType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    await _categoryService.initialize();
    setState(() {
      _categories = _categoryService.categories;
      _isLoading = false;
    });
  }

  List<Category> get _filteredCategories {
    return _categories.where((c) => c.type == _selectedType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: theme.appBarTheme.titleTextStyle),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
            onPressed: () {
              _showAddCategoryDialog(context);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Transaction Categories',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your expense categories for better budgeting and tracking.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Type Filter
                  CategoryTypeFilter(
                    selectedType: _selectedType,
                    onTypeChanged: (type) {
                      setState(() {
                        _selectedType = type;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Categories Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      return CategoryCard(
                        category: category,
                        onTap: () => _showCategoryDetails(context, category),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Add Custom Category Button
                  AddCustomCategoryButton(
                    onTap: () => _showAddCategoryDialog(context),
                  ),
                ],
              ),
            ),
    );
  }


  void _showCategoryDetails(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryDetailsBottomSheet(
        category: category,
        onEdit: () {
          Navigator.pop(context);
          _showEditCategoryDialog(context, category);
        },
        onDelete: () async {
          Navigator.pop(context);
          final success = await _categoryService.deleteCategory(category.id);
          if (success) {
            await _loadCategories();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.name} deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cannot delete default category'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }


  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(
        onCategoryAdded: (category) async {
          final success = await _categoryService.addCategory(category);
          if (success) {
            await _loadCategories();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.name} added successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category with this name already exists'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(
        category: category,
        onCategoryUpdated: (updatedCategory) async {
          final success = await _categoryService.updateCategory(updatedCategory);
          if (success) {
            await _loadCategories();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${updatedCategory.name} updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Category with this name already exists'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
