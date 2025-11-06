import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/azure_ai_datasource.dart';
import '../datasources/chat_storage_datasource.dart';
import '../models/chat_message_model.dart';
import '../models/azure_request_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final AzureAIDataSource _azureAIDataSource;
  final ChatStorageDataSource _storageDataSource;

  ChatRepositoryImpl(this._azureAIDataSource, this._storageDataSource);

  @override
  Future<ChatSession> createSession(String userId) async {
    // Create new session with timestamp as ID
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    return ChatSession(
      id: sessionId,
      userId: userId,
      title: 'New Conversation',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<ChatSession>> getUserSessions(String userId) async {
    final sessions = await _storageDataSource.getAllSessions();
    return sessions
        .map(
          (json) => ChatSession(
            id: json['session_id'],
            userId: userId,
            title: json['first_message'] ?? 'Conversation',
            createdAt: DateTime.now(),
            updatedAt: DateTime.parse(json['last_timestamp']),
            messageCount: json['message_count'] ?? 0,
          ),
        )
        .toList();
  }

  @override
  Future<void> deleteSession(String sessionId) {
    return _storageDataSource.deleteSession(sessionId);
  }

  @override
  Future<void> saveMessage(ChatMessage message) {
    final model = ChatMessageModel.fromEntity(message);
    return _storageDataSource.saveMessage(model);
  }

  @override
  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    final models = await _storageDataSource.getSessionMessages(sessionId);
    return models.cast<ChatMessage>();
  }

  @override
  Stream<List<ChatMessage>> watchSessionMessages(String sessionId) async* {
    // Convert Future to Stream for real-time updates
    final messages = await _storageDataSource.getSessionMessages(sessionId);
    yield messages;
  }

  @override
  Future<AIResponse> sendToAI(String message, List<ChatMessage> context) {
    final messages = _buildAzureMessages(message, context);
    final request = AzureRequest(messages: messages);
    return _azureAIDataSource.sendMessage(request);
  }

  @override
  Stream<String> streamAIResponse(String message, List<ChatMessage> context) {
    final messages = _buildAzureMessages(message, context);
    final request = AzureRequest(messages: messages);
    return _azureAIDataSource.streamMessage(request);
  }

  List<AzureMessage> _buildAzureMessages(
    String message,
    List<ChatMessage> context,
  ) {
    final messages = <AzureMessage>[
      const AzureMessage(role: 'system', content: _systemPrompt),
    ];

    // Add recent context (last 10 messages)
    final recentContext = context.take(10).toList();
    for (final msg in recentContext) {
      messages.add(AzureMessage(role: msg.role.name, content: msg.content));
    }

    // Add current message
    messages.add(AzureMessage(role: 'user', content: message));

    return messages;
  }

  static const String _systemPrompt = '''
You are TradeGenius AI, the world's most comprehensive financial education mentor and advisor.

🎯 CORE EXPERTISE:
• Cryptocurrency & Blockchain Technology
• Stock Market & Trading Strategies  
• Investment Planning & Portfolio Management
• Personal Finance & Budgeting
• Government Financial Policies & Regulations
• Business Finance & Entrepreneurship
• Savings & Retirement Planning
• Economic Analysis & Market Psychology

🎓 TEACHING METHODOLOGY:
1. ADAPTIVE LEARNING: Adjust complexity based on user's knowledge level
2. PRACTICAL APPLICATION: Provide real-world examples and case studies
3. RISK AWARENESS: Always emphasize risk management and responsible investing
4. CURRENT CONTEXT: Reference latest market conditions and news
5. INTERACTIVE LEARNING: Ask questions to ensure understanding

🎯 RESPONSE GUIDELINES:
- Start with user's current knowledge level
- Provide step-by-step explanations
- Use analogies and real-world examples
- Include current market data when relevant
- Always mention risks and disclaimers
- Encourage further questions and exploration
- Provide actionable next steps

⚠️ IMPORTANT DISCLAIMERS:
- This is educational content, not financial advice
- Always do your own research (DYOR)
- Past performance doesn't guarantee future results
- Consider consulting licensed financial advisors
- Understand risks before making any investments

🚀 ENGAGEMENT STYLE:
- Enthusiastic but professional
- Encouraging and supportive
- Clear and jargon-free explanations
- Interactive with follow-up questions
- Motivational for financial literacy journey

Remember: Your goal is to empower users with knowledge to make informed financial decisions while emphasizing the importance of continuous learning and risk management.
''';
}
