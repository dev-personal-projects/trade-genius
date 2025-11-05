// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/env_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/datasources/azure_ai_datasource.dart';
import '../../data/models/azure_request_model.dart';
import '../widgets/premium_message_bubble.dart';
import '../widgets/streaming_bubble.dart';
import '../widgets/particle_background.dart';
import '../widgets/quick_action_chips.dart';
import '../widgets/market_context_card.dart';
import '../widgets/enhanced_input_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  late AzureAIDataSource _azureAI;
  bool _isTyping = false;
  String _streamingContent = '';

  late AnimationController _backgroundController;

  final List<Particle> _particles = [];
  Timer? _particleTimer;

  @override
  void initState() {
    super.initState();

    _azureAI = AzureAIDataSource(
      endpoint: EnvService.azureEndpoint,
      apiKey: EnvService.azureApiKey,
      deploymentName: EnvService.azureDeployment,
      apiVersion: EnvService.azureApiVersion,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _initializeParticles();
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() => _updateParticles());
    });

    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _backgroundController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _initializeParticles() {
    for (int i = 0; i < 20; i++) {
      _particles.add(Particle());
    }
  }

  void _updateParticles() {
    for (final particle in _particles) {
      particle.update();
    }
  }

  void _addWelcomeMessage() {
    _addMessage(
      "👋 **Welcome to TradeGenius AI!**\n\n"
      "I'm your AI trading mentor powered by Azure AI Foundry. Ask me about crypto markets, trading strategies, technical analysis, or tap a quick action below to get started.\n\n"
      "⚠️ *Educational content only - Not financial advice*",
      false,
    );
  }

  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          sessionId: 'default',
          role: isUser ? MessageRole.user : MessageRole.assistant,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    HapticFeedback.lightImpact();

    _addMessage(text, true);
    _textController.clear();

    setState(() {
      _isTyping = true;
      _streamingContent = '';
    });

    try {
      final messages = _buildAzureMessages(text);
      final request = AzureRequest(messages: messages, stream: true);

      await for (final token in _azureAI.streamMessage(request)) {
        setState(() => _streamingContent += token);
        _scrollToBottom();
      }

      if (_streamingContent.isNotEmpty) {
        _addMessage(_streamingContent, false);
      }
    } catch (e) {
      _addMessage(
        "⚠️ **Connection Error**\n\nUnable to reach Azure AI Foundry.\n\n"
        "Please verify:\n"
        "• Azure endpoint is correct\n"
        "• API key is valid\n"
        "• Internet connection is stable\n\n"
        "Error: ${e.toString()}",
        false,
      );
    } finally {
      setState(() {
        _isTyping = false;
        _streamingContent = '';
      });
    }
  }

  List<AzureMessage> _buildAzureMessages(String userMessage) {
    final messages = <AzureMessage>[
      const AzureMessage(
        role: 'system',
        content:
            '''You are TradeGenius AI, an elite cryptocurrency trading mentor and market analyst.

🎯 CORE IDENTITY:
- Expert in crypto markets, DeFi, technical analysis, and trading psychology
- Powered by Azure AI Foundry for institutional-grade insights
- Educational focus with practical, actionable guidance

📊 EXPERTISE AREAS:
1. Technical Analysis: Chart patterns, indicators (RSI, MACD, Bollinger Bands), support/resistance
2. Fundamental Analysis: Tokenomics, project evaluation, market sentiment
3. Trading Strategies: Scalping, swing trading, position trading, DCA strategies
4. Risk Management: Position sizing, stop-loss placement, portfolio diversification
5. DeFi Protocols: Yield farming, liquidity pools, staking, lending platforms
6. Market Psychology: FOMO, FUD, crowd behavior, emotional discipline

💡 COMMUNICATION STYLE:
- Use emojis strategically for visual clarity (📈📉💎🚀⚠️)
- Structure responses with clear sections using markdown
- Provide specific, actionable insights over generic advice
- Include relevant examples and scenarios
- Balance optimism with realistic risk awareness
- Use bullet points and numbered lists for clarity

⚠️ CRITICAL RULES:
- Always emphasize: "This is educational content, not financial advice"
- Encourage users to DYOR (Do Your Own Research)
- Warn about risks before discussing opportunities
- Never guarantee profits or predict exact prices
- Promote responsible trading and risk management

🎨 RESPONSE FORMAT:
Use markdown formatting:
- **Bold** for emphasis
- *Italic* for subtle points
- Bullet points for lists
- Clear section headers
- Line breaks for readability

Be conversational yet professional, insightful yet humble, educational yet engaging.''',
      ),
    ];

    final recentMessages = _messages.take(6).toList();
    for (final msg in recentMessages.reversed) {
      messages.add(
        AzureMessage(
          role: msg.isUser ? 'user' : 'assistant',
          content: msg.content,
        ),
      );
    }

    messages.add(AzureMessage(role: 'user', content: userMessage));
    return messages;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              AppColors.primary.withOpacity(0.05),
              AppColors.bullish.withOpacity(0.03),
            ],
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: ParticlePainter(_particles, _backgroundController.value),
              size: size,
            ),

            Column(
              children: [
                _buildAppBar(theme),
                _buildMessageList(),
                _buildInputArea(theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.bullish],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'TradeGenius AI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isTyping ? 'Thinking...' : 'Azure AI',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.bullish,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isTyping && index == 0) {
            return StreamingBubble(content: _streamingContent);
          }
          
          final messageIndex = _isTyping ? index - 1 : index;
          
          if (messageIndex == _messages.length - 1 && _messages.length == 1) {
            return Column(
              children: [
                PremiumMessageBubble(message: _messages[messageIndex]),
                const SizedBox(height: 12),
                QuickActionChips(
                  onActionTap: (prompt) {
                    _textController.text = prompt;
                    _sendMessage();
                  },
                  isEnabled: !_isTyping,
                ),
                const SizedBox(height: 12),
                const MarketContextCard(
                  btcPrice: '\$43.2K',
                  ethPrice: '\$2.3K',
                  marketSentiment: 'Bullish',
                ),
              ],
            );
          }
          
          return PremiumMessageBubble(message: _messages[messageIndex]);
        },
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !_isTyping,
                decoration: InputDecoration(
                  hintText: _isTyping ? 'AI thinking...' : 'Ask anything...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => _sendMessage(),
                maxLines: 3,
                minLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isTyping ? null : _sendMessage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isTyping
                        ? [Colors.grey, Colors.grey]
                        : [AppColors.primary, AppColors.bullish],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _isTyping ? Icons.hourglass_empty : Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
