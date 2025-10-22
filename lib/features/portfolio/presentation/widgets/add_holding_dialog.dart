// Why: Modal dialog for adding new holdings with coin search and validation
// Flutter Concepts: Dialog, Form, TextFormField, FutureBuilder, Autocomplete
// UX: Real-time coin search, input validation, clear error messages

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/holding.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../../../market/domain/entities/crypto_coin.dart';

class AddHoldingDialog extends StatefulWidget {
  final Function(Holding) onAdd;

  const AddHoldingDialog({super.key, required this.onAdd});

  @override
  State<AddHoldingDialog> createState() => _AddHoldingDialogState();
}

class _AddHoldingDialogState extends State<AddHoldingDialog> {
  // Form key - Used to validate all form fields at once
  final _formKey = GlobalKey<FormState>();

  // Text controllers - Manage text input state
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();

  // Datasource for fetching coins
  final _binanceDatasource = BinanceDatasource();

  // Selected coin state
  CryptoCoin? _selectedCoin;
  bool _isLoading = false;

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // Dialog - Modal popup with custom content
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        // SingleChildScrollView - Makes content scrollable if keyboard appears
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            // Form - Groups form fields for validation
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Take minimum space needed
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Holding',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Coin search field
                FutureBuilder<List<CryptoCoin>>(
                  // FutureBuilder - Builds widget based on Future result
                  future: _binanceDatasource.getTopCoins(limit: 100),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }

                    final coins = snapshot.data!;

                    return Autocomplete<CryptoCoin>(
                      // Autocomplete - Search field with suggestions
                      displayStringForOption: (coin) =>
                          '${coin.symbol} - ${coin.name}',
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return coins.take(10);
                        }
                        return coins
                            .where((coin) {
                              final query = textEditingValue.text.toLowerCase();
                              return coin.symbol.toLowerCase().contains(
                                    query,
                                  ) ||
                                  coin.name.toLowerCase().contains(query);
                            })
                            .take(10);
                      },
                      onSelected: (coin) {
                        setState(() {
                          _selectedCoin = coin;
                          // Pre-fill current price
                          _priceController.text = coin.currentPrice
                              .toStringAsFixed(2);
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'Search Coin',
                                hintText: 'BTC, ETH, SOL...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (_selectedCoin == null) {
                                  return 'Please select a coin';
                                }
                                return null;
                              },
                            );
                          },
                    );
                  },
                ),

                // Show selected coin
                if (_selectedCoin != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            _selectedCoin!.symbol[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedCoin!.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _selectedCoin!.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${_selectedCoin!.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Quantity field
                TextFormField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    // FilteringTextInputFormatter - Restricts input to specific pattern
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter quantity';
                    }
                    final quantity = double.tryParse(value);
                    if (quantity == null || quantity <= 0) {
                      return 'Please enter valid quantity';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Average buy price field
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Average Buy Price',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter valid price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Total cost preview
                if (_quantityController.text.isNotEmpty &&
                    _priceController.text.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Cost',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '\$${_calculateTotalCost()}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleAdd,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Add Holding'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _calculateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    return (quantity * price).toStringAsFixed(2);
  }

  Future<void> _handleAdd() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final holding = Holding(
        id: '', // Will be generated by Supabase
        userId: '', // Will be set by datasource
        symbol: _selectedCoin!.symbol,
        coinName: _selectedCoin!.name,
        quantity: double.parse(_quantityController.text),
        averageBuyPrice: double.parse(_priceController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        currentPrice: _selectedCoin!.currentPrice,
      );

      widget.onAdd(holding);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
