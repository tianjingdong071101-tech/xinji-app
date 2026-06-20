enum MoodType {
  happy('快乐', '☀️'),
  calm('平静', '🌤'),
  longing('思念', '🌧'),
  sad('忧伤', '🌨'),
  anxious('焦虑', '🌪'),
  hopeful('期待', '🌈');

  final String label;
  final String emoji;

  const MoodType(this.label, this.emoji);
}
