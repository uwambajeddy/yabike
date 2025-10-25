import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/services/category_service.dart';
import '../viewmodels/budget_viewmodel.dart';
import '../widgets/budget_progress_indicator.dart';
import '../widgets/budget_bottom_navigation.dart';
import '../steps/budget_name_step.dart';
import '../steps/budget_category_step.dart';
import '../steps/budget_amount_step.dart';
import '../steps/budget_date_step.dart';

class CreateBudgetStepperScreen extends StatefulWidget {
  final bool isEditing;
  
  const CreateBudgetStepperScreen({
    super.key,
    this.isEditing = false,
  });

  @override
  State<CreateBudgetStepperScreen> createState() => _CreateBudgetStepperScreenState();
}

class _CreateBudgetStepperScreenState extends State<CreateBudgetStepperScreen> with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  // Form data
  Category? _selectedCategory;
  String? _selectedPeriod;
  DateTime? _startDate;
  DateTime? _endDate;

  // Category service
  final CategoryService _categoryService = CategoryService.instance;
  List<Category> _categories = [];

  // Period options
  final List<Map<String, dynamic>> _periods = [
    {'name': 'Daily', 'icon': Icons.today, 'days': 1},
    {'name': 'Weekly', 'icon': Icons.calendar_view_week, 'days': 7},
    {'name': 'Monthly', 'icon': Icons.calendar_month, 'days': 30},
    {'name': 'Yearly', 'icon': Icons.calendar_today, 'days': 365},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _loadCategories();
    
    // Pre-fill form if editing (after categories are loaded)
    if (widget.isEditing) {
      _prefillFormData();
    }
  }

  Future<void> _loadCategories() async {
    await _categoryService.initialize();
    setState(() {
      _categories = _categoryService.expenseCategories;
    });
  }

  void _prefillFormData() {
    final viewModel = context.read<BudgetViewModel>();
    final budget = viewModel.editingBudget;
    
    if (budget != null && _categories.isNotEmpty) {
      setState(() {
        _nameController.text = budget.name;
        _amountController.text = budget.amount.toStringAsFixed(0);
        
        // Find and set the matching category
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.name == budget.category,
          orElse: () => _categories.first,
        );
        
        _startDate = budget.startDate;
        _endDate = budget.endDate;
        
        // Calculate period from date range
        final days = budget.endDate.difference(budget.startDate).inDays;
        if (days == 1) {
          _selectedPeriod = 'Daily';
        } else if (days == 7) {
          _selectedPeriod = 'Weekly';
        } else if (days >= 28 && days <= 31) {
          _selectedPeriod = 'Monthly';
        } else if (days >= 365) {
          _selectedPeriod = 'Yearly';
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 3) {
          _currentStep++;
          _animationController.reset();
          _animationController.forward();
        }
      });
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_nameController.text.trim().isEmpty) {
          _showSnackBar('Please enter a budget name', isError: true);
          return false;
        }
        return true;
      case 1:
        if (_selectedCategory == null) {
          _showSnackBar('Please select a category', isError: true);
          return false;
        }
        return true;
      case 2:
        if (_amountController.text.trim().isEmpty) {
          _showSnackBar('Please enter an amount', isError: true);
          return false;
        }
        final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
        if (amount == null || amount <= 0) {
          _showSnackBar('Please enter a valid amount', isError: true);
          return false;
        }
        if (_selectedPeriod == null) {
          _showSnackBar('Please select a period', isError: true);
          return false;
        }
        return true;
      case 3:
        if (_startDate == null || _endDate == null) {
          _showSnackBar('Please select start and end dates', isError: true);
          return false;
        }
        if (_endDate!.isBefore(_startDate!)) {
          _showSnackBar('End date must be after start date', isError: true);
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _createBudget() async {
    if (!_validateCurrentStep()) return;

    try {
      final amount = double.parse(_amountController.text.replaceAll(',', ''));
      final viewModel = context.read<BudgetViewModel>();
      
      if (widget.isEditing && viewModel.editingBudget != null) {
        // Update existing budget
        final updatedBudget = Budget(
          id: viewModel.editingBudget!.id,
          name: _nameController.text.trim(),
          category: _selectedCategory!.name,
          amount: amount,
          period: _selectedPeriod!.toLowerCase(),
          startDate: _startDate!,
          endDate: _endDate!,
          spent: viewModel.editingBudget!.spent, // Keep existing spent amount
          isActive: viewModel.editingBudget!.isActive,
          walletId: viewModel.editingBudget!.walletId,
          createdAt: viewModel.editingBudget!.createdAt,
        );
        
        await viewModel.updateBudget(updatedBudget);
        
        if (mounted) {
          viewModel.clearEditingBudget();
          _showSnackBar('Budget updated successfully!');
          Navigator.pop(context, true);
        }
      } else {
        // Create new budget
        final budget = Budget(
          name: _nameController.text.trim(),
          category: _selectedCategory!.name,
          amount: amount,
          period: _selectedPeriod!.toLowerCase(),
          startDate: _startDate!,
          endDate: _endDate!,
        );

        await viewModel.addBudget(budget);
        
        if (mounted) {
          _showSnackBar('Spending budget created! We\'ll track your expenses automatically.');
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to ${widget.isEditing ? 'update' : 'create'} budget: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Spending Budget' : 'Create Spending Budget',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Set limits to control your expenses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Progress Indicator
          BudgetProgressIndicator(
            currentStep: _currentStep,
            totalSteps: 4,
          ),
          
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
          ),
          
          // Bottom Navigation
          BudgetBottomNavigation(
            currentStep: _currentStep,
            totalSteps: 4,
            onBack: _currentStep > 0 ? _previousStep : null,
            onNext: _currentStep < 3 ? _nextStep : _createBudget,
            finishButtonText: widget.isEditing ? 'Update Budget' : 'Create Budget',
          ),
        ],
      ),
    );
  }


  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return BudgetNameStep(nameController: _nameController);
      case 1:
        return BudgetCategoryStep(
          categories: _categories,
          selectedCategory: _selectedCategory,
          onCategorySelected: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      case 2:
        return BudgetAmountStep(
          amountController: _amountController,
          periods: _periods,
          selectedPeriod: _selectedPeriod,
          onPeriodSelected: (period) {
            setState(() {
              _selectedPeriod = period;
              // Auto-calculate dates based on period
              if (_startDate == null) {
                _startDate = DateTime.now();
              }
              final periodData = _periods.firstWhere((p) => p['name'] == period);
              _endDate = _startDate!.add(Duration(days: periodData['days']));
            });
          },
        );
      case 3:
        return BudgetDateStep(
          startDate: _startDate,
          endDate: _endDate,
          onStartDateSelected: (date) {
            setState(() {
              _startDate = date;
              // Update end date if it's before start date
              if (_endDate != null && _endDate!.isBefore(date)) {
                _endDate = date.add(const Duration(days: 30));
              }
            });
          },
          onEndDateSelected: (date) {
            setState(() {
              _endDate = date;
            });
          },
        );
      default:
        return const SizedBox();
    }
  }

}
