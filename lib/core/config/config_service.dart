import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_order_app/core/config/app_config.dart';
import 'package:flutter_order_app/core/error/exceptions.dart';

class ConfigService {
  late AppConfig _config;
  AppConfig get config => _config;

  Future<void> loadConfig() async {
    try {
      final configString = await rootBundle.loadString('assets/config/app_config.json');
      final json = jsonDecode(configString);
      _config = AppConfig.fromJson(json);

      if (_config.aiApiKey.isEmpty || _config.aiApiKey == "YOUR_AI_API_KEY_HERE") {
        throw ConfigException(
            'Klucz AI jest pusty lub nie został ustawiony. '
            'Sprawdź plik assets/config/app_config.json.');
      }
    } catch (e) {
      // Zapewniamy, że _config istnieje, nawet jeśli ładowanie się nie powiodło
      _config = const AppConfig(aiApiKey: '');
      
      if (e is ConfigException) rethrow;
      
      // Obsługa błędu braku pliku
      throw ConfigException(
          'Nie można wczytać pliku konfiguracyjnego app_config.json. '
          'Upewnij się, że plik istnieje w assets/config/');
    }
  }
}