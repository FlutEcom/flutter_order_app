import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/core/usecase/usecase.dart';
import 'package:flutter_order_app/features/order/domain/entities/order_analysis_result.dart';
import 'package:flutter_order_app/features/order/domain/entities/order_item.dart';
import 'package:flutter_order_app/features/order/domain/entities/parsed_order_item.dart';
import 'package:flutter_order_app/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart' as fuzzy;

class AnalyzeOrder implements UseCase<OrderAnalysisResult, AnalyzeOrderParams> {
  final OrderRepository repository;

  AnalyzeOrder(this.repository);

  @override
  Future<Either<Failure, OrderAnalysisResult>> call(
      AnalyzeOrderParams params) async {
    // 1. Wyślij tekst do AI
    final failureOrParsedItems = await repository.parseOrderText(params.orderText);

    return failureOrParsedItems.fold(
      (failure) => Left(failure),
      (parsedItems) {
        // 2. Logika dopasowania
        final result = _matchProducts(parsedItems, params.allProducts);
        return Right(result);
      },
    );
  }

 OrderAnalysisResult _matchProducts(
    List<ParsedOrderItem> parsedItems,
    List<Product> allProducts,
  ) {
    final List<OrderItem> resultItems = [];
    double totalSum = 0;

    for (final item in parsedItems) {
      Product? matchedProduct; // Domyślnie null

      if (allProducts.isNotEmpty) {
        try {
          // V-- TO JEST KLUCZOWA ZMIANA --V
          // Ta funkcja rzuca wyjątek, jeśli nie znajdzie dopasowania
          // powyżej progu 'cutoff'
          final bestMatch = fuzzy.extractOne(
            query: item.name,
            choices: allProducts.map((p) => p.title).toList(),
            cutoff: 60,
          );

          // Jeśli kod dotrze tutaj, to znaczy, że dopasowanie znaleziono
          matchedProduct = allProducts.firstWhere(
            (p) => p.title == bestMatch.choice,
          );
          // ^-- KONIEC BLOKU TRY --^

        } catch (e) {
          // Łapiemy błąd (np. 'Bad state: No element' z fuzzywuzzy)
          // Oznacza to brak dopasowania.
          // matchedProduct pozostaje null, co jest poprawne.
          // print('Nie znaleziono dopasowania dla "${item.name}": $e');
        }
      }

      // Ta logika pozostaje bez zmian
      if (matchedProduct != null) {
        // Znaleziono dopasowanie
        final itemSum = matchedProduct.price * item.quantity;
        totalSum += itemSum;

        resultItems.add(OrderItem(
          productName: matchedProduct.title,
          quantity: item.quantity,
          unitPrice: matchedProduct.price,
          itemSum: itemSum,
          isMatched: true,
        ));
      } else {
        // Nie znaleziono dopasowania (lub lista była pusta)
        resultItems.add(OrderItem(
          productName: item.name, // Oryginalna nazwa z AI
          quantity: item.quantity,
          isMatched: false,
        ));
      }
    }

    return OrderAnalysisResult(items: resultItems, totalSum: totalSum);
  }
}

class AnalyzeOrderParams extends Equatable {
  final String orderText;
  final List<Product> allProducts;

  const AnalyzeOrderParams({required this.orderText, required this.allProducts});

  @override
  List<Object?> get props => [orderText, allProducts];
}