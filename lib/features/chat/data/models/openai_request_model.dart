class OpenAIMessage {
  final String role;
  final String content;

  const OpenAIMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> messages;
  final double temperature;
  final int maxTokens;
  final bool stream;

  const OpenAIRequest({
    this.model = 'gpt-4-turbo-preview',
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 4096,
    this.stream = false,
  });

  Map<String, dynamic> toJson() => {
    'model': model,
    'messages': messages.map((m) => m.toJson()).toList(),
    'temperature': temperature,
    'max_tokens': maxTokens,
    'stream': stream,
  };
}

class OpenAIResponse {
  final String content;
  final int tokensUsed;

  const OpenAIResponse({required this.content, required this.tokensUsed});

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponse(
      content: json['choices'][0]['message']['content'],
      tokensUsed: json['usage']['total_tokens'],
    );
  }
}
