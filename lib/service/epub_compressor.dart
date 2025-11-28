import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:epub_image_compressor/utils/app_util.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class CompressionOptions {
  const CompressionOptions({
    this.quality = 85,
    this.skipSmallImages = true,
    this.minImageBytes = 10 * 1024,
    this.pngLevel = 6,
  });

  final int quality;
  final bool skipSmallImages;
  final int minImageBytes;
  final int pngLevel;

  Map<String, dynamic> toMap() {
    return {
      'quality': quality,
      'skipSmallImages': skipSmallImages,
      'minImageBytes': minImageBytes,
      'pngLevel': pngLevel,
    };
  }

  factory CompressionOptions.fromMap(Map<String, dynamic> map) {
    return CompressionOptions(
      quality: map['quality'] as int? ?? 85,
      skipSmallImages: map['skipSmallImages'] as bool? ?? true,
      minImageBytes: map['minImageBytes'] as int? ?? 10 * 1024,
      pngLevel: map['pngLevel'] as int? ?? 6,
    );
  }

  CompressionOptions copyWith({
    int? quality,
    bool? skipSmallImages,
    int? minImageBytes,
    int? pngLevel,
  }) {
    return CompressionOptions(
      quality: quality ?? this.quality,
      skipSmallImages: skipSmallImages ?? this.skipSmallImages,
      minImageBytes: minImageBytes ?? this.minImageBytes,
      pngLevel: pngLevel ?? this.pngLevel,
    );
  }
}

class CancellationToken {
  bool _isCancelled = false;
  final List<void Function()> _listeners = [];

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
    for (final listener in List<void Function()>.from(_listeners)) {
      listener();
    }
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw CompressionCancelled();
    }
  }

  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }
}

class CompressionProgress {
  CompressionProgress({
    required this.totalImages,
    required this.processedImages,
    required this.currentEntry,
  });

  final int totalImages;
  final int processedImages;
  final String currentEntry;

  double get percent => totalImages == 0 ? 1.0 : processedImages / totalImages;
}

class CompressionSummary {
  CompressionSummary({
    required this.outputPath,
    required this.totalImages,
    required this.processedImages,
    required this.savedBytes,
    required this.elapsed,
    required this.cancelled,
  });

  final String outputPath;
  final int totalImages;
  final int processedImages;
  final int savedBytes;
  final Duration elapsed;
  final bool cancelled;

  Map<String, dynamic> toMap() {
    return {
      'outputPath': outputPath,
      'totalImages': totalImages,
      'processedImages': processedImages,
      'savedBytes': savedBytes,
      'elapsedMs': elapsed.inMilliseconds,
      'cancelled': cancelled,
    };
  }

  factory CompressionSummary.fromMap(Map<String, dynamic> map) {
    return CompressionSummary(
      outputPath: map['outputPath'] as String? ?? '',
      totalImages: map['totalImages'] as int? ?? 0,
      processedImages: map['processedImages'] as int? ?? 0,
      savedBytes: map['savedBytes'] as int? ?? 0,
      elapsed: Duration(milliseconds: map['elapsedMs'] as int? ?? 0),
      cancelled: map['cancelled'] as bool? ?? false,
    );
  }
}

class CompressionCancelled implements Exception {
  @override
  String toString() => 'Compression cancelled';
}

class EpubCompressor {
  Future<CompressionSummary> compressEpubInIsolate({
    required String inputPath,
    required String outputDir,
    required CompressionOptions options,
    CancellationToken? cancelToken,
    void Function(String message)? onLog,
    void Function(CompressionProgress progress)? onProgress,
  }) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn<_IsolateParams>(
      _compressEpubIsolateEntry,
      _IsolateParams(
        sendPort: receivePort.sendPort,
        inputPath: inputPath,
        outputDir: outputDir,
        options: options.toMap(),
      ),
    );

    final completer = Completer<CompressionSummary>();
    SendPort? commandPort;
    void Function()? cancelListener;

    cancelListener = () {
      if (commandPort != null) {
        commandPort!.send({'type': 'cancel'});
      }
    };
    if (cancelToken != null && cancelListener != null) {
      cancelToken.addListener(cancelListener);
    }

