import 'package:flutter/foundation.dart';

import '../../services/foreground_service.dart';
import 'macos/macos_bot_runtime_controller.dart';

abstract class BotRuntimeController {
  bool get supportsPersistentBackground;

  void init();

  Future<void> start({
    required String title,
    required String text,
  });

  Future<void> update({
    required String title,
    required String text,
  });

  Future<void> stop();

  Future<void> requestBatteryOptimization();
}

BotRuntimeController createBotRuntimeController() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
    return MacosBotRuntimeController();
  }
  return ForegroundTaskBotRuntimeController();
}

class ForegroundTaskBotRuntimeController implements BotRuntimeController {
  @override
  bool get supportsPersistentBackground => true;

  @override
  void init() => ForegroundService.init();

  @override
  Future<void> start({
    required String title,
    required String text,
  }) =>
      ForegroundService.start(title: title, text: text);

  @override
  Future<void> update({
    required String title,
    required String text,
  }) =>
      ForegroundService.update(title: title, text: text);

  @override
  Future<void> stop() => ForegroundService.stop();

  @override
  Future<void> requestBatteryOptimization() =>
      ForegroundService.requestBatteryOptimization();
}
