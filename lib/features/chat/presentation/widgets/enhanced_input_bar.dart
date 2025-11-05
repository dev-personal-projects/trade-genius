import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class EnhancedInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isEnabled;
  final bool isTyping;

  const EnhancedInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.isEnabled = true,
    this.isTyping = false,
  });

  @override
  State<EnhancedInputBar> createState() => _EnhancedInputBarState();
}

class _EnhancedInputBarState extends State<EnhancedInputBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScale;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    if (!widget.isEnabled || widget.isTyping || !_hasText) return;
    HapticFeedback.lightImpact();
    _sendButtonController.forward().then((_) => _sendButtonController.reverse());
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _hasText
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              // Attachment button (future feature)
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.primary.withOpacity(0.6),
                ),
                onPressed: widget.isEnabled ? () {} : null,
                tooltip: 'Attach (Coming Soon)',
              ),
              
              // Text input
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.isEnabled && !widget.isTyping,
                  decoration: InputDecoration(
                    hintText: widget.isTyping
                        ? 'AI is thinking...'
                        : 'Ask about trading, crypto, DeFi...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                  maxLines: 4,
                  minLines: 1,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              AnimatedBuilder(
                animation: _sendButtonScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sendButtonScale.value,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.isTyping || !_hasText
                              ? [Colors.grey, Colors.grey.shade600]
                              : [AppColors.primary, AppColors.bullish],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: _hasText && !widget.isTyping
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: _handleSend,
                          child: Icon(
                            widget.isTyping
                                ? Icons.hourglass_empty
                                : _hasText
                                    ? Icons.send_rounded
                                    : Icons.mic_none,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
