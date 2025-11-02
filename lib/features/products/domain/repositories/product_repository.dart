import 'package:dartz/dartz.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
}