import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../../../shared/models/paged_result.dart';
import '../models/channel_emoji.dart';

class ChannelEmojisSheet extends StatefulWidget {
  const ChannelEmojisSheet({super.key});

  @override
  State<ChannelEmojisSheet> createState() =>
      _ChannelEmojisSheetState();
}

class _ChannelEmojisSheetState
    extends State<ChannelEmojisSheet> {
  final _emojiService = AppServices.emojiService;

  late Future<PagedResult<ChannelEmoji>> _emojisFuture;

  bool _isUploading = false;
  String? _deletingEmojiId;

  static const int _maximumEmojiCount = 3;

  @override
  void initState() {
    super.initState();
    _emojisFuture = _emojiService.getMine();
  }

  void _refresh() {
    setState(() {
      _emojisFuture = _emojiService.getMine();
    });
  }

  Future<void> _openUploadDialog() async {
    final result = await showDialog<_EmojiUploadData>(
      context: context,
      builder: (_) => const _UploadEmojiDialog(),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _emojiService.uploadEmoji(
        code: result.code,
        bytes: result.bytes,
        fileName: result.fileName,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Emoji uploaded successfully.');
      _refresh();
    } on ApiException catch (exception) {
      AppServices.errorHandler.showApiException(
        exception,
        title: 'Emoji upload failed',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Emoji upload failed: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteEmoji(
    ChannelEmoji emoji,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete emoji?'),
          content: Text(
            'Are you sure you want to delete :${emoji.code}:?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _deletingEmojiId = emoji.id;
    });

    try {
      await _emojiService.deleteEmoji(
        emoji.id,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Emoji deleted.');
      _refresh();
    } on ApiException catch (exception) {
      AppServices.errorHandler.showApiException(
        exception,
        title: 'Emoji delete failed',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Emoji delete failed: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _deletingEmojiId = null;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .78,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
              child: FutureBuilder<PagedResult<ChannelEmoji>>(
              future: _emojisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _buildError(
                    snapshot.error.toString(),
                  );
                }

                final result = snapshot.data;

                if (result == null) {
                  return const SizedBox.shrink();
                }

                return _buildContent(result);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        8,
        10,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Channel emojis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    PagedResult<ChannelEmoji> result,
  ) {
    final emojis = result.items;
    
    final canUpload = result.totalCount < _maximumEmojiCount;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        28,
      ),
      children: [
        const Text(
          'Create up to 3 custom emojis for your channel.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 18),

        for (final emoji in emojis) ...[
          _buildEmojiCard(emoji),
          const SizedBox(height: 12),
        ],

        if (canUpload)
          _buildUploadCard(),

        if (!canUpload) ...[
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'You have reached the maximum of 3 emojis.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmojiCard(
    ChannelEmoji emoji,
  ) {
    final imageUrl =
        resolveMediaUrl(emoji.imageUrl);

    final isDeleting =
        _deletingEmojiId == emoji.id;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: Colors.black12,
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(13),
              child: imageUrl.isEmpty
                  ? const Icon(
                      Icons.emoji_emotions_outlined,
                      size: 34,
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image_outlined,
                          size: 30,
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  ':${emoji.code}:',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Channel emoji',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          TextButton.icon(
            onPressed: isDeleting ||
                    _isUploading
                ? null
                : () => _deleteEmoji(emoji),
            icon: isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.delete_outline,
                  ),
            label: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadCard() {
    return InkWell(
      onTap: _isUploading
          ? null
          : _openUploadDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black26,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: _isUploading
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.add_rounded,
                      size: 36,
                    ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _isUploading
                        ? 'Uploading...'
                        : 'Upload emoji',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a custom image and code.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _refresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadEmojiDialog
    extends StatefulWidget {
  const _UploadEmojiDialog();

  @override
  State<_UploadEmojiDialog> createState() =>
      _UploadEmojiDialogState();
}

class _UploadEmojiDialogState
    extends State<_UploadEmojiDialog> {
  final _formKey =
      GlobalKey<FormState>();

  final _codeController =
      TextEditingController();

  Uint8List? _imageBytes;
  String? _fileName;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.bytes == null) {
      return;
    }

    const maximumSize =
        5 * 1024 * 1024;

    if (file.size > maximumSize) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Emoji image must not be larger than 5 MB.',
            ),
          ),
        );

      return;
    }

    setState(() {
      _imageBytes = file.bytes;
      _fileName = file.name;
    });
  }

  void _submit() {
    if (_formKey.currentState
            ?.validate() !=
        true) {
      return;
    }

    final bytes = _imageBytes;
    final fileName = _fileName;

    if (bytes == null ||
        fileName == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Please select an emoji image.',
            ),
          ),
        );

      return;
    }

    Navigator.of(context).pop(
      _EmojiUploadData(
        code:
            _codeController.text.trim(),
        bytes: bytes,
        fileName: fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Upload emoji',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius:
                    BorderRadius.circular(16),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color:
                        Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(
                            16),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: _imageBytes == null
                      ? const Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons
                                  .add_photo_alternate_outlined,
                              size: 34,
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Select image',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.contain,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller:
                    _codeController,
                maxLength: 32,
                decoration:
                    const InputDecoration(
                  labelText: 'Emoji code',
                  hintText: 'Wow',
                  prefixText: ':',
                  suffixText: ':',
                ),
                validator: (value) {
                  final code =
                      value?.trim() ?? '';

                  if (code.isEmpty) {
                    return 'Emoji code is required.';
                  }

                  final validCode =
                      RegExp(
                    r'^[A-Za-z0-9_]+$',
                  );

                  if (!validCode
                      .hasMatch(code)) {
                    return 'Use only letters, numbers and _.';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Upload'),
        ),
      ],
    );
  }
}

class _EmojiUploadData {
  const _EmojiUploadData({
    required this.code,
    required this.bytes,
    required this.fileName,
  });

  final String code;
  final Uint8List bytes;
  final String fileName;
}
