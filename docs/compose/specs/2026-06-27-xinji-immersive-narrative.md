# 「心迹」沉浸式叙事引擎 — 组件与引擎设计规格

> 基于 frontend-design Swiss 锚点，在心迹情感日记 App 中新增沉浸式叙事组件和引擎层。

## [N1] 架构变更

```
lib/
├── engines/                        # 新增：引擎层
│   ├── story_engine.dart           # 叙事引擎核心
│   ├── mood_analysis_engine.dart   # 情绪分析引擎
│   └── scroll_sync_engine.dart     # 滚动联动引擎
└── presentation/
    ├── screens/
    │   ├── timeline/
    │   │   └── widgets/
    │   │       ├── timeline_flow.dart        # 叙事流组件
    │   │       └── timeline_streak_bar.dart   # 连续徽章
    │   ├── insights/
    │   │   └── widgets/
    │   │       ├── mood_star_chart.dart       # 情绪星图 (CustomPainter)
    │   │       └── mood_calendar_grid.dart    # 月历情绪热力图
    │   └── story/                            # 新增：全屏叙事流
    │       └── story_mode_screen.dart
    └── widgets/
        ├── diary_card.dart           # ← 升级：加左侧情绪线
        └── emotion_river.dart        # ← 升级 2.0：情绪色渐变
```

### 引擎职责

| 引擎 | 职责 | 输入 | 输出 |
|------|------|------|------|
| `StoryEngine` | 按时间/情绪/标签串联日记，生成导航结构 | DiaryRepository | 叙事流数据 (分段：今天/本周/本月/更早) |
| `MoodAnalysisEngine` | 从数据库聚合情绪趋势 | MoodRepository | 趋势数据 (日/周/月粒度) |
| `ScrollSyncEngine` | 管理时间线滚动时头部/标尺/背景的动画联动 | ScrollController | 0-1 progress 值驱动各组件 |

## [N2] 组件设计

### N2.1 TimelineFlow — 叙事流组件

**位置：** `presentation/screens/timeline/widgets/timeline_flow.dart`

替换现有的 `ListView.builder`。核心交互：

- 左侧竖排日期列（Swiss 数字排版：日期大字号粗体 + 周几小字）
- 每条日记左侧有一条 1px 竖线 = 情绪线，颜色 = `entry.moodType.color`
- 情绪线连接相邻日记（视觉上形成连续的色彩河流）
- 时间标尺分段器：`─── 今天 ───` / `─── 本周 ───` / `─── 更早 ───`
- 背景色根据可视区域内日记的情绪色做微渐变（由 ScrollSyncEngine 驱动）
- 空状态保持现有设计

**接口：**
```dart
class TimelineFlow extends StatelessWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry)? onEntryTap;
}
```

### N2.2 TimelineStreakBar — 连续徽章

**位置：** `presentation/screens/timeline/widgets/timeline_streak_bar.dart`

- 在情绪河流下方显示连续记录天数
- Swiss 风格：小字号 `连续 N 天` + 计数数字大号排版
- 无数据时不显示

### N2.3 MoodStarChart — 情绪星图 (CustomPainter)

**位置：** `presentation/screens/insights/widgets/mood_star_chart.dart`

替代洞察页面的饼图，提供更直觉的情绪分布可视化：

- 每个情绪是一个圆形节点
- 节点半径 = 出现次数的对数映射（min 20px, max 60px）
- 位置：快乐↔期待相近，忧伤↔思念相近，焦虑偏右独立，平静居中
- 节点颜色 = `MoodType.color`
- 节点间连线 = 两种情绪在同一天出现的频次（可选，>1 次才画）
- 选中节点时放大 + 显示情绪名称和计数

**接口：**
```dart
class MoodStarChart extends StatelessWidget {
  final Map<MoodType, int> distribution;
}
```

### N2.4 MoodCalendarGrid — 月历情绪热力图

**位置：** `presentation/screens/insights/widgets/mood_calendar_grid.dart`

- 月视图日历，每日一个方格
- 日期数字为 Swiss 排版（condensed 风格）
- 有日记的日期下方显示 `mood.color` 圆点
- 点击某天 → 跳转到当天日记列表
- 左右滑动切换月份
- 数据由 `MoodAnalysisEngine` 按月聚合

**接口：**
```dart
class MoodCalendarGrid extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDayTap;
}
```

### N2.5 StoryModeScreen — 全屏沉浸叙事流

**位置：** `presentation/screens/story/story_mode_screen.dart`

从时间线/日历某天进入的全屏叙事模式：

- 透明 AppBar，背景透出情绪色
- 大号 Swiss 日期排版（`2026.06.24  周四`）
- 情绪 emoji + 标签
- 正文：大行高 (1.6-1.8) 舒适阅读
- 底部照片缩略条
- **上下滑动 → 无缝切换到上一篇/下一篇日记**（页面转换 + 背景色渐变过渡）
- 背景色 = `entry.moodType.color.withValues(alpha: 0.05~0.12)`

## [N3] 引擎设计

### N3.1 StoryEngine

```dart
class StoryEngine {
  final DiaryRepository _repo;

  /// 获取按时间分段的日记列表
  Future<NarrativeData> getNarrative();

  /// 获取上/下一篇日记（用于时光机导航）
  Future<DiaryEntry?> getPrevious(int currentId);
  Future<DiaryEntry?> getNext(int currentId);
}

class NarrativeData {
  final List<DiarySegment> segments;
}

class DiarySegment {
  final String label; // 今天 / 本周 / 本月 / 更早
  final List<DiaryEntry> entries;
}
```

### N3.2 MoodAnalysisEngine

```dart
class MoodAnalysisEngine {
  final MoodRepository _repo;

  /// 获取指定月份每一天的情绪
  Future<Map<DateTime, MoodType?>> getDailyMoods(int year, int month);

  /// 获取情绪趋势（7天/30天滑动平均）
  Future<List<MoodTrendPoint>> getTrend(int days);
}

class MoodTrendPoint {
  final DateTime date;
  final MoodType dominantMood;
  final double intensity; // 0.0-1.0
}
```

### N3.3 ScrollSyncEngine

```dart
class ScrollSyncEngine extends ChangeNotifier {
  final ScrollController controller;

  double get scrollProgress; // 0.0-1.0
  double get headerOpacity;  // 基于偏移量
  Color? get dominantColor;  // 当前可视区主导情绪色
}
```

## [N4] 视觉规范（Swiss 锚点）

遵循 frontend-design Swiss 锚点：

| 维度 | 规范 |
|------|------|
| 表面 | `#FFFFFF` / `#F7F7F8` |
| 强调色 | Yves Klein Blue `#002FA7`（已有） |
| 字体 | 系统 sans，左对齐 |
| 结构 | 1px 发丝线，无圆角 |
| 数字 | 粗体大字号，作为构图元素 |
| 禁止 | 暖色背景、圆角 >2px、阴影 |

## [N5] 实现顺序

1. `MoodAnalysisEngine` + `StoryEngine`（数据层，无 UI 依赖）
2. `ScrollSyncEngine`（工具类，无 UI 依赖）
3. `TimelineStreakBar`（简单组件，快速产出）
4. `TimelineFlow`（核心叙事流，替换现有 ListView）
5. `MoodCalendarGrid`（月历热力图）
6. `MoodStarChart`（星图，CustomPainter）
7. `StoryModeScreen`（全屏沉浸叙事）
8. 集成：时间线 → 时光机导航 + 日历 → 详情导航
