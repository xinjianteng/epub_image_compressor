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

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void throwIfCancelled() {
    if (_isCancelled) {
      throw CompressionCancelled();
    }
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
}

class CompressionCancelled implements Exception {
  @override
  String toString() => 'Compression cancelled';
}

class EpubCompressor {
  Future<CompressionSummary> compressEpub({
    required String inputPath,
    required String outputDir,
    required CompressionOptions options,
    CancellationToken? cancelToken,
    void Function(String message)? onLog,
    void Function(CompressionProgress progress)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    cancelToken?.throwIfCancelled();

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
      // Yield to the event loop so UI can repaint during long batches.
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
        cancelToken?.throwIfCancelled();

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

      cancelToken?.throwIfCancelled();
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
      cancelled: cancelToken?.isCancelled ?? false,
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
}
