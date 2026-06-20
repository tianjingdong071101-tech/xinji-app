# 「心迹」— 情感日记 App 设计规格

> [!NOTE]
> This document may not reflect the current implementation.
> See the final report for up-to-date state:
> [Final Report](../reports/xinji-app.md)

> 跨平台情感日记 App，Flutter + Drift + Riverpod + Clean Architecture

## [S1] 产品定位

一款以**情绪追踪**为核心的日记 App。用户记录日常事件和感受的同時，自动生成情绪变化趋势分析，帮助理解自己的心理状态和成长轨迹。

目标用户：关注心理健康、有写日记习惯或想要培养日记习惯的年轻人。

## [S2] 设计方向

**锚点：Organic** — 温暖纸质感，大地色系。

**不同化标识：「情感天气」** — 每种情绪映射为一种天气现象（晴/雨/风/雪/虹），在时间线上以流动的色彩河流呈现。

### 配色

| 用途 | 色值 | 说明 |
|------|------|------|
| 背景 | #E8DCC7 | 沙色，暖纸白 |
| 背景深 | #D4B895 | 燕麦色，微妙渐变 |
| 卡片 | #FFFFFF | 纯白 + 柔和阴影 |
| 文字主 | #2C2C2C | 深炭灰 |
| 文字辅 | #8C8C8C | 中灰 |
| 强调 | #C8956C | 琥珀棕 |
| 次要强调 | #C66B3D | 陶土红 |

### 情绪色系

| 情绪 | 色值 | 天气符号 |
|------|------|----------|
| 快乐 | #E8C170 暖金 | ☀️ 晴 |
| 平静 | #A0B8A0 苔绿 | 🌤 多云 |
| 思念 | #7BA7BC 雾蓝 | 🌧 雨 |
| 忧伤 | #B08BA0 薰衣草紫 | 🌨 雪 |
| 焦虑 | #C66B3D 赤陶 | 🌪 风 |
| 期待 | #A8C686 草绿 | 🌈 虹 |

### 字体

系统默认字体。中文用系统默认，英文用 warm geometric sans。

### 结构

- 圆角 16-32px
- Grain texture 1-3%（SVG feTurbulence）
- 温和动画 ease 300-500ms
- 禁止：纯白/纯黑背景、冷灰色、硬直角

## [S3] 技术架构

### 技术栈

| 层 | 技术 |
|----|------|
| 框架 | Flutter (Dart) |
| 状态管理 | Riverpod |
| 本地数据库 | Drift (SQLite) |
| 路由 | go_router |
| 图表 | fl_chart |
| 图片选择 | image_picker |
| 语音录制 | record / just_audio |
| DI | Riverpod (auto-generated) |

### 架构分层

```
lib/
├── app/          # App 入口、路由配置
├── core/         # 通用工具、主题、常量
│   ├── theme/    # 主题/配色/字体
│   ├── util/     # 工具函数
│   └── constants/
├── data/         # 数据层
│   ├── database/ # Drift 数据库定义
│   ├── dao/      # 数据访问对象
│   └── repository/ # 仓库实现
├── domain/       # 领域层
│   ├── model/    # 实体模型
│   ├── repository/ # 仓库接口
│   └── usecase/  # 业务用例
└── presentation/ # 展示层
    ├── providers/ # Riverpod providers
    ├── screens/  # 页面
    │   ├── timeline/   # 情绪时间线
    │   ├── write/      # 写日记
    │   ├── insights/   # 洞察分析
    │   └── profile/    # 我的
    └── widgets/  # 可复用组件
```

## [S4] 数据模型

### DiaryEntry（日记条目）

```
id: INTEGER PRIMARY KEY AUTOINCREMENT
title: TEXT (nullable)
content: TEXT NOT NULL
moodType: TEXT NOT NULL (enum: HAPPY/CALM/LONGING/SAD/ANXIOUS/HOPEFUL)
createdAt: INTEGER NOT NULL (timestamp)
updatedAt: INTEGER NOT NULL (timestamp)
weatherTag: TEXT (nullable, 实际天气)
photoPaths: TEXT (nullable, JSON array)
audioPath: TEXT (nullable)
tags: TEXT (nullable, JSON array)
```

### MoodRecord（情绪记录，用于图表）

```
id: INTEGER PRIMARY KEY AUTOINCREMENT
date: TEXT NOT NULL (YYYY-MM-DD)
moodType: TEXT NOT NULL
entryId: INTEGER (nullable, 关联日记)
createdAt: INTEGER NOT NULL
```

### Tag（标签）

```
id: INTEGER PRIMARY KEY AUTOINCREMENT
name: TEXT NOT NULL UNIQUE
color: TEXT NOT NULL
createdAt: INTEGER NOT NULL
```

## [S5] 页面结构

### 底部导航（4 Tab）

1. **情绪时间线**（首页）—「情感天气」河流 + 日记卡片
2. **写日记** — 中间 FAB 按钮（非 Tab）
3. **洞察** — 图表 + 统计
4. **我的** — 设置

### 情绪时间线页

- 顶部：日期 + 问候语
- 情绪河流：横向流动的渐变条，颜色代表今日情绪
- 日记列表：按日期倒序，卡片展示情绪标记 + 摘要 + 照片缩略图
- 空状态：「今天还没有记录，写下你的心情吧」

### 写日记页

- 情绪选择器：6 种情绪，天气符号 + 颜色
- 标题输入（可选）
- 正文：全屏沉浸式文本输入
- 附件：照片 + 录音
- 标签选择/创建
- 保存按钮

### 洞察页

- 情绪日历：月视图，每日颜色标记
- 趋势折线图：7天/30天/90天
- 各情绪占比饼图
- 统计数据（连续记录天数、总条目数、本月记录数）
- 高频词云

### 我的页面

- 统计概览（总日记数、连续天数、标签数）
- 数据导出（JSON/CSV）
- 设置（提醒、字体大小、主题切换）
- 关于

## [S6] 导航路由

```
/timeline          → 情绪时间线（首页）
/write             → 写日记
/insights          → 洞察分析
/profile           → 我的
/diary/:id         → 日记详情
/diary/:id/edit    → 编辑日记
```

## [S7] MVP 范围

### 第一阶段（MVP）
- 写日记 + 情绪标记
- 照片附件（最多 9 张）
- 语音录音
- 情绪时间线浏览
- 标签系统
- 情绪趋势图表（7天/30天）
- 数据本地存储
- 搜索日记

### 第二阶段
- 数据导出（JSON/CSV）
- 日历视图
- 每日提醒
- 日记详情页编辑

### 第三阶段
- 云端同步
- AI 情绪分析
- 密码/生物锁

## [S8] 动画规范

- 页面转场：fade 300ms + slide
- 列表项进入：fade + slideFromBottom，每项 delay 50ms
- FAB 点击：spring scale
- 情绪选择：spring(0.6) scale 1.0→1.15
- 情绪河流：横向无限滚动渐变，随数据变化
- 卡片按下：scale 0.98 + 阴影变化
