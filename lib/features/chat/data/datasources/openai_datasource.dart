// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/openai_request_model.dart';
import '../../domain/entities/ai_response.dart';
import '../../../../core/services/env_service.dart';


class OpenAIDataSource {
  final String _apiKey ;
  final String _baseUrl = 'https://api.openai.com/v1';

  OpenAIDataSource() : _apiKey = EnvService.openAIApiKey;

  Future<AIResponse> sendMessage(OpenAIRequest request) async {
    final stopwatch = Stopwatch()..start();

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    stopwatch.stop();

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final openAIResponse = OpenAIResponse.fromJson(data);

    return AIResponse(
      content: openAIResponse.content,
      tokensUsed: openAIResponse.tokensUsed,
      responseTime: stopwatch.elapsed,
    );
  }

  Stream<String> streamMessage(OpenAIRequest request) async* {
    final streamRequestData = OpenAIRequest(
      model: request.model,
      messages: request.messages,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
      stream: true,
    );

    final client = http.Client();
    try {
      final httpRequest = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );
      httpRequest.headers.addAll({
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      });
      httpRequest.body = jsonEncode(streamRequestData.toJson());

      final response = await client.send(httpRequest);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            try {
              final data = jsonDecode(line.substring(6));
              final content = data['choices'][0]['delta']['content'];
              if (content != null) yield content;
            } catch (_) {}
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
