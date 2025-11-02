import 'package:dio/dio.dart';
import 'package:flutter_order_app/core/config/config_service.dart';
import 'package:flutter_order_app/features/order/data/datasources/order_ai_datasource.dart';
import 'package:flutter_order_app/features/order/data/repositories/order_repository_impl.dart';
import 'package:flutter_order_app/features/order/domain/repositories/order_repository.dart';
import 'package:flutter_order_app/features/order/domain/usecases/analyze_order.dart';
import 'package:flutter_order_app/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_order_app/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_order_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_order_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_order_app/features/products/domain/usecases/get_products.dart';
import 'package:flutter_order_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Core ---
  sl.registerSingleton(Dio());
  sl.registerSingleton(ConfigService());

  // Ładowanie konfiguracji przy starcie
  final configService = sl<ConfigService>();
  await configService.loadConfig();
  sl.registerSingleton<AppConfig>(configService.config);

  // --- Features ---

  // Products
  // BLoC
  sl.registerFactory(() => ProductBloc(getProducts: sl()));
  // UseCases
  sl.registerLazySingleton(() => GetProducts(sl()));
  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  // DataSources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );

  // Order
  // BLoC
  sl.registerFactory(() => OrderBloc(analyzeOrderUseCase: sl()));
  // UseCases
  sl.registerLazySingleton(() => AnalyzeOrder(sl()));
  // Repositories
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(aiDataSource: sl()),
  );
  // DataSources
  sl.registerLazySingleton<OrderAIDataSource>(
    () => OrderAIDataSourceImpl(dio: sl(), config: sl()),
  );
}