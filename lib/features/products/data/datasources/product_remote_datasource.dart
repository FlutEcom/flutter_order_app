import 'package:dio/dio.dart';
import 'package:flutter_order_app/core/error/exceptions.dart';
import 'package:flutter_order_app/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;
  final String _url = "https://dummyjson.com/products?limit=50";

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await dio.get(_url);
      if (response.statusCode == 200) {
        final List<dynamic> productsJson = response.data['products'];
        return productsJson.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            'Błąd serwera: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException('Błąd sieci: ${e.message}');
    } catch (e) {
      throw ServerException('Niespodziewany błąd: ${e.toString()}');
    }
  }
}