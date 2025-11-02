import 'package:equatable/equatable.dart';

// Encja reprezentująca odpowiedź z AI
class ParsedOrderItem extends Equatable {
  final String name;
  final int quantity;

  const ParsedOrderItem({required this.name, required this.quantity});

  @override
  List<Object?> get props => [name, quantity];
}