import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/currency_model.dart';
import '../viewmodels/create_wallet_viewmodel.dart';
import 'wallet_balance_screen.dart';

/// Screen for selecting wallet currency
class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String _searchQuery = '';
  
  List<CurrencyModel> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return Currencies.all;
    }
    return Currencies.all.where((currency) {
      return currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _selectCurrency(CurrencyModel currency) {
    final viewModel = context.read<CreateWalletViewModel>();
    viewModel.setSelectedCurrency(currency);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: viewModel,
          child: const WalletBalanceScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateWalletViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Currency'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search currency...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Currency list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected =
                    currency.code == viewModel.selectedCurrency.code;
                
                return ListTile(
                  leading: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    currency.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  subtitle: Text(
                    '${currency.code} (${currency.symbol})',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => _selectCurrency(currency),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
