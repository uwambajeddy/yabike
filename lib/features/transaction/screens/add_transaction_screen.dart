import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transaction_model.dart';
import '../viewmodels/add_transaction_viewmodel.dart';
import '../widgets/date_picker_bottom_sheet.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final _amountController = TextEditingController();
  final _transactionNameController = TextEditingController();
  final _noteController = TextEditingController();
  
  String? _selectedEmoji;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<AddTransactionViewModel>();
      viewModel.initialize(widget.transaction);
      
      // Listen to ViewModel changes and update controllers
      viewModel.addListener(() {
        // Update amount controller if amount changed
        if (viewModel.amount > 0 && _amountController.text != viewModel.amount.toString()) {
          _amountController.text = viewModel.amount.toString();
        }
        // Update description controller if description changed
        if (viewModel.description.isNotEmpty && _transactionNameController.text != viewModel.description) {
          _transactionNameController.text = viewModel.description;
        }
        
        // Show feedback for scan results
        if (viewModel.lastScanError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showScanFeedback(viewModel, isError: true);
          });
        } else if (viewModel.lastScanConfidence != null && viewModel.lastScanConfidence! < 0.5) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showScanFeedback(viewModel, isError: false);
          });
        }
      });
      
      // Pre-fill form if editing
      if (widget.transaction != null) {
        final tx = widget.transaction!;
        _amountController.text = tx.amount.toString();
        _transactionNameController.text = tx.description;
        _noteController.text = tx.rawMessage;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _amountController.dispose();
    _transactionNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
          ),
          onPressed: _previousPage,
        ),
        title: Text(
          widget.transaction != null ? 'Edit Transaction' : _getPageTitle(_currentPage),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<AddTransactionViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // Step indicator
              _buildStepIndicator(),
              
              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildWalletCategoriesPage(viewModel),
                    _buildAmountPage(viewModel),
                    _buildDateTimePage(viewModel),
                    _buildNotePage(viewModel),
                    _buildReviewPage(viewModel),
                  ],
                ),
              ),
              
              // Bottom buttons
              _buildBottomButtons(viewModel),
            ],
          );
        },
      ),
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'New Transaction';
      case 1:
        return 'Amount';
      case 2:
        return 'Date & Time';
      case 3:
        return 'Note';
      case 4:
        return 'Review';
      default:
        return 'New Transaction';
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _buildStepItem(1, 'Wallet & Categories', 0),
          _buildStepDivider(0),
          _buildStepItem(2, 'Amount', 1),
          _buildStepDivider(1),
          _buildStepItem(3, 'Date & Time', 2),
          _buildStepDivider(2),
          _buildStepItem(4, 'Name & Note', 3, isLast: true),
          _buildStepDivider(3),
          _buildStepItem(5, 'Review', 4, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, int pageIndex, {bool isLast = false}) {
    final isActive = _currentPage == pageIndex;
    final isCompleted = _currentPage > pageIndex;
    
    return Column(
      children: [
        Text(
          '$step.',
          style: TextStyle(
            color: isActive ? AppColors.primary : isCompleted ? AppColors.primary : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : Colors.grey,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(int pageIndex) {
    final isCompleted = _currentPage > pageIndex;
    
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isCompleted ? AppColors.primary : Colors.grey.shade300,
      ),
    );
  }

  // Page 1: Wallet & Categories
  Widget _buildWalletCategoriesPage(AddTransactionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Wallet dropdown (always visible)
          const Text(
            'Wallet',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: viewModel.selectedWallet,
            decoration: InputDecoration(
              hintText: 'Choose your wallet',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            items: viewModel.wallets.map((wallet) {
              return DropdownMenuItem(
                value: wallet,
                child: Text(wallet.name),
              );
            }).toList(),
            onChanged: (wallet) {
              if (wallet != null) {
                viewModel.setWallet(wallet);
              }
            },
          ),
          
          // Step 2: Show "Choose Categories" section only after wallet is selected
          if (viewModel.selectedWallet != null) ...[
            const SizedBox(height: 24),
            
            const Text(
              'Choose Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            
            // Income/Expense toggle
            Row(
              children: [
                Expanded(
                  child: _buildCategoryTypeCard(
                    'Income',
                    '💰',
                    TransactionType.income,
                    viewModel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCategoryTypeCard(
                    'Expenses',
                    '💸',
                    TransactionType.expense,
                    viewModel,
                  ),
                ),
              ],
            ),
          ],
          
          // Step 3: Show selected category only after type is selected
          if (viewModel.selectedWallet != null && viewModel.type != null) ...[
            const SizedBox(height: 16),
            
            if (viewModel.selectedCategory != null) ...[
              // Show selected category with edit button
              GestureDetector(
                onTap: () => _showCategoryBottomSheet(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.selectedCategory!.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (viewModel.type == TransactionType.income 
                                    ? AppColors.income 
                                    : AppColors.expense).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                viewModel.type == TransactionType.income ? 'Income' : 'Expense',
                                style: TextStyle(
                                  color: viewModel.type == TransactionType.income 
                                      ? AppColors.income 
                                      : AppColors.expense,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Edit',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Show placeholder when no category selected
              GestureDetector(
                onTap: () => _showCategoryBottomSheet(context, viewModel),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showCategoryBottomSheet(BuildContext context, AddTransactionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    viewModel.type == TransactionType.income 
                        ? 'Earned Income' 
                        : 'Expense Categories',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Category list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: viewModel.filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = viewModel.filteredCategories[index];
                  final isSelected = viewModel.selectedCategory?.id == category.id;
                  
                  return GestureDetector(
                    onTap: () {
                      viewModel.setCategory(category);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Category icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: category.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isSelected) ...[
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                                if (category.description.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    category.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTypeCard(String label, String emoji, TransactionType type, AddTransactionViewModel viewModel) {
    final isSelected = viewModel.type == type;
    
    return GestureDetector(
      onTap: () => viewModel.setType(type),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page 2: Amount
  Widget _buildAmountPage(AddTransactionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              // Emoji/Icon selector button
              GestureDetector(
                onTap: () => _showEmojiPicker(context),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji ?? '?',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Amount input
              Expanded(
                child: TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    hintText: 'Enter new amount',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final amount = double.tryParse(value.replaceAll(',', '')) ?? 0;
                    viewModel.setAmount(amount);
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Center(child: Text('Or', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 16),
          
          // Scan Receipt button
          if (viewModel.isScanning)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Scanning receipt...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: () => _showScanOptions(context, viewModel),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Scan Receipt',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 8),
          Text(
            'By scanning the receipt, our system will automatically add all the receipt\'s data to the app.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Icon',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Icon categories
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmojiSection('Money', [
                      '💰', '💵', '🏦', '💳', '💴', '💶', '💷', '💸'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Gift', [
                      '🎁', '🧧'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Chart', [
                      '📈', '📊', '📉'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Food & Drink', [
                      '🍕', '🍔', '🍟', '🌮', '🍱', '🍜', '☕', '🍺'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Transport', [
                      '🚗', '🚕', '🚌', '🚎', '🏍️', '🚲', '✈️', '🚂'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Shopping', [
                      '🛍️', '👕', '👔', '👗', '👠', '💄', '📱', '💻'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Health', [
                      '💊', '🏥', '⚕️', '🩺', '💉', '🧘', '🏋️', '🧴'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Entertainment', [
                      '🎬', '🎮', '🎵', '🎸', '🎨', '📚', '⚽', '🎾'
                    ]),
                    const SizedBox(height: 16),
                    _buildEmojiSection('Other', [
                      '🏠', '🔧', '💡', '📝', '🎓', '✈️', '🌍', '⭐'
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiSection(String title, List<String> emojis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emojis.map((emoji) {
            final isSelected = _selectedEmoji == emoji;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedEmoji = emoji;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Page 3: Date & Time
  Widget _buildDateTimePage(AddTransactionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          InkWell(
            onTap: () => _showDatePicker(context, viewModel),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isToday(viewModel.date)
                        ? 'Select Date'
                        : '${viewModel.date.day.toString().padLeft(2, '0')} ${_getMonthName(viewModel.date.month)} ${viewModel.date.year}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Time',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          // Time display - clickable
          InkWell(
            onTap: () => _showTimePicker(context, viewModel),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTimeSegment(
                    viewModel.date.hour > 12 
                        ? (viewModel.date.hour - 12).toString().padLeft(2, '0')
                        : viewModel.date.hour == 0 
                            ? '12' 
                            : viewModel.date.hour.toString().padLeft(2, '0'),
                    'Hour',
                  ),
                  const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  _buildTimeSegment(
                    viewModel.date.minute.toString().padLeft(2, '0'),
                    'Minute',
                  ),
                  _buildTimeSegment(
                    viewModel.date.hour >= 12 ? 'PM' : 'AM',
                    'Period',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSegment(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _showDatePicker(BuildContext context, AddTransactionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerBottomSheet(
        initialDate: viewModel.date,
        onDateSelected: (date) {
          viewModel.setDate(DateTime(
            date.year,
            date.month,
            date.day,
            viewModel.date.hour,
            viewModel.date.minute,
          ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimePicker(BuildContext context, AddTransactionViewModel viewModel) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: viewModel.date.hour, minute: viewModel.date.minute),
    );
    
    if (picked != null) {
      viewModel.setDate(DateTime(
        viewModel.date.year,
        viewModel.date.month,
        viewModel.date.day,
        picked.hour,
        picked.minute,
      ));
    }
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Page 4: Note
  Widget _buildNotePage(AddTransactionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Name',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          TextField(
            controller: _transactionNameController,
            decoration: InputDecoration(
              hintText: 'Enter the name of your transaction',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: viewModel.setDescription,
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Note (Optional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Enter your transaction note',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            maxLines: 3,
            onChanged: viewModel.setNote,
          ),
        ],
      ),
    );
  }

  // Page 5: Review
  Widget _buildReviewPage(AddTransactionViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Icon and name
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (viewModel.type == TransactionType.income 
                            ? AppColors.income 
                            : AppColors.expense).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _selectedEmoji ?? '💰',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewModel.description.isEmpty ? 'Transaction' : viewModel.description,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (viewModel.type == TransactionType.income 
                                  ? AppColors.income 
                                  : AppColors.expense).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              viewModel.type == TransactionType.income ? 'Income' : 'Expense',
                              style: TextStyle(
                                color: viewModel.type == TransactionType.income 
                                    ? AppColors.income 
                                    : AppColors.expense,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Amount
                const Text(
                  'Amount',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  '${viewModel.type == TransactionType.income ? '+' : '-'}${viewModel.selectedWallet?.currency ?? 'RWF'} ${viewModel.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: viewModel.type == TransactionType.income ? AppColors.income : AppColors.expense,
                  ),
                ),
                
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                
                // Details
                _buildReviewRow('Categories', viewModel.selectedCategory?.name ?? 'Not selected'),
                const SizedBox(height: 12),
                _buildReviewRow('Type', 'Manual'),
                const SizedBox(height: 12),
                _buildReviewRow('Date', '${viewModel.date.day.toString().padLeft(2, '0')} ${_getMonthName(viewModel.date.month)} ${viewModel.date.year}'),
                const SizedBox(height: 12),
                _buildReviewRow('Time', '${viewModel.date.hour.toString().padLeft(2, '0')}:${viewModel.date.minute.toString().padLeft(2, '0')} ${viewModel.date.hour >= 12 ? 'PM' : 'AM'}'),
                const SizedBox(height: 12),
                _buildReviewRow('Note', viewModel.note?.isEmpty ?? true ? '-' : viewModel.note!),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Edit button
          OutlinedButton.icon(
            onPressed: () {
              _pageController.jumpToPage(0);
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Information'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(AddTransactionViewModel viewModel) {
    final isLastPage = _currentPage == 4;
    final canProceed = _canProceed(viewModel);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                      if (isLastPage) {
                        final success = await viewModel.saveTransaction();
                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Transaction saved successfully'),
                              backgroundColor: AppColors.income,
                            ),
                          );
                        }
                      } else {
                        _nextPage();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isLastPage ? 'Finish' : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed(AddTransactionViewModel viewModel) {
    switch (_currentPage) {
      case 0: // Wallet & Categories
        return viewModel.selectedWallet != null && viewModel.selectedCategory != null;
      case 1: // Amount
        return viewModel.amount > 0;
      case 2: // Date & Time
        return true;
      case 3: // Note
        return viewModel.description.isNotEmpty;
      case 4: // Review
        return viewModel.canSave;
      default:
        return false;
    }
  }

  void _showScanOptions(BuildContext context, AddTransactionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Scan Receipt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Take a Picture'),
              onTap: () {
                Navigator.pop(context);
                viewModel.scanReceipt(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Select from Gallery'),
              onTap: () {
                Navigator.pop(context);
                viewModel.scanReceipt(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showScanFeedback(AddTransactionViewModel viewModel, {required bool isError}) {
    final message = isError 
        ? viewModel.lastScanError ?? 'Scan failed'
        : 'Low confidence scan (${(viewModel.lastScanConfidence! * 100).toStringAsFixed(0)}%). Please verify and fill missing fields.';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.warning_amber,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.orange.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    viewModel.clearScanFeedback();
  }
}
