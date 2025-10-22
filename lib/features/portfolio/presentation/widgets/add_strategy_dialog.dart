// Why: Form dialog to create new trading strategy
// Flutter Concepts: Dialog, Form, TextFormField validation, DropdownButton
// UX: Validation, optional fields, tag input, status selection

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/trading_strategy.dart';

class AddStrategyDialog extends StatefulWidget {
  final TradingStrategy? strategy; // Optional - null for add, non-null for edit

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
  
  late StrategyStatus _status;
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if editing existing strategy
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

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
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
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          // SingleChildScrollView - Makes content scrollable if keyboard appears
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
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Symbol (optional)
                  TextFormField(
                    controller: _symbolController,
                    decoration: const InputDecoration(
                      labelText: 'Symbol',
                      hintText: 'e.g., BTCUSDT',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  
                  // Description (optional)
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Strategy details...',
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
                          decoration: const InputDecoration(labelText: 'Entry Price'),
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
                          decoration: const InputDecoration(labelText: 'Target'),
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
                          decoration: const InputDecoration(labelText: 'Stop Loss'),
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
                    decoration: const InputDecoration(labelText: 'Status'),
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
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          if (_tagController.text.isNotEmpty) {
                            setState(() {
                              _tags.add(_tagController.text);
                              _tagController.clear();
                            });
                          }
                        },
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
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'Update' : 'Create'),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final strategy = TradingStrategy(
      id: widget.strategy?.id ?? '', // Preserve ID if editing
      userId: widget.strategy?.userId ?? '', // Preserve or set by datasource
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
