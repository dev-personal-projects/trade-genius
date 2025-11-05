class AzureMessage {
  final String role;
  final String content;

  const AzureMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AzureRequest {
  final List<AzureMessage> messages;
  final double temperature;
  final int maxTokens;
  final bool stream;

  const AzureRequest({
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.stream = false,
  });

  Map<String, dynamic> toJson() => {
    'messages': messages.map((m) => m.toJson()).toList(),
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': stream,
  };
}
