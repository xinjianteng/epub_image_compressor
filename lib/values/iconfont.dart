import 'package:flutter/material.dart';

/// 统一管理自定义字体图标，使用前需在 pubspec.yaml 中声明字体资源。
class Iconfont {
  static const share = IconData(
    0xe60d,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );

  static const home = IconData(
    0xe600,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );

  static const search = IconData(
    0xe601,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );

  static const user = IconData(
    0xe602,
    fontFamily: 'Iconfont',
    matchTextDirection: true,
  );
}
