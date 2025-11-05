/*
 * FLUTTER CONCEPTS USED:
 * 
 * 1. TEXTFIELD CUSTOMIZATION
 *    - Custom decoration and styling
 *    - Focus management and keyboard handling
 *    - Input validation and formatting
 * 
 * 2. ANIMATED ICONS
 *    - Morphing between send/mic icons
 *    - AnimatedSwitcher for smooth transitions
 *    - Icon state based on text input
 * 
 * 3. KEYBOARD HANDLING
 *    - TextInputAction for better UX
 *    - onSubmitted for enter key handling
 *    - Focus management between widgets
 */

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onVoicePressed;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onVoicePressed,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = widget.controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: 'Ask about trading, crypto, or markets...',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                maxLines: 4,
                minLines: 1,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send/Voice button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _hasText ? _buildSendButton() : _buildVoiceButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return FloatingActionButton.small(
      key: const ValueKey('send'),
      onPressed: _handleSend,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.send, color: Colors.white),
    );
  }

  Widget _buildVoiceButton() {
    return FloatingActionButton.small(
      key: const ValueKey('voice'),
      onPressed: widget.onVoicePressed,
      backgroundColor: AppColors.bullish,
      child: const Icon(Icons.mic, color: Colors.white),
    );
  }
}
