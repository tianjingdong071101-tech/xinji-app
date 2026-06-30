import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repository/essay_repository_impl.dart';
import '../../../data/repository/mood_repository_impl.dart';
import '../../../domain/model/mood_type.dart';

part 'insights_provider.g.dart';

class InsightsState {
  final Map<MoodType, int> distribution;
  final int totalEntries;
  final int streakDays;

  const InsightsState({
    this.distribution = const {},
    this.totalEntries = 0,
    this.streakDays = 0,
  });
}

@riverpod
class Insights extends _$Insights {
  @override
  Future<InsightsState> build() async {
    final moodRepo = ref.watch(moodRepositoryProvider);
    final diaryRepo = ref.watch(diaryRepositoryProvider);

    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final distribution = await moodRepo.getMoodDistribution(monthAgo, now);
    final total = await diaryRepo.getEntryCount();
    final streak = await diaryRepo.getStreakCount();

    return InsightsState(
      distribution: distribution,
      totalEntries: total,
      streakDays: streak,
    );
  }
}
