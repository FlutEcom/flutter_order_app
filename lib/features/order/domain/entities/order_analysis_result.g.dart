// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_analysis_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderAnalysisResult _$OrderAnalysisResultFromJson(Map<String, dynamic> json) =>
    OrderAnalysisResult(
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSum: (json['totalSum'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderAnalysisResultToJson(
  OrderAnalysisResult instance,
) => <String, dynamic>{'items': instance.items, 'totalSum': instance.totalSum};
