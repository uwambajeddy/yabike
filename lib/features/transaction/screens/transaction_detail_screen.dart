import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/transaction_model.dart';
import '../viewmodels/transaction_detail_viewmodel.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionDetailViewModel>().initialize(widget.transaction);
    });
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Detail',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<TransactionDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final transaction = viewModel.transaction!;
          final isIncome = transaction.type == 'credit';
          final color = isIncome ? AppColors.income : AppColors.expense;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Main transaction card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // Icon and title with menu
                      Row(
                        children: [
                          // Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                viewModel.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title and badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description.isNotEmpty
                                      ? transaction.description
                                      : (transaction.recipient?.isNotEmpty ?? false)
                                          ? transaction.recipient!
                                          : (transaction.sender?.isNotEmpty ?? false)
                                              ? transaction.sender!
                                              : 'Transaction',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isIncome ? 'Income' : 'Expense',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Menu button
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {
                              _showOptionsMenu(context, viewModel);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Amount
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${isIncome ? '+' : '-'}${transaction.currency} ${_formatAmount(transaction.amount)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Details
                      _buildDetailRow('Categories', transaction.category.isEmpty ? 'Uncategorized' : transaction.category),
                      const SizedBox(height: 12),
                      _buildDetailRow('Type', transaction.source),
                      const SizedBox(height: 12),
                      _buildDetailRow('Date', DateFormat('dd MMMM yyyy').format(transaction.date)),
                      const SizedBox(height: 12),
                      _buildDetailRow('Time', DateFormat('hh:mm a').format(transaction.date)),
                      const SizedBox(height: 12),
                      if (transaction.fee != null && transaction.fee! > 0) ...[
                        _buildDetailRow('Fee', '${transaction.currency} ${_formatAmount(transaction.fee!)}'),
                        const SizedBox(height: 12),
                      ],
                      if (transaction.reference != null && transaction.reference!.isNotEmpty) ...[
                        _buildDetailRow('Reference', transaction.reference!),
                        const SizedBox(height: 12),
                      ],
                      if (transaction.recipient != null && transaction.recipient!.isNotEmpty) ...[
                        _buildDetailRow('Recipient', transaction.recipient!),
                        const SizedBox(height: 12),
                      ],
                      if (transaction.sender != null && transaction.sender!.isNotEmpty) ...[
                        _buildDetailRow('Sender', transaction.sender!),
                        const SizedBox(height: 12),
                      ],
                      _buildDetailRow('Note', viewModel.note.isEmpty ? '-' : viewModel.note),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Shortcut section
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Shortcut',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Add new transaction button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.addTransaction);
                  },
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text(
                    'Add new transaction',
                    style: TextStyle(color: Colors.black),
                  ),
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
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _showOptionsMenu(BuildContext context, TransactionDetailViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Edit option
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit transaction
              },
            ),

            // Delete option
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.expense),
              title: const Text(
                'Delete Transaction',
                style: TextStyle(color: AppColors.expense),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, viewModel);
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TransactionDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              final success = await viewModel.deleteTransaction();
              if (success && mounted) {
                Navigator.pop(context); // Go back to previous screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Transaction deleted successfully'),
                    backgroundColor: AppColors.income,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
}
