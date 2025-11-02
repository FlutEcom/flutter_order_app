import 'package:flutter/material.dart';
import 'package:flutter_order_app/core/di/injector.dart' as di;
import 'package:flutter_order_app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicjalizacja Dependency Injection
  await di.init();
  
  runApp(const MyApp());
}