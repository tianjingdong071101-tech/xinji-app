import 'package:equatable/equatable.dart';
import 'mood_type.dart';

class MoodRecord extends Equatable {
  final int id;
  final DateTime date;
  final MoodType moodType;
  final int? entryId;
  final DateTime createdAt;

  const MoodRecord({
    required this.id,
    required this.date,
    required this.moodType,
    this.entryId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, date, moodType, entryId, createdAt];
}
