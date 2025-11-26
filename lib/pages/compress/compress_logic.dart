import 'dart:io';

import 'package:epub_image_compressor/utils/app_util.dart';
import 'package:epub_image_compressor/values/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;

import '../../models/models.dart';
import '../../service/epub_compressor.dart';
import 'compress_state.dart';

class CompressLogic extends GetxController {
  final CompressState state = CompressState();

  // final RxList<CompressState> batchJobs = <CompressState>[].obs;

  final RxString outputDir = ''.obs;
  final RxBool isRunning = false.obs;

  // Options
  final RxInt quality = 60.obs;
  final RxBool skipSmall = true.obs;
  final RxInt minKb = 12.obs;
  final RxInt pngLevel = 6.obs;

  final EpubCompressor _compressor = EpubCompressor();
  CancellationToken? _token;
  static const int _maxLogEntries = 500;

  CompressionOptions get currentOptions => CompressionOptions(
        quality: quality.value,
        skipSmallImages: skipSmall.value,
        minImageBytes: minKb.value * 1024,
        pngLevel: pngLevel.value,
      );

  Future<void> pickBatchFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['epub'],
    );
    if (result == null) return;

    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      final alreadyExists =
          state.newJobs.any((job) => p.equals(job.inputPath, path));
      if (!alreadyExists) {
        final autoDir = _buildTimestampDir(path);
        final job = CompressorJob(
          inputPath: path,
          outputDir: outputDir.value.isEmpty ? null : outputDir.value,
          suggestedOutputDir: autoDir,
        );
        if (file.size > 0) {
          job.originalBytes.value = file.size;
        }
        state.newJobs.add(job);
      }
    }
    update();
  }

  void clearBatch() {
    if (isRunning.value) return;
    state.newJobs.clear();
    state.overallProgress.value = 0;
    update();
  }

  Future<void> chooseOutputDir() async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;
    outputDir.value = dir;
    for (var i = 0; i < state.newJobs.length; i++) {
      state.newJobs[i] = CompressorJob(
        inputPath: state.newJobs[i].inputPath,
        outputDir: dir,
        suggestedOutputDir: state.newJobs[i].suggestedOutputDir,
      );
    }
    state.newJobs.refresh();
    update();
  }

  void clearOutputDir() {
    outputDir.value = '';
    for (var i = 0; i < state.newJobs.length; i++) {
      state.newJobs[i] = CompressorJob(
        inputPath: state.newJobs[i].inputPath,
        outputDir: null,
        suggestedOutputDir: state.newJobs[i].suggestedOutputDir,
      );
    }
    update();
  }

  Future<void> startBatch() async {
    if (state.newJobs.isEmpty || isRunning.value) return;
    isRunning.value = true;
    state.overallProgress.value = 0;
    _token = CancellationToken();
    final totalJobs = state.newJobs.length;

    for (var i = 0; i < totalJobs; i++) {
      if (_token?.isCancelled == true) break;
      await _runJob(state.newJobs[i], i, totalJobs);
      state.overallProgress.value = (i + 1) / totalJobs;
    }

    isRunning.value = false;
  }

  void cancelAll() {
    _token?.cancel();
  }

  String _buildTimestampDir(String samplePath) {
    final now = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final ts =
        '${now.year}${pad(now.month)}${pad(now.day)}_${pad(now.hour)}${pad(now.minute)}${pad(now.second)}';
    return p.join(p.dirname(samplePath), 'epub_output_$ts');
  }

  Future<void> _runJob(
    CompressorJob job,
    int index,
    int total,
  ) async {
    _token ??= CancellationToken();
    job.status.value = JobStatus.running;
    job.progress.value = 0;
    job.message.value = '处理中...';
    job.logs.clear();
    job.originalBytes.value = await _getFileSize(job.inputPath);

    final targetDir = outputDir.value.isNotEmpty
        ? outputDir.value
        : job.defaultOutputDir ?? _buildTimestampDir(job.inputPath);

    _log(job, '输入：${job.inputPath}');
    _log(job, '输出目录：$targetDir');

    try {
      final summary = await _compressor.compressEpub(
        inputPath: job.inputPath,
        outputDir: targetDir,
        options: currentOptions,
        cancelToken: _token,
        onLog: (msg) => _log(job, msg),
        onProgress: (progress) {
          job.totalImages.value = progress.totalImages;
          job.processedImages.value = progress.processedImages;
          job.progress.value = progress.percent;
          state.overallProgress.value =
              (index + progress.percent) / (total == 0 ? 1 : total);
        },
      );

      job.outputPath = summary.outputPath;
      job.savedBytes.value = summary.savedBytes;
      job.compressedBytes.value = await _getFileSize(summary.outputPath);

      if (_token?.isCancelled == true || summary.cancelled) {
        job.status.value = JobStatus.cancelled;
        job.message.value = '已取消';
      } else {
        job.status.value = JobStatus.success;
        job.message.value =
            '完成，${summary.processedImages} 张图，节省 ${AppUtil.formatSize(summary.savedBytes)}';
      }
    } on CompressionCancelled {
      job.status.value = JobStatus.cancelled;
      job.message.value = '已取消';
    } catch (e) {
      job.status.value = JobStatus.failed;
      job.message.value = '失败：$e';
      _log(job, '错误：$e');
    } finally {
      job.progress.value = 1.0;
      state.timeline.add('[${job.fileName}] ${job.message.value}');
      _trimLogs(state.timeline);
    }
  }

  void _log(CompressorJob job, String message) {
    job.addLog(message);
    _trimLogs(job.logs);
    state.timeline.add('${job.fileName}: $message');
    _trimLogs(state.timeline);
  }

  void _trimLogs(RxList<String> logs) {
    final overflow = logs.length - _maxLogEntries;
    if (overflow > 0) {
      logs.removeRange(0, overflow);
    }
  }

  void clearTimeline() {
    state.timeline.clear();
  }

  /// 浮动按钮按下后的响应处理器。
  ///
  /// 判断当前是否有正在运行的任务，若有则弹窗询问是否取消；否则检查是否存在待处理任务，
  /// 如有则开始批量压缩，如没有则提示用户先添加任务。
  ///
  /// [context] - 页面上下文。
  /// [logic] - 压缩逻辑控制器。
  Future<void> handleFabPressed() async {
    if (isRunning.value) {
      await _confirmCancel();
      return;
    }
    if (state.newJobs.isEmpty) {
      Get.snackbar(
        '提示',
        '请先添加要压缩的 EPUB 文件',
        snackPosition: SnackPosition.BOTTOM,
        // backgroundColor: AppColors.divider,
        colorText: AppColors.textPrimary,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    await startBatch();
  }

  /// 弹出对话框确认是否取消正在进行的所有压缩任务。
  ///
  /// 若用户点击“取消任务”，则调用逻辑层的 cancelAll 方法终止所有任务。
  ///
  /// [context] - 上下文环境。
  /// [logic] - 压缩逻辑控制器实例。
  Future<void> _confirmCancel() async {
    Get.defaultDialog(
      title: '确认取消',
      content: const Text('当前有任务正在运行，是否取消所有任务？'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            cancelAll();
            Get.back();
          },
          child: const Text('取消任务'),
        ),
      ],
    );
  }

  Future<int> _getFileSize(String path) async {
    try {
      return await File(path).length();
    } catch (_) {
      return 0;
    }
  }
}
