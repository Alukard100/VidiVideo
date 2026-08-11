import 'package:flutter/material.dart';

import '../../../../categories/models/category.dart';
import '../../../../videos/models/video_visibility.dart';

class VideoDetailsStep extends StatelessWidget {
  const VideoDetailsStep({
    super.key,
    required this.formKey,
    required this.captionController,
    required this.categories,
    required this.selectedCategory,
    required this.visibility,
    required this.isPublished,
    required this.enabled,
    required this.onCategoryChanged,
    required this.onVisibilityChanged,
    required this.onPublishedChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController captionController;

  final List<Category> categories;
  final Category? selectedCategory;

  final VideoVisibility visibility;
  final bool isPublished;
  final bool enabled;

  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<VideoVisibility> onVisibilityChanged;
  final ValueChanged<bool> onPublishedChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        children: [
          const Text(
            'Tell us about your video',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 20),
          TextFormField(
            controller: captionController,
            enabled: enabled,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(color: Colors.black45),
            decoration: InputDecoration(
              labelText: 'Caption',
              labelStyle: const TextStyle(color: Colors.black45),
              hintText: 'Write something about your video...',
              alignLabelWithHint: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black26,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Caption is required.';
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Category>(
            initialValue: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: const TextStyle(color: Colors.black45),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black26,
                  width: 1.5,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.black12,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),

              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            items: categories
                .map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name),
                  ),
                )
                .toList(),
            onChanged: enabled ? onCategoryChanged : null,
            validator: (value) {
              if (value == null) {
                return 'Please select a category.';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Visibility',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<VideoVisibility>(
            segments: const [
              ButtonSegment(
                value: VideoVisibility.public,
                icon: Icon(Icons.public),
                label: Text('Public'),
              ),
              ButtonSegment(
                value: VideoVisibility.subscribersOnly,
                icon: Icon(Icons.lock_outline),
                label: Text('Subscribers'),
              ),
            ],
            selected: {visibility},
            onSelectionChanged: enabled
                ? (selection) {
                    onVisibilityChanged(selection.first);
                  }
                : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.grey.shade800;
                  }
                  return Colors.grey.shade200;
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.black87;
                },
              ),
              side: WidgetStateProperty.all(
                const BorderSide(color: Colors.black12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: isPublished,
            onChanged: enabled ? onPublishedChanged : null,
            activeThumbColor: Color.fromARGB(255, 196, 62, 129),
            activeTrackColor: Colors.pink.shade200,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
            title: const Text(
              'Publish immediately',
              style: TextStyle(color: Colors.black),
            ),
            subtitle: const Text(
              'Turn this off to save the video as unpublished.',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}