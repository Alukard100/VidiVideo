import 'package:flutter/material.dart';

import '../../../../core/network/media_url.dart';
import 'subscribed_button.dart';
import '../../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, 
    required this.profile,
    required this.isMyProfile,
    required this.isVisitingProfile,
    required this.isPreview,
    required this.onEditProfile,
    required this.onChangeAvatar,
    required this.onFollowersPressed,
    required this.onFollowingPressed,
    required this.onFollow,
    required this.onSubscribe,
    required this.onRefund,
    required this.onConnectPayPal,
  });

  final UserProfile profile;
  final bool isMyProfile;
  final bool isVisitingProfile;
  final bool isPreview;
  final VoidCallback onEditProfile;
  final VoidCallback onChangeAvatar;
  final VoidCallback onFollowersPressed;
  final VoidCallback onFollowingPressed;
  final VoidCallback onFollow;
  final VoidCallback onSubscribe;
  final VoidCallback onRefund;
  final VoidCallback onConnectPayPal;

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
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                      ),
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
                    children: [
                      Expanded(
                        child: _ProfileStat(
                          label: 'Followers',
                          value: profile.followersCount,
                          onTap: onFollowersPressed,
                        ),
                      ),
                      Expanded(
                        child: _ProfileStat(
                          label: 'Following',
                          value: profile.followingCount,
                          onTap: onFollowingPressed,
                        ),
                      ),
                      Expanded(
                        child: _ProfileStat(
                          label: 'Videos',
                          value: videoCount,
                        ),
                      ),
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
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ProfileActionButton(
                      label: 'Edit profile',
                      onPressed: onEditProfile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: _ProfileOutlinedButton(
                  label: profile.hasConnectedPayPal
                      ? 'PayPal connected'
                      : 'Connect PayPal',
                  icon: profile.hasConnectedPayPal
                      ? Icons.check_circle_outline
                      : Icons.account_balance_wallet_outlined,
                  onPressed: profile.hasConnectedPayPal
                      ? null
                      : onConnectPayPal,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: _ProfileActionButton(
                  label: profile.isFollowing ? 'Unfollow' : 'Follow',
                  onPressed: isPreview ? null : onFollow,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: profile.isSubscribed
                    ? SubscribedButton(
                      onPressed: isPreview ? null : onRefund,
                    )
                    : _ProfileActionButton(
                        label: 'Subscribe',
                        onPressed: isPreview ? null : onSubscribe,
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
    this.onTap,
  });

  final String label;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column( mainAxisSize: MainAxisSize.min,
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
        ),
      ),
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
  final VoidCallback? onPressed;

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

class _ProfileOutlinedButton extends StatelessWidget {
  const _ProfileOutlinedButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF020011),
          side: const BorderSide(
            color: Color(0xFF020011),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        icon: Icon(
          icon,
          size: 18,
        ),
        label: Text(label),
      ),
    );
  }
}