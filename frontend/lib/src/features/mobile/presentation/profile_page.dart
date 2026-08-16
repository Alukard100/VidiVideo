import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../../countries/models/country.dart';
import '../../profile/models/profile_video.dart';
import '../../profile/models/user_profile.dart';
import '../../videos/widgets/video_thumbnail_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    this.userId,
    super.key,
  });

  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _profileService = AppServices.profileService;

  late Future<UserProfile> _profileFuture;
  bool _showPublicPreview = false;

  bool get _isMyProfile => widget.userId == null && !_showPublicPreview;
  bool get _isVisitingProfile => widget.userId != null || _showPublicPreview;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();

    AppServices.profileRefreshNotifier.addListener(_refreshProfile);
  }

  @override
    void dispose() {
    AppServices.profileRefreshNotifier.removeListener(_refreshProfile);
    super.dispose();
  }

  Future<UserProfile> _loadProfile() {
    final userId = widget.userId;

    if (userId == null || _showPublicPreview) {
      return _profileService.getMyProfile();
    }

    return _profileService.getProfile(userId);
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      _showMessage('Could not read the selected avatar.');
      return;
    }

    const maximumSize = 5 * 1024 * 1024;

    if (file.size > maximumSize) {
      _showMessage('Avatar must not be larger than 5 MB.');
      return;
    }

    try {
      await _profileService.uploadAvatar(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Avatar updated.');
      _refreshProfile();
    } on ApiException catch (exception) {
      _showMessage('Avatar upload failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Avatar upload failed: $exception');
    }
  }

  Future<void> _openEditProfile(UserProfile profile) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _EditProfileSheet(profile: profile);
      },
    );

    if (updated == true) {
      _refreshProfile();
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            elevation: 0,
            centerTitle: false,
            leading: Navigator.of(context).canPop()
            ? IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
            )
            : null,
            title: Text(
              profile?.userName ?? (_isMyProfile ? 'my profile' : 'profile'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (widget.userId == null)
                IconButton(
                  tooltip: _showPublicPreview ? 'Show editable profile' : 'Preview public profile',
                  onPressed: () {
                    setState(() {
                      _showPublicPreview = !_showPublicPreview;
                      _profileFuture = _loadProfile();
                    });
                  },
                  icon: Icon(_showPublicPreview ? Icons.edit_outlined : Icons.visibility_outlined),
                ),
            ],
          ),
          body: _buildBody(snapshot),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<UserProfile> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return _ProfileError(
        message: snapshot.error.toString(),
        onRetry: _refreshProfile,
      );
    }

    final profile = snapshot.data;

    if (profile == null) {
      return _ProfileError(
        message: 'Profile could not be loaded.',
        onRetry: _refreshProfile,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshProfile(),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                children: [
                  _ProfileHeader(
                    profile: profile,
                    isMyProfile: _isMyProfile,
                    isVisitingProfile: _isVisitingProfile,
                    isPreview: _showPublicPreview,
                    onEditProfile: () => _openEditProfile(profile),
                    onChangeAvatar: _pickAvatar,
                    onFollow: () => _showMessage('Follow action will be connected to Follow API.'),
                    onSubscribe: () => _showMessage('Subscription checkout will be connected here.'),
                  ),
                  const SizedBox(height: 16),
                  _ProfileTabs(
                    publicVideos: profile.publicVideos,
                    subscriberOnlyVideos: profile.subscriberOnlyVideos,
                    forceSubscriberLocks: _isVisitingProfile && !profile.isSubscribed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.isMyProfile,
    required this.isVisitingProfile,
    required this.isPreview,
    required this.onEditProfile,
    required this.onChangeAvatar,
    required this.onFollow,
    required this.onSubscribe,
  });

  final UserProfile profile;
  final bool isMyProfile;
  final bool isVisitingProfile;
  final bool isPreview;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeAvatar;
  final VoidCallback onFollow;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.displayName.isEmpty ? profile.userName : profile.displayName;
    final videoCount = profile.publicVideos.length + profile.subscriberOnlyVideos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                _ProfileAvatar(avatarUrl: profile.avatarUrl),
                if (isMyProfile)
                  SizedBox(
                    height: 34,
                    width: 34,
                    child: IconButton.filled(
                      tooltip: 'Change avatar',
                      padding: EdgeInsets.zero,
                      onPressed: onChangeAvatar,
                      iconSize: 18,
                      icon: const Icon(Icons.camera_alt_outlined),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ProfileStat(label: 'Followers', value: profile.followersCount),
                      _ProfileStat(label: 'Following', value: profile.followingCount),
                      _ProfileStat(label: 'Videos', value: videoCount),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _buildBioText(profile),
          style: const TextStyle(
            color: Color(0xFF374151),
            height: 1.35,
            fontSize: 14,
          ),
        ),
        if (isMyProfile && (profile.email ?? '').isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            profile.email!,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 14,
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (isMyProfile)
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'Edit profile',
                  onPressed: onEditProfile,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: 'Follow',
                  onPressed: onFollow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileActionButton(
                  label: 'Subscribe',
                  onPressed: onSubscribe,
                ),
              ),
            ],
          ),
        if (isPreview) ...[
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Public preview',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ),
        ],
      ],
    );
  }

  String _buildBioText(UserProfile profile) {
    final bio = profile.bio?.trim();

    if (bio != null && bio.isNotEmpty) {
      return bio;
    }

    return 'No bio yet.';
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.avatarUrl});

  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = resolveMediaUrl(avatarUrl);

    return CircleAvatar(
      radius: 42,
      backgroundColor: const Color(0xFFE5E7EB),
      backgroundImage: url.isEmpty ? null : NetworkImage(url),
      child: url.isEmpty
          ? const Icon(
              Icons.person_rounded,
              color: Color(0xFF6B7280),
              size: 46,
            )
          : null,
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          _compactNumber(value),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _compactNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF020011),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs({
    required this.publicVideos,
    required this.subscriberOnlyVideos,
    required this.forceSubscriberLocks,
  });

  final List<ProfileVideo> publicVideos;
  final List<ProfileVideo> subscriberOnlyVideos;
  final bool forceSubscriberLocks;

  @override
  Widget build(BuildContext context) {
    final tabHeight = _gridHeightFor(
      publicVideos.length > subscriberOnlyVideos.length
          ? publicVideos.length
          : subscriberOnlyVideos.length,
    );

    return Column(
      children: [
        const TabBar(
          indicatorColor: Color(0xFF111827),
          labelColor: Color(0xFF111827),
          unselectedLabelColor: Color(0xFF374151),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: [
            Tab(
              icon: Icon(Icons.grid_on_rounded, size: 17),
              text: 'Videos',
            ),
            Tab(
              icon: Icon(Icons.workspace_premium_outlined, size: 17),
              text: 'Subscribers Only',
            ),
          ],
        ),
        SizedBox(
          height: tabHeight,
          child: TabBarView(
            children: [
              _VideoGrid(
                videos: publicVideos,
                emptyMessage: 'No public videos yet.',
              ),
              _VideoGrid(
                videos: subscriberOnlyVideos,
                emptyMessage: 'No subscriber-only videos yet.',
                forceLocked: forceSubscriberLocks,
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _gridHeightFor(int itemCount) {
    final rows = itemCount == 0 ? 1 : ((itemCount + 2) / 3).ceil();
    return rows * 162 + (rows - 1) * 4;
  }
}

class _VideoGrid extends StatelessWidget {
  const _VideoGrid({
    required this.videos,
    required this.emptyMessage,
    this.forceLocked = false,
  });

  final List<ProfileVideo> videos;
  final String emptyMessage;
  final bool forceLocked;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return _EmptyVideoStrip(message: emptyMessage);
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 9 / 14,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final video = videos[index];

        return VideoThumbnailTile(
          video: video,
          forceLocked: forceLocked,
          onTap: () {
            Navigator.of(context).pushNamed(
              AppRoutes.videoViewer,
              arguments: VideoViewerRouteArguments(videoId: video.id),
            );
          },
        );
      },
    );
  }
}

class _EmptyVideoStrip extends StatelessWidget {
  const _EmptyVideoStrip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late Future<List<Country>> _countriesFuture;
  String? _selectedCountryId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.profile.displayName);
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _selectedCountryId = widget.profile.countryId;
    _countriesFuture = AppServices.countryService.getAll();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await AppServices.profileService.updateMyProfile(
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        countryId: _selectedCountryId,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } on ApiException catch (exception) {
      _showMessage('Profile update failed (${exception.statusCode}): ${exception.message}');
    } catch (exception) {
      _showMessage('Profile update failed: $exception');
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
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                  'Edit profile',
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
              controller: _displayNameController,
              enabled: !_isSaving,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (text.isEmpty) {
                  return 'Display name is required.';
                }

                if (text.length > 100) {
                  return 'Display name must not be longer than 100 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Country>>(
              future: _countriesFuture,
              builder: (context, snapshot) {
                final countries = snapshot.data ?? const <Country>[];

                return DropdownButtonFormField<String?>(
                  initialValue: _selectedCountryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Country'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('No country selected'),
                    ),
                    for (final country in countries)
                      DropdownMenuItem<String?>(
                        value: country.id,
                        child: Text(
                          country.code.isEmpty
                              ? country.name
                              : '${country.name} (${country.code})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _isSaving || snapshot.connectionState == ConnectionState.waiting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedCountryId = value;
                          });
                        },
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              enabled: !_isSaving,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Bio'),
              validator: (value) {
                final text = value?.trim() ?? '';

                if (text.length > 500) {
                  return 'Bio must not be longer than 500 characters.';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
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
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFF6B7280), size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF374151)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
