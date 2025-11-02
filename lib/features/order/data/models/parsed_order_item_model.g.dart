// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParsedOrderItemModel _$ParsedOrderItemModelFromJson(
  Map<String, dynamic> json,
) => ParsedOrderItemModel(
  name: json['name'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$ParsedOrderItemModelToJson(
  ParsedOrderItemModel instance,
) => <String, dynamic>{'name': instance.name, 'quantity': instance.quantity};
