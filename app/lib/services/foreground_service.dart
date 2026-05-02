import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// Top-level entry point for the background isolate — must be annotated.
@pragma('vm:entry-point')
void botForegroundEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_BotTaskHandler());
}

class _BotTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Keep-alive tick — actual trading logic runs in the main Dart isolate
    // via TraderService timers which survive while this service is active.
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

class ForegroundService {
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    _initialized = true;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'lnmarkets_bot_channel',
        channelName: 'LN Markets Bot',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> start({
    required String title,
    required String text,
  }) async {
    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: title,
        notificationText: text,
        callback: botForegroundEntryPoint,
      );
    } catch (e) {
      // Graceful degradation — app still works without foreground service
    }
  }

  static Future<void> update({
    required String title,
    required String text,
  }) async {
    try {
      await FlutterForegroundTask.updateService(
        notificationTitle: title,
        notificationText: text,
      );
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await FlutterForegroundTask.stopService();
    } catch (_) {}
  }

  static Future<void> requestBatteryOptimization() async {
    try {
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }
    } catch (_) {}
  }
}
