enum AdminUserSort {
  userName,
  registrationDate,
  videoCount,
  followersCount,
  status,
}

extension AdminUserSortApi on AdminUserSort {
  String get apiValue {
    switch (this) {
      case AdminUserSort.userName:
        return 'UserName';
      case AdminUserSort.registrationDate:
        return 'RegistrationDate';
      case AdminUserSort.videoCount:
        return 'VideoCount';
      case AdminUserSort.followersCount:
        return 'FollowersCount';
      case AdminUserSort.status:
        return 'Status';
    }
  }
}

enum AdminUserStatusFilter {
  all,
  active,
  suspended,
  deleted,
}

extension AdminUserStatusFilterApi on AdminUserStatusFilter {
  int? get apiValue {
    switch (this) {
      case AdminUserStatusFilter.all:
        return null;
      case AdminUserStatusFilter.active:
        return 1;
      case AdminUserStatusFilter.suspended:
        return 2;
      case AdminUserStatusFilter.deleted:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case AdminUserStatusFilter.all:
        return 'All Status';
      case AdminUserStatusFilter.active:
        return 'Active';
      case AdminUserStatusFilter.suspended:
        return 'Suspended';
      case AdminUserStatusFilter.deleted:
        return 'Deleted';
    }
  }
}