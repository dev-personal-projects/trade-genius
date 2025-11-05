/*
 * FLUTTER CONCEPTS USED:
 * 
 * 1. VALUENOTIFIER PATTERN
 *    - Lightweight state management solution
 *    - Notifies listeners when value changes
 *    - Perfect for simple state without complex logic
 *    - Alternative to: Provider, Riverpod, BLoC
 * 
 * 2. STREAM SUBSCRIPTION
 *    - Listen to real-time AI responses
 *    - Handle async data streams (WebSocket-like)
 *    - Proper cleanup in dispose() prevents memory leaks
 * 
 * 3. ASYNC/AWAIT PATTERN
 *    - Handle asynchronous operations cleanly
 *    - Better than .then() chains for readability
 *    - Error handling with try-catch blocks
 * 
 * 4. DEPENDENCY INJECTION
 *    - Constructor injection of use cases
 *    - Testable and modular architecture
 *    - Follows SOLID principles
 * 
 * 5. DISPOSE PATTERN
 *    - Clean up resources when controller destroyed
 *    - Cancel subscriptions, close streams
 *    - Prevents memory leaks in Flutter apps
 * 
 * HOW TO USE IN UI:
 * - ValueListenableBuilder<ChatState>(
 *     valueListenable: chatController,
 *     builder: (context, state, child) => Widget()
 *   )
 * - Or with Provider: ChangeNotifierProvider
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/usecases/send_message_usecase.dart';
import '../domain/repositories/chat_repository.dart';
import '../domain/entities/chat_message.dart';
import 'chat_state.dart';

class ChatController extends ValueNotifier<ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final ChatRepository _repository;

  StreamSubscription<String>? _streamSubscription;

  ChatController(this._sendMessageUseCase, this._repository)
    : super(ChatState.initial());

  // Initialize chat session
  Future<void> initializeChat(String userId) async {
    try {
      value = value.copyWith(status: ChatStatus.loading);

      final session = await _repository.createSession(userId);
      final messages = await _repository.getSessionMessages(session.id);

      value = value.copyWith(
        status: ChatStatus.success,
        currentSession: session,
        messages: messages,
      );
    } catch (e) {
      value = value.copyWith(status: ChatStatus.error, error: e.toString());
    }
  }

  // Send message with streaming response
  Future<void> sendMessage(String content, String userId) async {
    if (value.currentSession == null) return;

    try {
      // Add user message immediately
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: value.currentSession!.id,
        role: MessageRole.user,
        content: content,
        timestamp: DateTime.now(),
      );

      value = value.copyWith(
        messages: [...value.messages, userMessage],
        status: ChatStatus.streaming,
        isAITyping: true,
        streamingContent: '',
      );

      // Stream AI response
      _streamSubscription = _sendMessageUseCase
          .executeStream(
            sessionId: value.currentSession!.id,
            content: content,
            userId: userId,
          )
          .listen(
            (token) {
              // Update streaming content
              value = value.copyWith(
                streamingContent: value.streamingContent + token,
              );
            },
            onDone: () {
              // Create final AI message
              final aiMessage = ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                sessionId: value.currentSession!.id,
                role: MessageRole.assistant,
                content: value.streamingContent,
                timestamp: DateTime.now(),
              );

              value = value.copyWith(
                messages: [...value.messages, aiMessage],
                status: ChatStatus.success,
                isAITyping: false,
                streamingContent: '',
              );
            },
            onError: (error) {
              value = value.copyWith(
                status: ChatStatus.error,
                error: error.toString(),
                isAITyping: false,
                streamingContent: '',
              );
            },
          );
    } catch (e) {
      value = value.copyWith(
        status: ChatStatus.error,
        error: e.toString(),
        isAITyping: false,
      );
    }
  }

  // Load chat history
  Future<void> loadSession(String sessionId) async {
    try {
      value = value.copyWith(status: ChatStatus.loading);

      final messages = await _repository.getSessionMessages(sessionId);

      value = value.copyWith(status: ChatStatus.success, messages: messages);
    } catch (e) {
      value = value.copyWith(status: ChatStatus.error, error: e.toString());
    }
  }

  // Clear error state
  void clearError() {
    value = value.copyWith(error: null);
  }

  // Stop streaming
  void stopStreaming() {
    _streamSubscription?.cancel();
    value = value.copyWith(
      status: ChatStatus.success,
      isAITyping: false,
      streamingContent: '',
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
