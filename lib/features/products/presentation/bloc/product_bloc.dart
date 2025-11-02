import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_order_app/core/usecase/usecase.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';
import 'package:flutter_order_app/features/products/domain/usecases/get_products.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProducts getProducts;

  ProductBloc({required this.getProducts}) : super(ProductInitial()) {
    on<FetchProducts>(_onFetchProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onFetchProducts(
    FetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final failureOrProducts = await getProducts(NoParams());
    failureOrProducts.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductLoaded(
        allProducts: products,
        displayedProducts: products,
      )),
    );
  }

  void _onSearchProducts(SearchProducts event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      
      if (event.query.isEmpty) {
        emit(ProductLoaded(
          allProducts: currentState.allProducts,
          displayedProducts: currentState.allProducts,
        ));
      } else {
        final filteredList = currentState.allProducts
            .where((product) => product.title
                .toLowerCase()
                .contains(event.query.toLowerCase()))
            .toList();
        
        emit(ProductLoaded(
          allProducts: currentState.allProducts,
          displayedProducts: filteredList,
        ));
      }
    }
  }
}