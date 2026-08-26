import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'steps/thumbnail_selection_step.dart';
import 'steps/video_details_step.dart';
import 'steps/video_selection_step.dart';

import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/models/category.dart';
import '../../../videos/models/video_create_request.dart';
import '../../../videos/models/video_visibility.dart';

class CreateVideoPage extends StatefulWidget {
  final VoidCallback? onPublished;

  const CreateVideoPage({this.onPublished, super.key});

  @override
  State<CreateVideoPage> createState() => _CreateVideoPageState();
}

class _CreateVideoPageState extends State<CreateVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final PageController _pageController = PageController();

  final _videoService = AppServices.videoService;

  List<Category> _categories = [];
  Category? _selectedCategory;

  PlatformFile? _selectedVideo;
  Uint8List? _selectedThumbnailBytes;
  String? _selectedThumbnailName;

  VideoVisibility _visibility = VideoVisibility.public;

  int _currentStep = 0;

  bool _isPublished = true;
  bool _isUploading = false;
  bool _isGeneratingThumbnail = false;

  bool _hasConnectedPayPal = false;
  bool _isLoadingCreatorProfile = true;

  String? _uploadStage;

  @override
  void dispose() {
    AppServices.profileRefreshNotifier.removeListener(_loadCreatorProfile);

    _captionController.dispose(); 
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCreatorProfile();

    AppServices.profileRefreshNotifier.addListener(_loadCreatorProfile);
  }


  // ---------------------------------------------------------------------------
  // File selection
  // ---------------------------------------------------------------------------


  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true, // temporary until VideoService supports path/stream upload.
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.path == null) {
      _showMessage('Could not read the selected video.');
      return;
    }

    const maximumSize = 500 * 1024 * 1024;

    if (file.size > maximumSize) {
      _showMessage('Video must not be larger than 500 MB.');
      return;
    }

    setState(() {
      _selectedVideo = file;
      _selectedThumbnailBytes = null;
      _selectedThumbnailName = null;
    });
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    if (file.bytes == null) {
      _showMessage('Could not read the selected thumbnail.');
      return;
    }

    const maximumSize = 5 * 1024 * 1024;

    if (file.size > maximumSize) {
      _showMessage('Thumbnail must not be larger than 5 MB.');
      return;
    }

    setState(() {
      _selectedThumbnailBytes = file.bytes;
      _selectedThumbnailName = file.name;
    });
  }



  // ---------------------------------------------------------------------------
  // Thumbnail generation
  // ---------------------------------------------------------------------------

  Future<void> _generateThumbnailAt(Duration position) async {
    final videoPath = _selectedVideo?.path;

    if (videoPath == null) {
      _showMessage('Video path is unavailable.');
      return;
    }

    setState(() {
      _isGeneratingThumbnail = true;
    });

    try {
      final bytes = await VideoThumbnail.thumbnailData(
        video: videoPath,
        timeMs: position.inMilliseconds,
        maxWidth: 720,
        quality: 85,
      );

      if (!mounted) {
        return;
      }

      if(bytes.isEmpty) {
        _showMessage('Could not generate video cover.');
        return;
      }

      setState(() {
        _selectedThumbnailBytes = bytes;
        _selectedThumbnailName = 'video-cover.jpg';
      });
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Could not generate video cover: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingThumbnail = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Categories & Creator Profile
  // ---------------------------------------------------------------------------

  Future<void> _loadCategories() async {
    try {
      final categories = await AppServices.categoryService.getAll();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
      });
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to load categories (${exception.statusCode}): ${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unexpected error while loading categories: $exception',
      );
    }
  }

  Future<void> _loadCreatorProfile() async {
    try {
      final profile = await AppServices.profileService.getMyProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _hasConnectedPayPal =
            profile.hasConnectedPayPal;

        _isLoadingCreatorProfile = false;
      });

    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasConnectedPayPal = false;
        _isLoadingCreatorProfile = false;
      });
    }
  }
  // ---------------------------------------------------------------------------
  // Step navigation
  // ---------------------------------------------------------------------------

  Future<void> _nextStep() async {
    if (_currentStep >= 2) {
      await _publish();
      return;
    }

    setState(() {
      _currentStep++;
    });

    await _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  bool _canContinue() {
    switch (_currentStep) {
      case 0:
        return _selectedVideo != null;

      case 1:
        return _selectedThumbnailBytes != null;

      case 2:
        return true;

      default:
        return false;
    }
  }

  Future<void> _previousStep() async {
    if (_currentStep <= 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });

    await _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ---------------------------------------------------------------------------
  // Publishing
  // ---------------------------------------------------------------------------

  Future<void> _publish() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final selectedVideo = _selectedVideo;
    final thumbnailBytes = _selectedThumbnailBytes;
    final thumbnailName = _selectedThumbnailName;
    final selectedCategory = _selectedCategory;

    if (selectedVideo == null) {
      _showMessage('Please select a video.');
      return;
    }

    if (selectedVideo.bytes == null) {
      _showMessage('Could not read the selected video.');
      return;
    }

    if (thumbnailBytes == null || thumbnailName == null) {
      _showMessage('Please select a thumbnail.');
      return;
    }

    if (selectedCategory == null) {
      _showMessage('Please select a category.');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStage = 'Uploading video...';
    });

    try {
      final videoUrl = await _videoService.uploadVideo(
        bytes: selectedVideo.bytes!,
        fileName: selectedVideo.name,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _uploadStage = 'Uploading thumbnail...';
      });

      final thumbnailUrl = await _videoService.uploadThumbnail(
        bytes: thumbnailBytes,
        fileName: thumbnailName,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _uploadStage = 'Creating video...';
      });

      final request = VideoCreateRequest(
        categoryId: selectedCategory.id,
        caption: _captionController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        visibility: _visibility,
        isPublished: _isPublished,
      );

      final videoId = await _videoService.createVideo(request);

      if (!mounted) {
        return;
      }

      debugPrint('Created video ID: $videoId');

      AppServices.profileRefreshNotifier.refresh();

      _showMessage(
        'Video published successfully.',
      );
      _resetForm();
      widget.onPublished?.call();
    } on ApiException catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Upload failed (${exception.statusCode}): ${exception.message}',
      );
    } catch (exception) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unexpected error: $exception',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadStage = null;
        });
      }
    }
  }

  void _resetForm() {
    _captionController.clear();

    setState(() {
      _selectedVideo = null;

      _selectedThumbnailBytes = null;
      _selectedThumbnailName = null;

      _selectedCategory = null;

      _visibility = VideoVisibility.public;
      _isPublished = true;
      _currentStep = 0;
    });

    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
  }  
  
  // ---------------------------------------------------------------------------
  // Shared UI
  // ---------------------------------------------------------------------------  

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Widget _buildHeader() {
      const titles = [
      'Create',
      'Choose cover',
      'Video details',
    ];

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              onPressed: _isUploading ? null : _previousStep,
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              titles[_currentStep],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _isUploading
                ? null
                : () {
                    _resetForm();
                    Navigator.of(context).maybePop();
                  },
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _currentStep == 2;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isUploading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                _uploadStage ?? 'Uploading...',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF2D95),
                  foregroundColor: Colors.white, 
                  disabledBackgroundColor: const Color(0xFF374151), 
                  disabledForegroundColor: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: _canContinue() && !_isUploading
                    ? _nextStep
                    : null,
                child: Text(
                  isLastStep
                      ? _isUploading
                          ? 'Publishing...'
                          : 'Publish'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  VideoSelectionStep(
                    selectedVideo: _selectedVideo,
                    enabled: !_isUploading,
                    onPickVideo: _pickVideo,
                  ),
                  ThumbnailSelectionStep(
                    thumbnailBytes: _selectedThumbnailBytes,
                    isGenerating: _isGeneratingThumbnail,
                    onGenerateThumbnail: () {
                      _generateThumbnailAt(
                        const Duration(seconds: 1),
                      );
                    },
                    onUploadThumbnail: _pickThumbnail,
                  ),
                  VideoDetailsStep(
                    formKey: _formKey,
                    captionController: _captionController,
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    visibility: _visibility,
                    isPublished: _isPublished,
                    enabled: !_isUploading,
                    canCreateSubscriberContent: _hasConnectedPayPal && !_isLoadingCreatorProfile,
                    onCategoryChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    onVisibilityChanged: (visibility) {
                      setState(() {
                        _visibility = visibility;
                      });
                    },
                    onPublishedChanged: (value) {
                      setState(() {
                        _isPublished = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

}
