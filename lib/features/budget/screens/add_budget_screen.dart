import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/budget_model.dart';
import '../viewmodels/add_budget_viewmodel.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget; // For editing existing budget
  
  const AddBudgetScreen({
    super.key,
    this.budget,
  });

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AddBudgetViewModel>();
      if (widget.budget != null) {
        viewModel.initializeForEdit(widget.budget!);
        _nameController.text = widget.budget!.name;
        _amountController.text = widget.budget!.amount.toStringAsFixed(0);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddBudgetViewModel>();
    final isEditing = widget.budget != null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Edit Budget' : 'Create Budget',
          style: theme.textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Budget Name
            Text(
              'Budget Name',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Monthly Groceries',
                filled: true,
                fillColor: AppColors.whiteTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a budget name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Category Selection
            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showCategoryPicker(context, viewModel),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteTertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      viewModel.selectedCategory ?? 'Select Category',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: viewModel.selectedCategory != null
                            ? colorScheme.onSurface
                            : AppColors.textHint,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, 
                      size: 16, 
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.selectedCategory == null && viewModel.showValidation)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  'Please select a category',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Budget Amount
            Text(
              'Budget Amount',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                hintText: '0',
                prefixText: 'UGX ',
                filled: true,
                fillColor: AppColors.whiteTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Period Selection
            Text(
              'Budget Period',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPeriodChip('daily', 'Daily', viewModel),
                const SizedBox(width: 8),
                _buildPeriodChip('weekly', 'Weekly', viewModel),
                const SizedBox(width: 8),
                _buildPeriodChip('monthly', 'Monthly', viewModel),
                const SizedBox(width: 8),
                _buildPeriodChip('yearly', 'Yearly', viewModel),
              ],
            ),
            const SizedBox(height: 24),

            // Date Range
            Text(
              'Date Range',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    context,
                    'Start Date',
                    viewModel.startDate,
                    () => _selectStartDate(context, viewModel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    context,
                    'End Date',
                    viewModel.endDate,
                    () => _selectEndDate(context, viewModel),
                  ),
                ),
              ],
            ),
            if (viewModel.startDate == null && viewModel.showValidation)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 8),
                child: Text(
                  'Please select start and end dates',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Wallet Selection (Optional)
            Text(
              'Wallet (Optional)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showWalletPicker(context, viewModel),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteTertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      viewModel.selectedWallet ?? 'All Wallets',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: viewModel.selectedWallet != null
                            ? colorScheme.onSurface
                            : AppColors.textHint,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, 
                      size: 16, 
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading ? null : () => _saveBudget(context, viewModel),
                child: viewModel.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Budget' : 'Create Budget',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimary,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String value, String label, AddBudgetViewModel viewModel) {
    final theme = Theme.of(context);
    final isSelected = viewModel.selectedPeriod == value;
    
    return Expanded(
      child: InkWell(
        onTap: () => viewModel.setPeriod(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.whiteTertiary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? date,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.whiteTertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, 
              size: 16, 
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM dd, yyyy').format(date)
                    : label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: date != null 
                    ? colorScheme.onSurface 
                    : AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(BuildContext context, AddBudgetViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ...viewModel.categories.map((category) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                category,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: viewModel.selectedCategory == category
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                viewModel.setCategory(category);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _showWalletPicker(BuildContext context, AddBudgetViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Wallet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'All Wallets',
                style: theme.textTheme.bodyLarge,
              ),
              trailing: viewModel.selectedWallet == null
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                viewModel.setWallet(null);
                Navigator.pop(context);
              },
            ),
            ...viewModel.wallets.map((wallet) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                wallet,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: viewModel.selectedWallet == wallet
                  ? Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                viewModel.setWallet(wallet);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context, AddBudgetViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
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
      viewModel.setStartDate(picked);
    }
  }

  Future<void> _selectEndDate(BuildContext context, AddBudgetViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.endDate ?? viewModel.startDate ?? DateTime.now(),
      firstDate: viewModel.startDate ?? DateTime(2020),
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

  Future<void> _saveBudget(BuildContext context, AddBudgetViewModel viewModel) async {
    // Trigger validation
    viewModel.setShowValidation(true);

    if (!_formKey.currentState!.validate() ||
        viewModel.selectedCategory == null ||
        viewModel.startDate == null ||
        viewModel.endDate == null) {
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final success = await viewModel.saveBudget(
      name: name,
      amount: amount,
      existingBudgetId: widget.budget?.id,
    );

    if (success && mounted) {
      Navigator.pop(context, true); // Return true to indicate success
    }
  }
}
