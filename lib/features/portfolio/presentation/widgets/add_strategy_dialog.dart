// Why: Form dialog to create new trading strategy with coin autocomplete
// Flutter Concepts: Dialog, Form, Autocomplete widget, FutureBuilder
// UX: Search coins from Binance, validation, optional fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/trading_strategy.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../../../market/domain/entities/crypto_coin.dart';

class AddStrategyDialog extends StatefulWidget {
  final TradingStrategy? strategy;

  const AddStrategyDialog({super.key, this.strategy});

  @override
  State<AddStrategyDialog> createState() => _AddStrategyDialogState();
}

class _AddStrategyDialogState extends State<AddStrategyDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _symbolController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _stopLossController = TextEditingController();
  final _tagController = TextEditingController();

  final _binanceDatasource = BinanceDatasource();
  List<CryptoCoin>? _coins; // Cached coin list

  late StrategyStatus _status;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _loadCoins(); // Load coins from Binance

    // Pre-fill form if editing
    if (widget.strategy != null) {
      _titleController.text = widget.strategy!.title;
      _descriptionController.text = widget.strategy!.description ?? '';
      _symbolController.text = widget.strategy!.symbol ?? '';
      _entryPriceController.text = widget.strategy!.entryPrice?.toString() ?? '';
      _targetPriceController.text = widget.strategy!.targetPrice?.toString() ?? '';
      _stopLossController.text = widget.strategy!.stopLoss?.toString() ?? '';
      _status = widget.strategy!.status;
      _tags = List.from(widget.strategy!.tags);
    } else {
      _status = StrategyStatus.active;
      _tags = [];
    }
  }

  Future<void> _loadCoins() async {
    try {
      final coins = await _binanceDatasource.getTopCoins(limit: 100);
      if (mounted) {
        setState(() => _coins = coins);
      }
    } catch (e) {
      // Silently fail - user can still type symbol manually
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _symbolController.dispose();
    _entryPriceController.dispose();
    _targetPriceController.dispose();
    _stopLossController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.strategy != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Strategy' : 'New Trading Strategy',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // Title (required)
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g., BTC Breakout Strategy',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) =>
                    value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Symbol with Autocomplete
                  _buildSymbolAutocomplete(),
                  const SizedBox(height: 16),

                  // Description (optional)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Strategy details...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Price levels row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _entryPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Entry',
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _targetPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Target',
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stopLossController,
                          decoration: const InputDecoration(
                            labelText: 'Stop',
                            prefixText: '\$ ',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<StrategyStatus>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: StrategyStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 16),

                  // Tags input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            labelText: 'Add Tag',
                            hintText: 'e.g., scalping',
                            prefixIcon: Icon(Icons.label),
                          ),
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        onPressed: _addTag,
                      ),
                    ],
                  ),

                  // Display tags
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _tags.map((tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => setState(() => _tags.remove(tag)),
                      )).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label: Text(isEditing ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Autocomplete widget for symbol selection
  Widget _buildSymbolAutocomplete() {
    if (_coins == null) {
      // Loading state
      return TextFormField(
        controller: _symbolController,
        decoration: const InputDecoration(
          labelText: 'Symbol',
          hintText: 'Loading coins...',
          prefixIcon: Icon(Icons.currency_bitcoin),
        ),
        enabled: false,
      );
    }

    return Autocomplete<CryptoCoin>(
      // Autocomplete - Material widget for searchable dropdown
      initialValue: TextEditingValue(text: _symbolController.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _coins!.take(10); // Show top 10 by default
        }
        // Filter coins by symbol or name
        return _coins!.where((coin) {
          final query = textEditingValue.text.toLowerCase();
          return coin.symbol.toLowerCase().contains(query) ||
              coin.name.toLowerCase().contains(query);
        }).take(10);
      },
      displayStringForOption: (CryptoCoin coin) => coin.symbol,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Symbol',
            hintText: 'Search coin (e.g., BTC)',
            prefixIcon: const Icon(Icons.currency_bitcoin),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller.clear();
                _symbolController.clear();
              },
            )
                : null,
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: (value) => _symbolController.text = value,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final coin = options.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        coin.symbol[0],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(coin.symbol),
                    subtitle: Text(coin.name),
                    trailing: Text(
                      '\$${coin.currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      onSelected(coin);
                      _symbolController.text = coin.symbol;
                      // Auto-fill entry price with current price
                      if (_entryPriceController.text.isEmpty) {
                        _entryPriceController.text = coin.currentPrice.toStringAsFixed(2);
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _addTag() {
    if (_tagController.text.isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text);
        _tagController.clear();
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final strategy = TradingStrategy(
      id: widget.strategy?.id ?? '',
      userId: widget.strategy?.userId ?? '',
      title: _titleController.text,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      symbol: _symbolController.text.isEmpty
          ? null
          : _symbolController.text.toUpperCase(),
      tags: _tags,
      entryPrice: _entryPriceController.text.isEmpty
          ? null
          : double.parse(_entryPriceController.text),
      targetPrice: _targetPriceController.text.isEmpty
          ? null
          : double.parse(_targetPriceController.text),
      stopLoss: _stopLossController.text.isEmpty
          ? null
          : double.parse(_stopLossController.text),
      status: _status,
      createdAt: widget.strategy?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.pop(context, strategy);
  }
}
