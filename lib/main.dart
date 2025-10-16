import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase before running the app
  await SupabaseService.initialize();
  
  runApp(const App());
}
