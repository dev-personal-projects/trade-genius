// Add import at top
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:tradegenius/core/theme/app_theme.dart';
import 'package:tradegenius/features/portfolio/domain/entities/watchlist_item.dart';

class WatchlistCard extends StatefulWidget {
  final WatchlistItem item;
  final Stream<double>? priceStream;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const WatchlistCard({
    super.key,
    required this.item,
    this.priceStream,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Coin avatar
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      widget.item.symbol[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Coin info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.item.symbol,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (widget.item.alertEnabled) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.notifications_active,
                                size: 16,
                                color: AppColors.warning,
                              ),
                            ],
                            if (widget.item.alarmSoundPath != null) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.music_note,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          widget.item.coinName,
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

                  // Current price with live updates
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.priceStream != null)
                        StreamBuilder<double>(
                          stream: widget.priceStream,
                          initialData: widget.item.currentPrice,
                          builder: (context, snapshot) {
                            final price = snapshot.data ?? widget.item.currentPrice;
                            return Text(
                              '\$${price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getPriceColor(price),
                              ),
                            );
                          },
                        )
                      else
                        Text(
                          '\$${widget.item.currentPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),

                  // Actions menu
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: widget.onEdit,
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: widget.onRemove,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.delete,
                              size: 20,
                              color: AppColors.bearish,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Remove',
                              style: TextStyle(color: AppColors.bearish),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Alarm sound player (NEW)
              if (widget.item.alarmSoundPath != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alarm Sound',
                              style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            Text(
                              widget.item.alarmSoundPath!.split('/').last,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.stop_circle : Icons.play_circle,
                          color: AppColors.primary,
                        ),
                        onPressed: _togglePlayback,
                      ),
                    ],
                  ),
                ),
              ],

              // Target price range indicator
              if (widget.item.targetPriceLow != null || 
                  widget.item.targetPriceHigh != null) ...[
                const SizedBox(height: 12),
                
                Column(
                  children: [
                    if (widget.item.targetPriceHigh != null)
                      _buildTargetRow(
                        context,
                        'High Target',
                        widget.item.targetPriceHigh!,
                        Icons.arrow_upward,
                        AppColors.bullish,
                        widget.item.currentPrice >= widget.item.targetPriceHigh!,
                      ),
                    
                    if (widget.item.targetPriceLow != null && 
                        widget.item.targetPriceHigh != null)
                      const SizedBox(height: 8),
                    
                    if (widget.item.targetPriceLow != null)
                      _buildTargetRow(
                        context,
                        'Low Target',
                        widget.item.targetPriceLow!,
                        Icons.arrow_downward,
                        AppColors.bearish,
                        widget.item.currentPrice <= widget.item.targetPriceLow!,
                      ),
                  ],
                ),

                if (widget.item.shouldAlert) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notification_important,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TARGET REACHED!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              // Notes
              if (widget.item.notes != null && widget.item.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.item.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (widget.item.alarmSoundPath == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.item.alarmSoundPath!));
        setState(() => _isPlaying = true);
        
        // Auto-stop when finished
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing sound: $e'),
            backgroundColor: AppColors.bearish,
          ),
        );
      }
    }
  }

  Widget _buildTargetRow(
    BuildContext context,
    String label,
    double price,
    IconData icon,
    Color color,
    bool isHit,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isHit ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          if (isHit)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'HIT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPriceColor(double price) {
    if (widget.item.targetPriceHigh != null && 
        price >= widget.item.targetPriceHigh!) {
      return AppColors.bullish;
    }
    if (widget.item.targetPriceLow != null && 
        price <= widget.item.targetPriceLow!) {
      return AppColors.bearish;
    }
    if (widget.item.isInTargetRange) {
      return AppColors.warning;
    }
    return AppColors.primary;
  }
}
