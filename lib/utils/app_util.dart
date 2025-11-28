import 'dart:io';
import 'dart:math';

import 'package:url_launcher/url_launcher.dart';

/// 工具类，提供应用程序相关的实用功能
class AppUtil {
  /// 获取当前时间的毫秒级时间戳
  static String getTime([DateTime? time]) {
    final now = time ?? DateTime.now();
    return now.millisecondsSinceEpoch.toString();
  }

  /// 生成一个随机的nonce字符串
  static const String NONCE_SET =
      '0123456789abcdefghijklmnoprrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// 生成一个16字符长度的随机nonce字符串
  static String getNonce() {
    final length = NONCE_SET.length;
    var str = '';
    for (var i = 0; i < 16; i++) {
      str = str + NONCE_SET[Random().nextInt(length)];
    }
    return str;
  }

  /// 在外部浏览器中打开指定URL
  static Future<void> openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  /// 打开本地文件或目录
  static Future<void> openFile(String path) async {
    final file = File(path);
    final uri = Uri.file(file.path);
    if (!file.existsSync()) {
      throw 'File not found: $path';
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open $path';
    }
  }

  /// 格式化文件大小显示
  static String formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var index = 0;
    while (size >= 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }
    return '${size.toStringAsFixed(size >= 10 ? 0 : 1)} ${suffixes[index]}';
  }

  /// 格式化耗时
  static String formatDuration(Duration duration) {
    if (duration.inMilliseconds < 1000) {
      return '${duration.inMilliseconds} ms';
    }
    if (duration.inSeconds < 60) {
      final hundredMs = (duration.inMilliseconds % 1000) ~/ 100;
      return '${duration.inSeconds}.${hundredMs}s';
    }
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
