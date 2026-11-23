import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Abstract service for sharing exported Muggu art.
abstract class ShareService {
  Future<void> sharePng({
    required Uint8List pngBytes,
    required String filename,
    required String title,
    String? text,
    Rect? sharePositionOrigin,
  });
}

/// Android/iOS native share sheet implementation via [share_plus] and [path_provider].
///
/// Writes image bytes to the application's temporary cache directory (`cacheDir`),
/// which does NOT require broad external storage permissions on Android.
class PlatformShareService implements ShareService {
  const PlatformShareService();

  @override
  Future<void> sharePng({
    required Uint8List pngBytes,
    required String filename,
    required String title,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final sanitized = filename.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final filePath = '${tempDir.path}/$sanitized.png';
    final file = File(filePath);
    await file.writeAsBytes(pngBytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'image/png', name: '$sanitized.png')],
        subject: title,
        text: text ?? title,
        sharePositionOrigin: sharePositionOrigin,
      ),
    );
  }
}

/// Provider for [ShareService].
final shareServiceProvider = Provider<ShareService>((ref) {
  return const PlatformShareService();
});
