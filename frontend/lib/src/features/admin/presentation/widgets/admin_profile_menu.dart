import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vidivideo_app/src/core/network/api_client.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/dependency/app_services.dart';
import '../../../../core/network/media_url.dart';
import '../../../profile/models/user_profile.dart';
import '../../../profile/presentation/sheets/change_password_sheet.dart';
import '../../../profile/presentation/sheets/edit_profile_sheet.dart';

class AdminProfileMenu extends StatefulWidget {
  const AdminProfileMenu({
    super.key,
  });

  @override
  State<AdminProfileMenu> createState() =>
      _AdminProfileMenuState();
}

class _AdminProfileMenuState
    extends State<AdminProfileMenu> {
  late Future<UserProfile> _profileFuture;

  @override
  void initState() {
    super.initState();

    _profileFuture =
        AppServices.profileService.getMyProfile();
  }

  void _refresh() {
    setState(() {
      _profileFuture =
          AppServices.profileService.getMyProfile();
    });
  }

  Future<void> _editProfile(
    UserProfile profile,
  ) async {
    final changed =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => EditProfileSheet(
        profile: profile,
      ),
    );

    if (changed == true) {
      _refresh();
    }
  }

  Future<void> _changePassword() async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          const ChangePasswordSheet(),
    );
  }

  Future<void> _logout() async {
    AppServices.sessionStore.clearSession();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  Future<void> _changeAvatar() async {
    try {
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
        _showMessage(
          'Unable to read the selected image.',
        );
        return;
      }

      if (file.size > 5 * 1024 * 1024) {
        _showMessage(
          'Avatar must not be larger than 5 MB.',
        );
        return;
      }

      await AppServices.profileService.uploadAvatar(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) {
        return;
      }

      _refresh();

      _showMessage(
        'Profile picture updated.',
      );
    } on ApiException catch (exception) {
      _showMessage(
        'Avatar update failed '
        '(${exception.statusCode}): '
        '${exception.message}',
      );
    } catch (exception) {
      debugPrint(
        'ADMIN AVATAR ERROR: $exception',
      );

      _showMessage(
        'Unable to update profile picture.',
      );
    }
  }

  Future<void> _showMenu(
    UserProfile profile,
  ) async {
    final action =
        await showMenu<_AdminProfileAction>(
      context: context,
      position: const RelativeRect.fromLTRB(
        20,
        500,
        250,
        80,
      ),
      items: const [
        PopupMenuItem(
          value: _AdminProfileAction.editProfile,
          child: ListTile(
            dense: true,
            leading:
                Icon(Icons.edit_outlined),
            title: Text('Edit profile'),
          ),
        ),
        PopupMenuItem(
          value: _AdminProfileAction.changeAvatar,
          child: ListTile(
            dense: true,
            leading: Icon(Icons.image_outlined,),
            title: Text('Change profile picture',),
          ),
        ),
        PopupMenuItem(
          value:
              _AdminProfileAction.changePassword,
          child: ListTile(
            dense: true,
            leading:
                Icon(Icons.lock_outline),
            title: Text('Change password'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _AdminProfileAction.logout,
          child: ListTile(
            dense: true,
            leading: Icon(
              Icons.logout,
              color: Color(0xFFDC2626),
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFDC2626),
              ),
            ),
          ),
        ),
      ],
    );

    switch (action) {
      case _AdminProfileAction.editProfile:
        await _editProfile(profile);
        break;

      case _AdminProfileAction.changeAvatar:
        await _changeAvatar();
        break;

      case _AdminProfileAction.changePassword:
        await _changePassword();
        break;

      case _AdminProfileAction.logout:
        await _logout();
        break;

      case null:
        break;
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
    return FutureBuilder<UserProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
                ConnectionState.waiting &&
            snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return const SizedBox.shrink();
        }

        final avatarUrl =
            resolveMediaUrl(profile.avatarUrl);

        final role =
            AppServices.sessionStore.role ?? '';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showMenu(profile),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 19,
                    backgroundImage:
                        avatarUrl.isEmpty
                            ? null
                            : NetworkImage(
                                avatarUrl,
                              ),
                    child: avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person_outline,
                          )
                        : null,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.displayName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _prettyRole(role),
                          style: const TextStyle(
                            fontSize: 11,
                            color:
                                Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _prettyRole(String role) {
    if (role.toLowerCase() ==
        'superadmin') {
      return 'Super Admin';
    }

    return role;
  }
}

enum _AdminProfileAction {
  editProfile,
  changeAvatar,
  changePassword,
  logout,
}