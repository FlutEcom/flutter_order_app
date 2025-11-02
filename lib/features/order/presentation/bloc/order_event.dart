part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object> get props => [];
}

class AnalyzeOrderEvent extends OrderEvent {
  final String orderText;
  final List<Product> allProducts;

  const AnalyzeOrderEvent({required this.orderText, required this.allProducts});

  @override
  List<Object> get props => [orderText, allProducts];
}

class ResetOrder extends OrderEvent {}