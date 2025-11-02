import 'package:dartz/dartz.dart';
import 'package:flutter_order_app/core/error/exceptions.dart';
import 'package:flutter_order_app/core/error/failure.dart';
import 'package:flutter_order_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';
import 'package:flutter_order_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final remoteProducts = await remoteDataSource.getProducts();
      return Right(remoteProducts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}