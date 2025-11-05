import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/env_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //load environment variables
  await EnvService.load();
  
  // Initialize Supabase before running the app
  await SupabaseService.initialize();
  
  runApp(const App());
}
