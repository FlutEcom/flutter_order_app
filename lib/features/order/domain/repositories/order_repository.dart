import 'package:dartz/dartz.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/features/order/domain/entities/parsed_order_item.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<ParsedOrderItem>>> parseOrderText(String orderText);
}