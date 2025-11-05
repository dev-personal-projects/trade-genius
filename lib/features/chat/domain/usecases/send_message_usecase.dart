import '../entities/chat_message.dart';
// ignore: unused_import
import '../entities/ai_response.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository _repository;

  SendMessageUseCase(this._repository);

  Future<ChatMessage> execute({
    required String sessionId,
    required String content,
    required String userId,
  }) async {
    // Create user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    // Save user message
    await _repository.saveMessage(userMessage);

    // Get conversation context
    final context = await _repository.getSessionMessages(sessionId);

    // Get AI response
    final aiResponse = await _repository.sendToAI(content, context);

    // Create AI message
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: MessageRole.assistant,
      content: aiResponse.content,
      timestamp: DateTime.now(),
      metadata: {
        'tokensUsed': aiResponse.tokensUsed,
        'responseTime': aiResponse.responseTime.inMilliseconds,
        'functionCalls': aiResponse.functionCalls,
        if (aiResponse.hasMarketData) 'marketData': aiResponse.marketData,
      },
    );

    // Save AI message
    await _repository.saveMessage(aiMessage);

    return aiMessage;
  }

  Stream<String> executeStream({
    required String sessionId,
    required String content,
    required String userId,
  }) async* {
    // Create and save user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sessionId: sessionId,
      role: MessageRole.user,
      content: content,
      timestamp: DateTime.now(),
    );

    await _repository.saveMessage(userMessage);

    // Get context and stream AI response
    final context = await _repository.getSessionMessages(sessionId);

    await for (final token in _repository.streamAIResponse(content, context)) {
      yield token;
    }
  }
}
