import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_order_app/core/config/app_config.dart';
import 'package:flutter_order_app/core/error/exceptions.dart';
import 'package:flutter_order_app/features/order/data/models/parsed_order_item_model.dart';

abstract class OrderAIDataSource {
  Future<List<ParsedOrderItemModel>> parseOrderText(String orderText);
}

class OrderAIDataSourceImpl implements OrderAIDataSource {
  final Dio dio;
  final AppConfig config;

  // TODO: Zastąp ten URL właściwym endpointem dostawcy AI (np. OpenAI, Gemini)
  final String _aiApiUrl = "https://api.openai.com/v1/chat/completions";

  OrderAIDataSourceImpl({required this.dio, required this.config});

  @override
  Future<List<ParsedOrderItemModel>> parseOrderText(String orderText) async {
    if (config.aiApiKey.isEmpty) {
      throw ConfigException(
          'Klucz API dla AI jest nieustawiony. Sprawdź plik konfiguracyjny.');
    }

    // --- POCZĄTEK MOCKOWANIA (do usunięcia w produkcji) ---
    // Zwracamy przykładowe dane, aby aplikacja działała bez klucza AI
    // Usuń ten blok, aby włączyć prawdziwe wywołanie API
    if (config.aiApiKey.startsWith("sk-fake")) {
       await Future.delayed(const Duration(seconds: 1));
       if (orderText.contains("iPhone 9")) {
         return [
           const ParsedOrderItemModel(name: "iPhone 9", quantity: 2),
           const ParsedOrderItemModel(name: "Samsung Universe 9", quantity: 1),
           const ParsedOrderItemModel(name: "Apple AirPods", quantity: 3),
         ];
       } else {
         return [
           const ParsedOrderItemModel(name: "iPhone X", quantity: 1),
           const ParsedOrderItemModel(name: "Laptop", quantity: 5), // Niezgodny
         ];
       }
    }
    // --- KONIEC MOCKOWANIA ---


    // TODO: Zastąp ten prompt i body właściwym dla Twojego modelu AI
    final prompt = """
    Przeanalizuj poniższy tekst zamówienia i zwróć listę produktów w formacie JSON.
    Każdy obiekt na liście powinien zawierać klucz "name" (string) oraz "quantity" (int).
    Zwróć TYLKO i WYŁĄCZNIE tablicę JSON, bez żadnego dodatkowego tekstu.

    Przykład: "Poproszę 2x iPhone 9 i 1x Samsung."
    Wynik: [{"name": "iPhone 9", "quantity": 2}, {"name": "Samsung", "quantity": 1}]
    
    Tekst do analizy:
    "$orderText"
    """;

    try {
      final response = await dio.post(
        _aiApiUrl,
        data: {
          // Przykładowe body dla OpenAI GPT-3.5/4
          "model": "gpt-3.5-turbo",
          "messages": [
            {"role": "system", "content": "Jesteś asystentem do parsowania zamówień."},
            {"role": "user", "content": prompt}
          ],
          // Upewnij się, że model zwróci JSON
          // "response_format": { "type": "json_object" }, // dla gpt-4-turbo
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.aiApiKey}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // TODO: Dostosuj parsowanie odpowiedzi do struktury zwracanej przez Twoje AI
        // Poniżej przykład dla OpenAI
        final content = response.data['choices'][0]['message']['content'];
        
        // AI może zwrócić JSON otoczony dodatkowym tekstem lub markdown
        final jsonString = _extractJson(content); 

        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => ParsedOrderItemModel.fromJson(json)).toList();
      } else {
        throw AIException('Błąd AI: ${response.statusCode} ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AIException('Błąd autoryzacji AI: Niepoprawny klucz API.');
      }
      throw AIException('Błąd sieci podczas łączenia z AI: ${e.message}');
    } catch (e) {
      throw AIException('Błąd parsowania odpowiedzi AI: ${e.toString()}');
    }
  }

  // Funkcja pomocnicza do wyciągania JSONa z odpowiedzi AI
  String _extractJson(String rawResponse) {
    final startIndex = rawResponse.indexOf('[');
    final endIndex = rawResponse.lastIndexOf(']');
    if (startIndex != -1 && endIndex != -1) {
      return rawResponse.substring(startIndex, endIndex + 1);
    }
    // Spróbuj dla pojedynczego obiektu (chociaż prosimy o listę)
    final startObj = rawResponse.indexOf('{');
    final endObj = rawResponse.lastIndexOf('}');
     if (startObj != -1 && endObj != -1) {
      return rawResponse.substring(startObj, endObj + 1);
    }
    throw Exception("Nie znaleziono JSON w odpowiedzi AI.");
  }
}