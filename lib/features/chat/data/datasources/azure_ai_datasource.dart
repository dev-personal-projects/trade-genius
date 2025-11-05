/*
 * AZURE AI FOUNDRY INTEGRATION
 * 
 * CONCEPTS:
 * - Azure OpenAI Service for enterprise-grade AI
 * - Custom deployment names for model versions
 * - Enhanced system prompts for financial education
 * - Function calling for real-time data integration
 */

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/azure_request_model.dart';
import '../../domain/entities/ai_response.dart';

class AzureAIDataSource {
  final String _endpoint;
  final String _apiKey;
  final String _deploymentName;
  final String _apiVersion;

  AzureAIDataSource({
    required String endpoint,
    required String apiKey,
    required String deploymentName,
    required String apiVersion,
  }) : _endpoint = endpoint,
       _apiKey = apiKey,
       _deploymentName = deploymentName,
       _apiVersion = apiVersion;

  Future<AIResponse> sendMessage(AzureRequest request) async {
    final stopwatch = Stopwatch()..start();

    final url =
        '$_endpoint/openai/deployments/$_deploymentName/chat/completions?api-version=$_apiVersion';

    final response = await http.post(
      Uri.parse(url),
      headers: {'api-key': _apiKey, 'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    stopwatch.stop();

    if (response.statusCode != 200) {
      throw Exception('Azure AI error: ${response.body}');
    }

    final data = jsonDecode(response.body);

    return AIResponse(
      content: data['choices'][0]['message']['content'],
      tokensUsed: data['usage']['total_tokens'],
      responseTime: stopwatch.elapsed,
      functionCalls: _extractFunctionCalls(data),
    );
  }

  Stream<String> streamMessage(AzureRequest request) async* {
    final streamRequest = AzureRequest(
      messages: request.messages,
      temperature: request.temperature,
      maxTokens: request.maxTokens,
      stream: true,
    );

    final url =
        '$_endpoint/openai/deployments/$_deploymentName/chat/completions?api-version=$_apiVersion';

    final client = http.Client();
    try {
      final httpRequest = http.Request('POST', Uri.parse(url));
      httpRequest.headers.addAll({
        'api-key': _apiKey,
        'Content-Type': 'application/json',
      });
      httpRequest.body = jsonEncode(streamRequest.toJson());

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

  List<String> _extractFunctionCalls(Map<String, dynamic> data) {
    // Extract function calls if present
    return [];
  }
}
