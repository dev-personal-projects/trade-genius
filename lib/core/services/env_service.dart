import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  static String get openAIApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIModel =>
      dotenv.env['OPENAI_MODEL'] ?? 'gpt-4-turbo-preview';
  static int get openAIMaxTokens =>
      int.parse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '4096');

  // Azure AI Foundry Configuration
  static String get azureEndpoint => dotenv.env['AZURE_OPENAI_ENDPOINT'] ?? '';
  static String get azureApiKey => dotenv.env['AZURE_OPENAI_API_KEY'] ?? '';
  static String get azureDeployment =>
      dotenv.env['AZURE_OPENAI_DEPLOYMENT_NAME'] ?? 'gpt-4.1-mini';
  static String get azureApiVersion =>
      dotenv.env['AZURE_OPENAI_API_VERSION'] ?? '2024-02-15-preview';
  static int get azureMaxTokens =>
      int.parse(dotenv.env['AZURE_MAX_TOKENS'] ?? '4096');
}
