import 'package:equatable/equatable.dart';

class Tag extends Equatable {
  final int id;
  final String name;
  final String color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
