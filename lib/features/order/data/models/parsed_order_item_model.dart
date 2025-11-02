import 'package:flutter_order_app/features/order/domain/entities/parsed_order_item.dart';
import 'package:json_annotation/json_annotation.dart';

part 'parsed_order_item_model.g.dart';

@JsonSerializable()
class ParsedOrderItemModel extends ParsedOrderItem {
  const ParsedOrderItemModel({required super.name, required super.quantity});

  factory ParsedOrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$ParsedOrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParsedOrderItemModelToJson(this);
}