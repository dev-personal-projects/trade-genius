import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/chat_message.dart';

class PremiumMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const PremiumMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    
    return Container(
      margin: EdgeInsets.only(
        left: isUser ? 64 : 0,
        right: isUser ? 0 : 64,
        bottom: 16,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: isUser
                ? LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  )
                : LinearGradient(
                    colors: [
                      theme.colorScheme.surface.withOpacity(0.9),
                      theme.colorScheme.surface.withOpacity(0.7),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: isUser ? const Radius.circular(4) : null,
              bottomLeft: !isUser ? const Radius.circular(4) : null,
            ),
            border: Border.all(
              color: isUser 
                  ? Colors.transparent 
                  : theme.colorScheme.outline.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: (isUser ? AppColors.primary : Colors.black).withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormattedText(
                message.content,
                theme,
                isUser,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: (isUser ? Colors.white : theme.colorScheme.onSurface)
                          .withOpacity(0.6),
                    ),
                  ),
                  if (!isUser)
                    GestureDetector(
                      onTap: () => _copyToClipboard(context, message.content),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormattedText(String content, ThemeData theme, bool isUser) {
    final baseColor = isUser ? Colors.white : theme.colorScheme.onSurface;
    final spans = <InlineSpan>[];
    final lines = content.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Bold text **text**
      if (line.contains('**')) {
        final parts = line.split('**');
        for (int j = 0; j < parts.length; j++) {
          spans.add(TextSpan(
            text: parts[j],
            style: j.isOdd
                ? TextStyle(fontWeight: FontWeight.bold, color: baseColor)
                : TextStyle(color: baseColor),
          ));
        }
      }
      // Bullet points
      else if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(color: baseColor, height: 1.6),
        ));
      }
      // Regular text
      else {
        spans.add(TextSpan(
          text: line,
          style: TextStyle(color: baseColor),
        ));
      }
      
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    
    return RichText(
      text: TextSpan(
        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
        children: spans,
      ),
    );
  }
  
  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.bullish,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    
    return '${timestamp.day}/${timestamp.month}';
  }
}