    late StreamSubscription sub;
    sub = receivePort.listen((message) {
      if (message is! Map) return;
      switch (message['type']) {
        case 'ready':
          commandPort = message['commandPort'] as SendPort?;
          if (cancelToken?.isCancelled ?? false) {
            commandPort?.send({'type': 'cancel'});
          }
          break;
        case 'log':
          final text = message['message'] as String? ?? '';
          onLog?.call(text);
          break;
        case 'progress':
          final total = message['total'] as int? ?? 0;
          final processed = message['processed'] as int? ?? 0;
          final entry = message['entry'] as String? ?? '';
          onProgress?.call(CompressionProgress(
            totalImages: total,
            processedImages: processed,
            currentEntry: entry,
          ));
          break;
        case 'done':
          final summaryMap =
              (message['summary'] as Map?)?.cast<String, dynamic>() ?? {};
          completer.complete(CompressionSummary.fromMap(summaryMap));
          break;
        case 'cancelled':
          completer.completeError(CompressionCancelled());
          break;
        case 'error':
          completer
              .completeError(Exception(message['error'] ?? 'Unknown error'));
          break;
      }
    });

    try {
      final summary = await completer.future;
      return summary;
    } finally {
      if (cancelListener != null) {
        cancelToken?.removeListener(cancelListener);
      }
      isolate.kill(priority: Isolate.immediate);
      await sub.cancel();
      receivePort.close();
    }
  }

  Future<CompressionSummary> compressEpub({
    required String inputPath,
    required String outputDir,
    required CompressionOptions options,
    CancellationToken? cancelToken,
    void Function(String message)? onLog,
    void Function(CompressionProgress progress)? onProgress,
  }) async {
    return _compressEpubInternal(
      inputPath: inputPath,
      outputDir: outputDir,
      options: options,
      isCancelled: () => cancelToken?.isCancelled ?? false,
      onLog: onLog,
      onProgress: onProgress,
    );
  }

  bool _isImage(String ext) {
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png' || ext == '.webp';
  }

  int _countImages(Archive archive) {
    return archive.files
        .where((f) => f.isFile && _isImage(p.extension(f.name).toLowerCase()))
        .length;
  }

  Future<List<int>?> _compressBytes(
    List<int> bytes,
    String ext,
    CompressionOptions options,
  ) async {
    // Run the CPU-heavy decode/encode work on a helper isolate
    // so the UI isolate stays responsive while compressing many images.
    return Isolate.run(() {
      final image = img.decodeImage(Uint8List.fromList(bytes));
      if (image == null) return null;

      if (ext == '.png') {
        return img.encodePng(
          image,
          level: options.pngLevel.clamp(0, 9),
        );
      }

      return img.encodeJpg(
        image,
        quality: options.quality.clamp(1, 100),
      );
    });
  }

  String _buildOutputPath({
    required String inputPath,
    required String outputDir,
  }) {
    final fileName = p.basename(inputPath);
    return p.join(outputDir, fileName);
  }

  Future<CompressionSummary> _compressEpubInternal({
    required String inputPath,
    required String outputDir,
    required CompressionOptions options,
    required bool Function() isCancelled,
    void Function(String message)? onLog,
    void Function(CompressionProgress progress)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    if (isCancelled()) {
      throw CompressionCancelled();
    }

    final inputFile = File(inputPath);
    if (!await inputFile.exists()) {
      throw FileSystemException('EPUB file not found', inputPath);
    }

    final inputStream = InputFileStream(inputPath);
    final archive = ZipDecoder().decodeBuffer(
      inputStream,
      verify: false,
    );
    final totalImages = _countImages(archive);
    int processedImages = 0;
    int savedBytes = 0;

    Future<void> updateProgress(String entryName) async {
      processedImages = min(processedImages, totalImages);
      onProgress?.call(
        CompressionProgress(
          totalImages: totalImages,
          processedImages: processedImages,
          currentEntry: entryName,
        ),
      );
      await Future<void>.delayed(Duration.zero);
    }

    final outputPath = _buildOutputPath(
      inputPath: inputPath,
      outputDir: outputDir,
    );
    final outputFile = File(outputPath);
    await outputFile.parent.create(recursive: true);

    final outputStream = OutputFileStream(outputPath);
    final encoder = ZipEncoder();

    try {
      encoder.startEncode(outputStream, level: Deflate.BEST_SPEED);

      for (final file in archive) {
        if (isCancelled()) {
          throw CompressionCancelled();
        }

        if (!file.isFile) {
          encoder.addFile(file, autoClose: false);
          continue;
        }

        final ext = p.extension(file.name).toLowerCase();
        if (!_isImage(ext)) {
          encoder.addFile(file, autoClose: false);
          continue;
        }

        final originalSize = file.size;
        if (options.skipSmallImages && originalSize < options.minImageBytes) {
          processedImages++;
          await updateProgress(file.name);
          onLog?.call('Skip small image: ${file.name}');
          encoder.addFile(file, autoClose: false);
          continue;
        }

        if (ext == '.webp') {
          processedImages++;
          await updateProgress(file.name);
          onLog?.call('Keep WebP: ${file.name}');
          encoder.addFile(file, autoClose: false);
          continue;
        }

        try {
          final originalBytes = file.content as List<int>;
          final compressedBytes = await _compressBytes(
            originalBytes,
            ext,
            options,
          );

          List<int> bytesToStore = originalBytes;
          if (compressedBytes != null &&
              compressedBytes.length < originalBytes.length) {
            savedBytes += originalBytes.length - compressedBytes.length;
            bytesToStore = compressedBytes;
            onLog?.call(
              'Compressed: ${file.name} '
              '(${AppUtil.formatSize(originalBytes.length)} -> ${AppUtil.formatSize(compressedBytes.length)})',
            );
          } else {
            onLog?.call('Keep original: ${file.name}');
          }

          final optimizedFile = ArchiveFile(
            file.name,
            bytesToStore.length,
            bytesToStore,
          )
            ..mode = file.mode
            ..lastModTime = file.lastModTime
            ..isFile = file.isFile
            ..isSymbolicLink = file.isSymbolicLink
            ..nameOfLinkedFile = file.nameOfLinkedFile;

          encoder.addFile(optimizedFile, autoClose: true);
        } catch (e) {
          onLog?.call('Compress failed, keep original: ${file.name}: $e');
          encoder.addFile(file, autoClose: false);
        } finally {
          processedImages++;
          await updateProgress(file.name);
          file.clear();
        }
      }

      if (isCancelled()) {
        throw CompressionCancelled();
      }
      encoder.endEncode();
    } finally {
      await outputStream.close();
      await inputStream.close();
      archive.clear();
    }

    stopwatch.stop();
    onLog?.call('Output completed: $outputPath');
    return CompressionSummary(
      outputPath: outputPath,
      totalImages: totalImages,
      processedImages: processedImages,
      savedBytes: savedBytes,
      elapsed: stopwatch.elapsed,
      cancelled: isCancelled(),
    );
  }
}

