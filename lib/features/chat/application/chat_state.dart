/*
 * FLUTTER CONCEPTS USED:
 * 
 * 1. IMMUTABLE STATE PATTERN
 *    - All state properties are final (immutable)
 *    - State changes create new instances via copyWith()
 *    - Prevents accidental mutations and bugs
 *    - Used with: ValueNotifier, Riverpod, BLoC
 * 
 * 2. COPYSWITH PATTERN
 *    - Creates new state instances with selective updates
 *    - Maintains immutability while allowing changes
 *    - Essential for state management libraries
 * 
 * 3. ENUM FOR TYPE SAFETY
 *    - ChatStatus enum prevents invalid states
 *    - Compile-time safety vs string comparisons
 *    - Better IDE support and refactoring
 * 
 * 4. NULLABLE TYPES
 *    - String? for optional error messages
 *    - Dart null safety prevents runtime errors
 * 
 * HOW TO USE:
 * - With ValueNotifier: ValueNotifier<ChatState>(ChatState.initial())
 * - With Riverpod: StateNotifier<ChatState>
 * - With BLoC: Cubit<ChatState> or Bloc<Event, ChatState>
 */

import '../domain/entities/chat_message.dart';
import '../domain/entities/chat_session.dart';

enum ChatStatus { initial, loading, success, error, streaming }

class ChatState {
  final ChatStatus status;
  final List<ChatMessage> messages;
  final ChatSession? currentSession;
  final String? error;
  final bool isAITyping;
  final String streamingContent;

  const ChatState({
    required this.status,
    required this.messages,
    this.currentSession,
    this.error,
    this.isAITyping = false,
    this.streamingContent = '',
  });

  factory ChatState.initial() {
    return const ChatState(status: ChatStatus.initial, messages: []);
  }

  ChatState copyWith({
    ChatStatus? status,
    List<ChatMessage>? messages,
    ChatSession? currentSession,
    String? error,
    bool? isAITyping,
    String? streamingContent,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      currentSession: currentSession ?? this.currentSession,
      error: error ?? this.error,
      isAITyping: isAITyping ?? this.isAITyping,
      streamingContent: streamingContent ?? this.streamingContent,
    );
  }

  // Computed properties for UI
  bool get hasMessages => messages.isNotEmpty;
  bool get hasError => error != null;
  bool get isLoading => status == ChatStatus.loading;
  bool get isStreaming => status == ChatStatus.streaming;
}
