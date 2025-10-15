import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final String? walletName;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.walletName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'credit';
    final color = isIncome ? AppColors.income : AppColors.expense;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Category indicator bar
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    transaction.category.isEmpty ? 'Uncategorized' : transaction.category,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 2),

                  // Description/Recipient
                  Text(
                    transaction.description.isNotEmpty
                        ? transaction.description
                        : (transaction.recipient?.isNotEmpty ?? false)
                            ? transaction.recipient!
                            : (transaction.sender?.isNotEmpty ?? false)
                                ? transaction.sender!
                                : 'Transaction',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Wallet name (if provided) - as a tag at bottom
                  if (walletName != null && walletName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getWalletColor(walletName!),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        walletName!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getWalletTextColor(walletName!),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Amount and Fee
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${transaction.currency} ${_formatAmount(transaction.amount)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Show fee if it exists and is greater than 0 - as a tag
                if (transaction.fee != null && transaction.fee! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Fee: ${transaction.currency} ${_formatAmount(transaction.fee!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF666666),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  Color _getWalletColor(String walletName) {
    final lowerName = walletName.toLowerCase();
    if (lowerName.contains('equity')) {
      return const Color(0xFFFFEBEE); // Light red background
    } else if (lowerName.contains('mtn') || lowerName.contains('mobile money')) {
      return const Color(0xFFFFF9E6); // Light yellow background
    }
    return const Color(0xFFE8F5E9); // Light green background
  }

  Color _getWalletTextColor(String walletName) {
    final lowerName = walletName.toLowerCase();
    if (lowerName.contains('equity')) {
      return const Color(0xFFD90025); // Equity Bank red
    } else if (lowerName.contains('mtn') || lowerName.contains('mobile money')) {
      return const Color(0xFFB8900A); // Dark yellow for readability
    }
    return const Color(0xFF2E7D32); // Dark green
  }
}
