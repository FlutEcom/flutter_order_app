import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_order_app/features/order/domain/entities/order_analysis_result.dart';
import 'package:flutter_order_app/features/order/domain/usecases/analyze_order.dart';
import 'package:flutter_order_app/features/products/domain/entities/product.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final AnalyzeOrder analyzeOrderUseCase;

  OrderBloc({required this.analyzeOrderUseCase}) : super(OrderInitial()) {
    on<AnalyzeOrderEvent>(_onAnalyzeOrder);
    on<ResetOrder>((event, emit) => emit(OrderInitial()));
  }

  Future<void> _onAnalyzeOrder(
    AnalyzeOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final params = AnalyzeOrderParams(
      orderText: event.orderText,
      allProducts: event.allProducts,
    );
    final failureOrResult = await analyzeOrderUseCase(params);

    failureOrResult.fold(
      (failure) => emit(OrderError(failure.message)),
      (result) => emit(OrderAnalysisSuccess(result)),
    );
  }
}