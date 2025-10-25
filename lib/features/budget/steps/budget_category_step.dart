import 'package:flutter/material.dart';
import '../../../data/models/category_model.dart';
import '../widgets/step_header.dart';
import '../widgets/budget_category_card.dart';

class BudgetCategoryStep extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;

  const BudgetCategoryStep({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StepHeader(
          step: 'Step 2',
          title: 'Select Spending Category',
          description: 'Which category do you want to limit spending on?',
        ),
        const SizedBox(height: 24),
        
        // Category Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory?.id == category.id;
            
            return BudgetCategoryCard(
              name: category.name,
              icon: category.icon,
              color: category.color,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category),
            );
          },
        ),
      ],
    );
  }
}
