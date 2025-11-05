class AIResponse {
  final String content;
  final int tokensUsed;
  final Duration responseTime;
  final List<String> functionCalls;
  final Map<String, dynamic>? marketData;

  const AIResponse({
    required this.content,
    required this.tokensUsed,
    required this.responseTime,
    this.functionCalls = const [],
    this.marketData,
  });

  bool get hasFunctionCalls => functionCalls.isNotEmpty;
  bool get hasMarketData => marketData != null;
}
