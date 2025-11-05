import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../entities/ai_response.dart';

abstract class ChatRepository {
  // Session management
  Future<ChatSession> createSession(String userId);
  Future<List<ChatSession>> getUserSessions(String userId);
  Future<void> deleteSession(String sessionId);

  // Message operations
  Future<void> saveMessage(ChatMessage message);
  Future<List<ChatMessage>> getSessionMessages(String sessionId);
  Stream<List<ChatMessage>> watchSessionMessages(String sessionId);

  // AI integration
  Future<AIResponse> sendToAI(String message, List<ChatMessage> context);
  Stream<String> streamAIResponse(String message, List<ChatMessage> context);
}
