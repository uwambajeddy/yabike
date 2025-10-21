import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodels/create_budget_stepper_viewmodel.dart';

class CreateBudgetStepperScreen extends StatefulWidget {
  const CreateBudgetStepperScreen({super.key});

  @override
  State<CreateBudgetStepperScreen> createState() => _CreateBudgetStepperScreenState();
}

class _CreateBudgetStepperScreenState extends State<CreateBudgetStepperScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ChangeNotifierProvider(
      create: (_) => CreateBudgetStepperViewModel(),
      child: Consumer<CreateBudgetStepperViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: AppColors.whiteTertiary,
            appBar: AppBar(
              backgroundColor: colorScheme.surface,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'New Budget',
                style: theme.textTheme.headlineSmall,
              ),
              centerTitle: false,
            ),
            body: Column(
              children: [
                // Category Selection (Always visible)
                Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCategorySelector(viewModel, theme),
                      const SizedBox(height: 12),
                      _buildStepIndicator(viewModel, theme),
                    ],
                  ),
                ),
                
                // Step Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 24),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.grayPrimary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildStepContent(
                              viewModel, 
                              theme, 
                              colorScheme,
                              _nameController,
                              _amountController,
                            ),
                          ),
                        ),
                        
                        // Bottom Buttons
                        _buildBottomButtons(viewModel, theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategorySelector(CreateBudgetStepperViewModel viewModel, ThemeData theme) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final category = viewModel.categories[index];
          final isSelected = viewModel.selectedCategory == category['name'];
          final isAddNew = category['isAddNew'] == true;
          final categoryColor = category['color'] as Color? ?? AppColors.textSecondary;
          
          return GestureDetector(
            onTap: () {
              if (isAddNew) {
                _showAddCategoryDialog(context, viewModel);
              } else {
                viewModel.selectCategory(category['name'] as String);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isSelected ? 90 : 80,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isSelected ? 80 : 64,
                    height: isSelected ? 80 : 64,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? categoryColor.withOpacity(0.2)
                        : AppColors.whiteTertiary,
                      shape: BoxShape.circle,
                      border: isSelected 
                        ? Border.all(color: categoryColor, width: 2)
                        : null,
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      size: isSelected ? 40 : 32,
                      color: isSelected 
                        ? categoryColor 
                        : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected 
                        ? categoryColor 
                        : AppColors.textSecondary,
                      fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, CreateBudgetStepperViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Add New Category',
          style: theme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: categoryController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter category name',
            filled: true,
            fillColor: AppColors.whiteTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final categoryName = categoryController.text.trim();
              if (categoryName.isNotEmpty) {
                viewModel.addNewCategory(categoryName);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Add',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(CreateBudgetStepperViewModel viewModel, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == viewModel.currentStep;
        final isCompleted = index < viewModel.currentStep;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCompleted || isActive 
              ? AppColors.primary 
              : AppColors.grayPrimary,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(
    CreateBudgetStepperViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
    TextEditingController nameController,
    TextEditingController amountController,
  ) {
    switch (viewModel.currentStep) {
      case 0:
        return _buildStep1(viewModel, theme, nameController);
      case 1:
        return _buildStep2(viewModel, theme, amountController);
      case 2:
        return _buildStep3(viewModel, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(
    CreateBudgetStepperViewModel viewModel,
    ThemeData theme,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Name',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter budget name',
            filled: true,
            fillColor: AppColors.whiteTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => viewModel.setBudgetName(value),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep2(
    CreateBudgetStepperViewModel viewModel,
    ThemeData theme,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'Enter the amount of funds needed',
            filled: true,
            fillColor: AppColors.whiteTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0;
            viewModel.setBudgetAmount(amount);
          },
        ),
        const SizedBox(height: 24),
        
        Text(
          'Achievement Date',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context, viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.whiteTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    viewModel.endDate != null
                        ? DateFormat('dd MMMM yyyy').format(viewModel.endDate!)
                        : 'Select Date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: viewModel.endDate != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStep3(
    CreateBudgetStepperViewModel viewModel,
    ThemeData theme,
  ) {
    final dailySavings = viewModel.calculateDailySavings();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.whiteTertiary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Rwf ${_formatAmount(viewModel.budgetAmount)}',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 24),
        
        Text(
          'Achievement Date',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectDate(context, viewModel),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.whiteTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    viewModel.endDate != null
                        ? DateFormat('dd MMMM yyyy').format(viewModel.endDate!)
                        : 'Select Date',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        
        if (dailySavings > 0) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(
                          text: 'To achieve your goal, you need to save at least ',
                        ),
                        TextSpan(
                          text: 'Rwf ${_formatAmount(dailySavings)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(
                          text: ' each day',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBottomButtons(
    CreateBudgetStepperViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isLastStep = viewModel.currentStep == 2;
    final canProceed = viewModel.canProceedToNextStep();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: canProceed
                  ? () async {
                      if (isLastStep) {
                        final success = await viewModel.createBudget();
                        if (success && mounted) {
                          Navigator.pop(context, true);
                        }
                      } else {
                        viewModel.nextStep();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.grayPrimary,
              ),
              child: Text(
                isLastStep ? 'Finish' : 'Next',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    CreateBudgetStepperViewModel viewModel,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      viewModel.setEndDate(picked);
    }
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
}
