import 'dart:typed_data';

import 'package:flutter/material.dart';

class ThumbnailSelectionStep extends StatelessWidget {
  const ThumbnailSelectionStep({
    super.key,
    required this.thumbnailBytes,
    required this.isGenerating,
    required this.onGenerateThumbnail,
    required this.onUploadThumbnail,
  });

  final Uint8List? thumbnailBytes;
  final bool isGenerating;
  final VoidCallback onGenerateThumbnail;
  final VoidCallback onUploadThumbnail;

  

   @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        children: [
          const Text(
            'Choose a cover for your video',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use a frame from your video or upload your own image.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8B95A5),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 26),

          Center(
            child: Container(
              width: 180,
              height: 320,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFD4D9E1),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: thumbnailBytes == null
                  ? const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 44,
                        color: Color(0xFF98A2B3),
                      ),
                    )
                  : Image.memory(
                      thumbnailBytes!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          const SizedBox(height: 26),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed:
                  isGenerating ? null : onGenerateThumbnail,
              icon: isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.movie_filter_outlined),
              label: Text(
                isGenerating
                    ? 'Generating...'
                    : 'Use frame from video',
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onUploadThumbnail,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Upload custom cover'),
            ),
          ),
        ],
      ),
    );
  }
}