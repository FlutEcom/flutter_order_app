part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderAnalysisSuccess extends OrderState {
  final OrderAnalysisResult result;
  const OrderAnalysisSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class OrderError extends OrderState {
  final String message;
  const OrderError(this.message);
  @override
  List<Object> get props => [message];
}