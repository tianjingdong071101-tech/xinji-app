import 'package:flutter/material.dart';

class ScrollSyncEngine extends ChangeNotifier {
  final ScrollController controller;

  ScrollSyncEngine(this.controller) {
    controller.addListener(_onScroll);
  }

  double get scrollProgress {
    if (!controller.hasClients) return 0.0;
    final max = controller.position.maxScrollExtent;
    if (max <= 0) return 0.0;
    return (controller.offset / max).clamp(0.0, 1.0);
  }

  double get headerOpacity {
    final progress = scrollProgress;
    if (progress < 0.15) return 1.0;
    if (progress < 0.4) return 1.0 - (progress - 0.15) / 0.25;
    return 0.0;
  }

  void _onScroll() {
    notifyListeners();
  }

  @override
  void dispose() {
    controller.removeListener(_onScroll);
    super.dispose();
  }
}
