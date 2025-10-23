
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/watchlist_item.dart';
import '../../../market/data/datasources/binance_datasource.dart';
import '../../../market/domain/entities/crypto_coin.dart';
import 'package:device_info_plus/device_info_plus.dart';


class AddWatchlistDialog extends StatefulWidget {
  final Function(WatchlistItem) onAdd;
  final WatchlistItem? item;

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
  final _lowPriceController = TextEditingController();
  final _highPriceController = TextEditingController();
  final _notesController = TextEditingController();
  final _binanceDatasource = BinanceDatasource();

  CryptoCoin? _selectedCoin;
  bool _alertEnabled = false;
  String? _alarmSoundPath;
  String? _alarmSoundName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _lowPriceController.text =
          widget.item!.targetPriceLow?.toStringAsFixed(2) ?? '';
      _highPriceController.text =
          widget.item!.targetPriceHigh?.toStringAsFixed(2) ?? '';
      _notesController.text = widget.item!.notes ?? '';
      _alertEnabled = widget.item!.alertEnabled;
      _alarmSoundPath = widget.item!.alarmSoundPath;
      if (_alarmSoundPath != null) {
        _alarmSoundName = _alarmSoundPath!.split('/').last;
      }
    }
  }

  @override
  void dispose() {
    _lowPriceController.dispose();
    _highPriceController.dispose();
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
                      isEditing ? 'Edit Alert' : 'Add Price Alert',
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

                // Coin search or display
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
                                'Current: \$${widget.item!.currentPrice.toStringAsFixed(2)}',
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

                // Low target price
                TextFormField(
                  controller: _lowPriceController,
                  decoration: InputDecoration(
                    labelText: 'Low Target (Support)',
                    hintText: 'Alert when price drops below',
                    prefixIcon: const Icon(Icons.arrow_downward),
                    prefixIconColor: AppColors.bearish,
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

                // High target price
                TextFormField(
                  controller: _highPriceController,
                  decoration: InputDecoration(
                    labelText: 'High Target (Resistance)',
                    hintText: 'Alert when price rises above',
                    prefixIcon: const Icon(Icons.arrow_upward),
                    prefixIconColor: AppColors.bullish,
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
                    if (_lowPriceController.text.isEmpty &&
                        (value == null || value.isEmpty)) {
                      return 'Set at least one target price';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Alert toggle
                SwitchListTile(
                  value: _alertEnabled,
                  onChanged: (value) {
                    setState(() => _alertEnabled = value);
                  },
                  title: const Text('Enable Price Alert'),
                  subtitle: const Text('Notify when target is reached'),
                  activeThumbColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),

                // Alarm sound selector
                if (_alertEnabled) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickAlarmSound,
                    icon: Icon(
                      _alarmSoundPath != null
                          ? Icons.music_note
                          : Icons.music_off,
                    ),
                    label: Text(
                      _alarmSoundName ?? 'Choose Alarm Sound',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  if (_alarmSoundPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                            size: 16,
                            color: AppColors.bullish,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _alarmSoundName!,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              setState(() {
                                _alarmSoundPath = null;
                                _alarmSoundName = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Trading strategy, reasons...',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
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

Future<void> _pickAlarmSound() async {
  try {
    // Request appropriate permission based on Android version
    PermissionStatus status;
    
    if (await _isAndroid13OrHigher()) {
      // Android 13+ requires READ_MEDIA_AUDIO
      status = await Permission.audio.request();
    } else {
      // Android 12 and below requires READ_EXTERNAL_STORAGE
      status = await Permission.storage.request();
    }

    if (status.isDenied) {
      if (mounted) {
        _showPermissionDialog('Permission Denied', 
          'Storage permission is required to select alarm sounds.');
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog('Permission Required', 
          'Please enable storage permission in app settings.',
          showSettings: true);
      }
      return;
    }

    // Pick audio file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _alarmSoundPath = result.files.first.path;
        _alarmSoundName = result.files.first.name;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: AppColors.bearish,
        ),
      );
    }
  }
}


Future<bool> _isAndroid13OrHigher() async {
  if (Theme.of(context).platform == TargetPlatform.android) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt >= 33; // Android 13 = API 33
  }
  return false;
}


void _showPermissionDialog(String title, String message, {bool showSettings = false}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (showSettings)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          )
        else
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _pickAlarmSound(); // Retry
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
      ],
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
        targetPriceLow: _lowPriceController.text.isEmpty
            ? null
            : double.parse(_lowPriceController.text),
        targetPriceHigh: _highPriceController.text.isEmpty
            ? null
            : double.parse(_highPriceController.text),
        alertEnabled: _alertEnabled,
        alarmSoundPath: _alarmSoundPath,
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