class _IsolateParams {
  _IsolateParams({
    required this.sendPort,
    required this.inputPath,
    required this.outputDir,
    required this.options,
  });

  final SendPort sendPort;
  final String inputPath;
  final String outputDir;
  final Map<String, dynamic> options;
}

Future<void> _compressEpubIsolateEntry(_IsolateParams params) async {
  final sendPort = params.sendPort;
  final cancelPort = ReceivePort();
  var cancelled = false;

  cancelPort.listen((message) {
    if (message is Map && message['type'] == 'cancel') {
      cancelled = true;
    }
  });

  sendPort.send({'type': 'ready', 'commandPort': cancelPort.sendPort});

  final compressor = EpubCompressor();
  try {
    final summary = await compressor._compressEpubInternal(
      inputPath: params.inputPath,
      outputDir: params.outputDir,
      options: CompressionOptions.fromMap(params.options),
      isCancelled: () => cancelled,
      onLog: (msg) => sendPort.send({'type': 'log', 'message': msg}),
      onProgress: (progress) => sendPort.send({
        'type': 'progress',
        'total': progress.totalImages,
        'processed': progress.processedImages,
        'entry': progress.currentEntry,
      }),
    );
    sendPort.send({'type': 'done', 'summary': summary.toMap()});
  } on CompressionCancelled {
    sendPort.send({'type': 'cancelled'});
  } catch (e) {
    sendPort.send({'type': 'error', 'error': e.toString()});
  } finally {
    cancelPort.close();
  }
}
