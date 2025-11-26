import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:path/path.dart' as p;

import '../../models/models.dart';
import '../../routers/routes.dart';
import '../../values/values.dart';

class CompressState {
  var newJobs = <CompressorJob>[].obs;
  final RxList<String> timeline = <String>[].obs;

  final RxDouble overallProgress = 0.0.obs;


  CompressState() {}

  AppBar buildAppBar() {
    return AppBar(
      elevation: 1,
      backgroundColor: AppColors.surface,
      title: Text(
        AppStrings.appName,
        style: buildTextStyle(20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          tooltip: '设置',
          onPressed: () => Get.toNamed(AppRoutes.setting),
          icon: const Icon(Icons.settings, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget buildVerticalDivider() {
    return const VerticalDivider(
      width: 1,
      color: AppColors.divider,
    );
  }
  Widget buildHorizontalDivider() {
    return const Divider(
      height: 1,
      color: AppColors.divider,
    );
  }




  TextStyle buildTextStyle(double fontSize,
      {FontStyle fontStyle = FontStyle.normal,
      FontWeight fontWeight = FontWeight.normal,Color color= AppColors.textPrimary,}) {
    return TextStyle(
      fontSize: fontSize,
      color: color,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
    );
  }

  BoxDecoration buildBoxDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      border: Border(
        top: BorderSide(color: AppColors.divider, width: 2),
      ),
    );
  }

  Widget buildButton(String text, VoidCallback onPressed, IconData iconData) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(iconData, color: AppColors.primary),
      label: Text(text, style: buildTextStyle(10)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(
            color: AppColors.primary,
            width: 1,
          ),
        ),
      ),
    );
  }

  /// 根据任务状态返回对应的颜色。
  ///
  /// [status] - 当前任务状态。
  /// [theme] - 主题数据，用于获取颜色方案。
  ///
  /// 返回值：适用于该状态的颜色。
  Color statusColor(JobStatus status, ThemeData theme) {
    switch (status) {
      case JobStatus.running:
        return Colors.green;
      case JobStatus.success:
        return AppColors.primary;
      case JobStatus.failed:
        return theme.colorScheme.error;
      case JobStatus.cancelled:
        return Colors.orange;
      case JobStatus.queued:
      default:
        return theme.colorScheme.outline;
    }
  }

  /// 将任务状态转换为人类易读的文字描述。
  ///
  /// [status] - 当前任务状态。
  ///
  /// 返回值：状态对应的中文描述。
  String statusText(JobStatus status) {
    switch (status) {
      case JobStatus.running:
        return '进行中';
      case JobStatus.success:
        return '完成';
      case JobStatus.failed:
        return '失败';
      case JobStatus.cancelled:
        return '已取消';
      case JobStatus.queued:
      default:
        return '等待';
    }
  }
}
