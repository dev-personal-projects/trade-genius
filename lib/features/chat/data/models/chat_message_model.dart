import '../../domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sessionId,
    required super.role,
    required super.content,
    super.type,
    required super.timestamp,
    super.metadata,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      sessionId: json['session_id'],
      role: MessageRole.values.byName(json['role']),
      content: json['content'],
      type: MessageType.values.byName(json['type'] ?? 'text'),
      timestamp: DateTime.parse(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role.name,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      sessionId: entity.sessionId,
      role: entity.role,
      content: entity.content,
      type: entity.type,
      timestamp: entity.timestamp,
      metadata: entity.metadata,
    );
  }
}
