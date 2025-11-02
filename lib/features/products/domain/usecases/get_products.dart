import 'package:dartz/dartz.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/core/usecase/usecase.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';
import 'package:flutter_order_app/features/products/domain/repositories/product_repository.dart';

class GetProducts implements UseCase<List<Product>, NoParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getProducts();
  }
}