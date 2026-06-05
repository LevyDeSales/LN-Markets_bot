import 'dart:async';

enum LogLevel { info, warning, error, debug }

class LogEntry {
  final DateTime time;
  final LogLevel level;
  final String message;
  LogEntry(this.level, this.message) : time = DateTime.now();

  String get prefix {
    switch (level) {
      case LogLevel.info:
        return '[INFO]   ';
      case LogLevel.warning:
        return '[WARN]   ';
      case LogLevel.error:
        return '[ERROR]  ';
      case LogLevel.debug:
        return '[DEBUG]  ';
    }
  }

  String get timeStr {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  String toString() => '$timeStr $prefix$message';
}

class LogService {
  final _controller = StreamController<LogEntry>.broadcast();
  final List<LogEntry> history = [];

  Stream<LogEntry> get stream => _controller.stream;

  void _add(LogLevel level, String msg) {
    final entry = LogEntry(level, msg);
    history.add(entry);
    if (history.length > 500) history.removeAt(0);
    _controller.add(entry);
  }

  void info(String msg) => _add(LogLevel.info, msg);
  void warning(String msg) => _add(LogLevel.warning, msg);
  void error(String msg) => _add(LogLevel.error, msg);
  void debug(String msg) => _add(LogLevel.debug, msg);

  void clear() => history.clear();
  void dispose() => _controller.close();
}
