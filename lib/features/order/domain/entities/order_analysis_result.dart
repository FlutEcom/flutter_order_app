import 'package:equatable/equatable.dart';
import 'package:flutter_order_app/features/order/domain/entities/order_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_analysis_result.g.dart';

// Encja reprezentująca kompletny wynik analizy
@JsonSerializable()
class OrderAnalysisResult extends Equatable {
  final List<OrderItem> items;
  final double totalSum;

  const OrderAnalysisResult({required this.items, required this.totalSum});

  @override
  List<Object?> get props => [items, totalSum];

    factory OrderAnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$OrderAnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$OrderAnalysisResultToJson(this);
}