import 'package:epub_image_compressor/utils/app_util.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;


/// 作业状态枚举
/// queued: 队列中
/// running: 运行中
/// success: 成功
/// failed: 失败
/// cancelled: 已取消
enum JobStatus { queued, running, success, failed, cancelled }


/// 压缩作业类
///
/// 用于管理EPUB文件压缩任务的状态和进度信息
class CompressorJob {
  /// 输入文件路径
  final String inputPath;

  /// 输出目录路径
  final String? outputDir;

  /// 建议的输出目录路径
  final String? suggestedOutputDir;

  /// 输出文件路径
  String? outputPath;

  /// 作业状态，使用Rx响应式变量
  final Rx<JobStatus> status = JobStatus.queued.obs;

  /// 处理进度，范围0.0-1.0
  final RxDouble progress = 0.0.obs;

  /// 总图片数量
  final RxInt totalImages = 0.obs;

  /// 已处理图片数量
  final RxInt processedImages = 0.obs;

  /// 节省的字节数
  final RxInt savedBytes = 0.obs;

  /// 原始文件大小
  final RxInt originalBytes = 0.obs;

  /// 压缩后文件大小
  final RxInt compressedBytes = 0.obs;

  /// 消息信息
  final RxString message = ''.obs;

  /// 日志列表
  final RxList<String> logs = <String>[].obs;

  /// 获取输入文件的文件名
  String get fileName => p.basename(inputPath);


  /// 获取默认输出目录路径
  ///
  /// 如果有建议输出目录则使用建议目录，否则在输入文件同目录下创建compressed_epub文件夹
  String? get defaultOutputDir =>
      suggestedOutputDir ?? p.join(p.dirname(inputPath), 'compressed_epub');

  /// 构造函数
  ///
  /// [inputPath] 输入文件路径，必需参数
  /// [outputDir] 输出目录路径，可选参数
  /// [suggestedOutputDir] 建议的输出目录路径，可选参数
  CompressorJob({
    required this.inputPath,
    this.outputDir,
    this.suggestedOutputDir,
  });

  /// 添加日志信息
  ///
  /// [text] 要添加的日志文本
  void addLog(String text) => logs.add(AppUtil.getTime()+text);

  String get formattedOriginalSize => AppUtil.formatSize(originalBytes.value);

  String get formattedCompressedSize =>
      compressedBytes.value > 0 ? AppUtil.formatSize(compressedBytes.value) : '--';
 }
