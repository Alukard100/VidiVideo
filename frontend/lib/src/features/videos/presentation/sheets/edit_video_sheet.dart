import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/models/category.dart';
import '../../models/video_detail.dart';
import '../../models/video_visibility.dart';

class EditVideoSheet extends StatefulWidget {
  const EditVideoSheet({required this.video, super.key});

  final VideoDetail video;

  @override
  State<EditVideoSheet> createState() => _EditVideoSheetState();
}

class _EditVideoSheetState extends State<EditVideoSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _captionController;
  late Future<List<Category>> _categoriesFuture;
  String? _selectedCategoryId;
  late VideoVisibility _visibility;
  late bool _isPublished;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.video.caption);
    _selectedCategoryId = widget.video.categoryId.isEmpty ? null : widget.video.categoryId;
    _visibility = _readVisibility(widget.video.visibility);
    _isPublished = widget.video.isPublished;
    _categoriesFuture = AppServices.categoryService.getAll();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true || _selectedCategoryId == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AppServices.videoService.updateVideo(
        videoId: widget.video.id,
        categoryId: _selectedCategoryId!,
        caption: _captionController.text.trim(),
        thumbnailUrl: widget.video.thumbnailUrl,
        visibility: _visibility.value,
        isPublished: _isPublished,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        Navigator.of(context).pushNamed(AppRoutes.register);
        return;
      }

      _showMessage('Video update failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Video update failed: $exception');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Edit video',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _captionController,
              enabled: !_isSaving,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(labelText: 'Caption'),
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Caption is required.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                final categories = snapshot.data ?? const <Category>[];
                final selectedCategoryId = categories.any(
                  (category) => category.id == _selectedCategoryId,
                )
                    ? _selectedCategoryId
                    : null;

                return DropdownButtonFormField<String>(
                  initialValue: selectedCategoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: _isSaving || snapshot.connectionState == ConnectionState.waiting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required.';
                    }

                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 14),
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
              selected: {_visibility},
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) {
                      setState(() {
                        _visibility = selection.first;
                      });
                    },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isPublished,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
              title: const Text('Published'),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }

  VideoVisibility _readVisibility(String value) {
    final normalized = value.toLowerCase();

    if (normalized == '2' || normalized.contains('subscriber')) {
      return VideoVisibility.subscribersOnly;
    }

    return VideoVisibility.public;
  }
}

