// main.dart
// Why: Keep entrypoint minimal. Delegates all setup to App(). No business/UI logic here.

import 'package:flutter/material.dart';
import 'app.dart';



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}