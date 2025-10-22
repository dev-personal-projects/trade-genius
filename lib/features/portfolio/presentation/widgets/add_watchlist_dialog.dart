// Why: Dialog for adding/editing watchlist items
// Flutter Concepts: Form, Autocomplete, Switch for alerts
// UX: Coin search, optional target price, alert toggle, notes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../../../market/domain/entities/crypto_coin.dart';

class AddWatchlistDialog extends StatefulWidget {
  final Function(WatchlistItem) onAdd;
  final WatchlistItem? item; // For editing

  const AddWatchlistDialog({
    super.key,
    required this.onAdd,
    this.item,
  });

  @override
  State<AddWatchlistDialog> createState() => _AddWatchlistDialogState();
}

class _AddWatchlistDialogState extends State<AddWatchlistDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetPriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _binanceDatasource = BinanceDatasource();

  CryptoCoin? _selectedCoin;
  bool _alertEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      // Pre-fill for editing
      _targetPriceController.text =
          widget.item!.targetPrice?.toStringAsFixed(2) ?? '';
      _notesController.text = widget.item!.notes ?? '';
      _alertEnabled = widget.item!.alertEnabled;
    }
  }

  @override
  void dispose() {
    _targetPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Watchlist' : 'Add to Watchlist',
                      style: const TextStyle(
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

                // Coin search (only for new items)
                if (!isEditing)
                  FutureBuilder<List<CryptoCoin>>(
                    future: _binanceDatasource.getTopCoins(limit: 100),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }

                      final coins = snapshot.data!;

                      return Autocomplete<CryptoCoin>(
                        displayStringForOption: (coin) =>
                        '${coin.symbol} - ${coin.name}',
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return coins.take(10);
                          }
                          return coins.where((coin) {
                            final query = textEditingValue.text.toLowerCase();
                            return coin.symbol.toLowerCase().contains(query) ||
                                coin.name.toLowerCase().contains(query);
                          }).take(10);
                        },
                        onSelected: (coin) {
                          setState(() => _selectedCoin = coin);
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
                  )
                else
                // Show coin info when editing
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            widget.item!.symbol[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item!.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.item!.coinName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Target price (optional)
                TextFormField(
                  controller: _targetPriceController,
                  decoration: InputDecoration(
                    labelText: 'Target Price (Optional)',
                    hintText: '0.00',
                    prefixIcon: const Icon(Icons.flag),
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
                ),

                const SizedBox(height: 16),

                // Alert toggle
                SwitchListTile(
                  value: _alertEnabled,
                  onChanged: (value) {
                    setState(() => _alertEnabled = value);
                  },
                  title: const Text('Enable Price Alert'),
                  subtitle: const Text('Notify when target price is reached'),
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add your thoughts...',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
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
                        onPressed: _isLoading ? null : _handleSubmit,
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
                            : Text(isEditing ? 'Update' : 'Add'),
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

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = WatchlistItem(
        id: widget.item?.id ?? '',
        userId: widget.item?.userId ?? '',
        symbol: widget.item?.symbol ?? _selectedCoin!.symbol,
        coinName: widget.item?.coinName ?? _selectedCoin!.name,
        targetPrice: _targetPriceController.text.isEmpty
            ? null
            : double.parse(_targetPriceController.text),
        alertEnabled: _alertEnabled,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
        currentPrice: widget.item?.currentPrice ?? _selectedCoin!.currentPrice,
      );

      widget.onAdd(item);

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
