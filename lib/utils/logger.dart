import 'dart:io';

/// 最小日志等级控制
enum LogLevel { debug, info, warn, error }

/// 统一的日志工具，支持等级过滤、控制台与文件输出。
class Logger {
  Logger._internal();

  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;

  /// 最低输出等级（低于此等级的日志会被忽略）
  LogLevel minLevel = LogLevel.debug;

  /// 是否输出到控制台
  bool logToConsole = true;

  /// 是否写入到文件
  bool logToFile = false;

  /// 日志文件路径（仅 [logToFile] 为 true 时生效）
  String logFilePath = 'app_log.txt';

  /// 通用日志入口，兼容旧的 [isError] 标记。
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    String tag = 'app',
    bool? isError,
  }) {
    final effectiveLevel = isError == true ? LogLevel.error : level;
    if (!_shouldLog(effectiveLevel)) return;

    final timestamp = _now();
    final record =
        '[$timestamp] [${_levelLabel(effectiveLevel)}] [$tag] $message';

    if (logToConsole) {
      if (effectiveLevel == LogLevel.error) {
        stderr.writeln(record);
      } else {
        stdout.writeln(record);
      }
    }

    if (logToFile) {
      _writeToFile(record);
    }
  }

  /// 便捷方法：调试
  void debug(String message, {String tag = 'app'}) =>
      log(message, level: LogLevel.debug, tag: tag);

  /// 便捷方法：信息
  void info(String message, {String tag = 'app'}) =>
      log(message, level: LogLevel.info, tag: tag);

  /// 便捷方法：警告
  void warn(String message, {String tag = 'app'}) =>
      log(message, level: LogLevel.warn, tag: tag);

  /// 便捷方法：错误
  void error(String message, {String tag = 'app'}) =>
      log(message, level: LogLevel.error, tag: tag);

  bool _shouldLog(LogLevel level) => level.index >= minLevel.index;
  String _levelLabel(LogLevel level) => level.name.toUpperCase();

  /// 当前时间戳字符串
  String _now() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    final ms = now.millisecond.toString().padLeft(3, '0');
    return '${now.toIso8601String().split("T").first} $h:$m:$s.$ms';
  }

  /// 追加写入日志文件（失败时静默忽略）
  Future<void> _writeToFile(String record) async {
    try {
      final file = File(logFilePath);
      await file.writeAsString('$record\n', mode: FileMode.append, flush: true);
    } catch (_) {}
  }
}
