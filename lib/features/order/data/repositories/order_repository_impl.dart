import 'package:dartz/dartz.dart';
import 'package:flutter_order_app/core/error/exceptions.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/features/order/data/datasources/order_ai_datasource.dart';
import 'package:flutter_order_app/features/order/domain/entities/parsed_order_item.dart';
import 'package:flutter_order_app/features/order/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderAIDataSource aiDataSource;

  OrderRepositoryImpl({required this.aiDataSource});

  @override
  Future<Either<Failure, List<ParsedOrderItem>>> parseOrderText(
      String orderText) async {
    try {
      final result = await aiDataSource.parseOrderText(orderText);
      return Right(result);
    } on AIException catch (e) {
      return Left(AIFailure(e.message));
    } on ConfigException catch (e) {
      return Left(ConfigFailure(e.message));
    } catch (e) {
      return Left(AIFailure('Niespodziewany błąd: ${e.toString()}'));
    }
  }
}