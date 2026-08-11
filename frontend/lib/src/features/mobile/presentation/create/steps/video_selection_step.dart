import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class VideoSelectionStep extends StatelessWidget {
  const VideoSelectionStep({
    super.key,
    required this.selectedVideo,
    required this.enabled,
    required this.onPickVideo,
    });

  final PlatformFile? selectedVideo;
  final bool enabled;
  final VoidCallback onPickVideo;

  @override
  Widget build(BuildContext context) {
    final hasVideo = selectedVideo != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      children: [
        const Text(
          'Upload Content',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Share your moments with the community',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF8A94A6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 54),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: enabled ? onPickVideo : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 310,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasVideo
                      ? const Color(0xFFFF2D95)
                      : const Color(0xFFD3D9E2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasVideo
                        ? Icons.check_circle_outline
                        : Icons.upload_outlined,
                    size: 48,
                    color: hasVideo
                        ? const Color(0xFFFF2D95)
                        : const Color(0xFF9CA6B8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasVideo
                        ? selectedVideo!.name
                        : 'Click to upload video',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF9CA6B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasVideo
                        ? 'Tap to choose another video'
                        : 'MP4, MOV, AVI (MAX. 500 MB)',
                    style: const TextStyle(
                      color: Color(0xFF8A94A6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}