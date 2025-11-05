import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message_model.dart';
import '../../domain/entities/chat_session.dart';

class ChatStorageDataSource {
  final SupabaseClient _client;

  ChatStorageDataSource(this._client);

  Future<ChatSession> createSession(String userId) async {
    final session = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'title': 'New Chat',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'message_count': 0,
    };

    await _client.from('chat_sessions').insert(session);

    return ChatSession(
      id: session['id'] as String,
      userId: session['user_id'] as String,
      title: session['title'] as String,
      createdAt: DateTime.parse(session['created_at'] as String),
      updatedAt: DateTime.parse(session['updated_at'] as String),
      messageCount: session['message_count'] as int,
    );
  }

  Future<List<ChatSession>> getUserSessions(String userId) async {
    final response = await _client
        .from('chat_sessions')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);

    return response
        .map<ChatSession>(
          (json) => ChatSession(
            id: json['id'] as String,
            userId: json['user_id'] as String,
            title: json['title'] as String,
            createdAt: DateTime.parse(json['created_at'] as String),
            updatedAt: DateTime.parse(json['updated_at'] as String),
            messageCount: (json['message_count'] as int?) ?? 0,
          ),
        )
        .toList();
  }

  Future<void> saveMessage(ChatMessageModel message) async {
    await _client.from('chat_messages').insert(message.toJson());

    // Update session
    await _client
        .from('chat_sessions')
        .update({
          'updated_at': DateTime.now().toIso8601String(),
          'message_count': await _getMessageCount(message.sessionId),
        })
        .eq('id', message.sessionId);
  }

  Future<List<ChatMessageModel>> getSessionMessages(String sessionId) async {
    final response = await _client
        .from('chat_messages')
        .select()
        .eq('session_id', sessionId)
        .order('timestamp', ascending: true);

    return response
        .map<ChatMessageModel>((json) => ChatMessageModel.fromJson(json))
        .toList();
  }

  Stream<List<ChatMessageModel>> watchSessionMessages(String sessionId) {
    return _client
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('timestamp')
        .map(
          (data) => data
              .map<ChatMessageModel>((json) => ChatMessageModel.fromJson(json))
              .toList(),
        );
  }

  Future<void> deleteSession(String sessionId) async {
    await _client.from('chat_messages').delete().eq('session_id', sessionId);
    await _client.from('chat_sessions').delete().eq('id', sessionId);
  }

  Future<int> _getMessageCount(String sessionId) async {
    final response = await _client
        .from('chat_messages')
        .select('id')
        .eq('session_id', sessionId);
    return response.length;
  }
}
