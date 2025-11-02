import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'order_item.g.dart';

// Encja reprezentująca pozycję w tabeli wynikowej
@JsonSerializable()
class OrderItem extends Equatable {
  final String productName;
  final int quantity;
  final double? unitPrice;
  final double? itemSum;
  final bool isMatched;

  const OrderItem({
    required this.productName,
    required this.quantity,
    this.unitPrice,
    this.itemSum,
    required this.isMatched,
  });

  @override
  List<Object?> get props =>
      [productName, quantity, unitPrice, itemSum, isMatched];

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}