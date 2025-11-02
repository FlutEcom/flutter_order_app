import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_order_app/core/di/injector.dart';
import 'package:flutter_order_app/features/products/presentation/bloc/product_bloc.dart';
import 'package:flutter_order_app/navigation/home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProductBloc>()..add(FetchProducts()),
        ),
        // OrderBloc będzie dostarczony lokalnie na OrderPage
      ],
      child: MaterialApp(
        title: 'Flutter Order App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 1,
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const HomePage(),
      ),
    );
  }
}