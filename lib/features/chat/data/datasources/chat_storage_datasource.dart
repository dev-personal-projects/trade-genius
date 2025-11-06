/*
 * CHAT STORAGE - Supabase Database Integration
 * 
 * PURPOSE: Save and retrieve chat messages from Supabase database
 * 
 * KEY CONCEPTS:
 * - Supabase: Backend-as-a-Service (like Firebase)
 * - PostgreSQL: SQL database used by Supabase
 * - CRUD: Create, Read, Update, Delete operations
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_message.dart';

class ChatStorageDataSource {
  // Get Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save message to database
  // Returns: true if successful, false if failed
  Future<bool> saveMessage(ChatMessage message) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      await _supabase.from('chat_messages').insert({
        'id': message.id,
        'session_id': message.sessionId,
        'role': message.role.name,
        'content': message.content,
        'timestamp': message.timestamp.toIso8601String(),
        'metadata': message.metadata,
        'user_id': userId,
      });
      return true;
    } catch (e) {
      print('Error saving message: $e');
      return false;
    }
  }

  // Get all messages for a specific session
  // Returns: List of ChatMessage objects
  Future<List<ChatMessage>> getSessionMessages(String sessionId) async {
    try {
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('session_id', sessionId)
          .order('timestamp', ascending: true);

      return (response as List).map((json) {
        return ChatMessage(
          id: json['id'],
          sessionId: json['session_id'],
          role: json['role'] == 'user' ? MessageRole.user : MessageRole.assistant,
          content: json['content'],
          timestamp: DateTime.parse(json['timestamp']),
          metadata: json['metadata'],
        );
      }).toList();
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  // Get all conversation sessions
  // Returns: List of session summaries with message count
  Future<List<Map<String, dynamic>>> getAllSessions() async {
    try {
      // SQL query to get sessions with message count and first message
      final response = await _supabase.rpc('get_chat_sessions');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  // Delete a conversation session and all its messages
  Future<bool> deleteSession(String sessionId) async {
    try {
      await _supabase
          .from('chat_messages')
          .delete()
          .eq('session_id', sessionId);
      return true;
    } catch (e) {
      print('Error deleting session: $e');
      return false;
    }
  }
}
