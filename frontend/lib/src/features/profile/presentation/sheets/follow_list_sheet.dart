import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import '../../models/follow_user.dart';

class FollowListSheet extends StatelessWidget {
  const FollowListSheet({super.key, 
    required this.title,
    required this.usersFuture,
    required this.onUserPressed,
    required this.onFollowPressed,
    required this.allowFollowActions,
  });

  final String title;
  final Future<List<FollowUser>> usersFuture;
  final ValueChanged<FollowUser> onUserPressed;
  final ValueChanged<FollowUser> onFollowPressed;
  final bool allowFollowActions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .72,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                  ),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<FollowUser>>(
              future: usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  );
                }

                final users = snapshot.data ?? const [];

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      title == 'Followers' ? 'No followers yet.' : 'Not following anyone yet.',
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final avatarUrl = resolveMediaUrl(user.avatarUrl);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: () => onUserPressed(user),
                      leading: CircleAvatar(
                        backgroundImage: avatarUrl.isEmpty ? null : NetworkImage(avatarUrl),
                        child: avatarUrl.isEmpty
                            ? const Icon(Icons.person_outline)
                            : null,
                      ),
                      title: Text(
                        user.displayName.isEmpty ? 'User' : user.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: !allowFollowActions ? null : user.isFollowing
                        ? const SizedBox(
                            width: 80,
                            child: Center(
                              child: Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 34,
                            child: FilledButton(
                              onPressed: () => onFollowPressed(user),
                              child: const Text('Follow back'),
                            ),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

