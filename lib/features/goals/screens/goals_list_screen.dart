import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Screen showing savings goals
class GoalsListScreen extends StatefulWidget {
  const GoalsListScreen({super.key});

  @override
  State<GoalsListScreen> createState() => _GoalsListScreenState();
}

class _GoalsListScreenState extends State<GoalsListScreen> {
  // TODO: Replace with actual ViewModel
  final List<Map<String, dynamic>> _goals = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner - Same style as budget but different message
            _buildBanner(context),
            const SizedBox(height: 24),

            // Section title
            Text(
              'Your Goals',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Goals list or empty state
            if (_goals.isNotEmpty)
              _buildGoalsList()
            else
              _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE5FCDC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Piggy bank illustration - Same image
          SizedBox(
            width: 100,
            height: 100,
            child: Image.asset(
              'assets/images/budget-planner-and-money.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Achieve Your Dreams!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF2D6A4F),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to create goal
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create a Goal Today'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD966),
                    foregroundColor: const Color(0xFF2D6A4F),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: theme.textTheme.labelMedium,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Piggy bank with question marks - Same style as budget
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5FCDC),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(
                Icons.savings,
                size: 64,
                color: AppColors.primary,
              ),
              Positioned(
                top: 0,
                right: 20,
                child: Text(
                  '??',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'You don\'t have any goals at the moment.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, 
                size: 16, 
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Try clicking the button above,\nor click here to create a new one.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    return Column(
      children: [
        // TODO: Add actual goals list when ViewModel is ready
        // For now, this will be empty
        const SizedBox(),
      ],
    );
  }
}
