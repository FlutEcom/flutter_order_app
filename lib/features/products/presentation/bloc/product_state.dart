part of 'product_bloc.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> allProducts; // Zawsze trzymamy pełną listę
  final List<Product> displayedProducts; // Filtrowana lista do wyświetlenia
  
  const ProductLoaded({
    required this.allProducts,
    required this.displayedProducts,
  });

  @override
  List<Object> get props => [allProducts, displayedProducts];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
  @override
  List<Object> get props => [message];
}