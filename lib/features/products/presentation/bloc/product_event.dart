part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class FetchProducts extends ProductEvent {}

// Bonus: Wyszukiwanie
class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);
  @override
  List<Object> get props => [query];
}