import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../models/admin_staff_member.dart';
import 'admin_navigation.dart';
import 'dialogs/add_staff_dialog.dart';
import 'dialogs/edit_staff_role_dialog.dart';
import 'widgets/admin_profile_menu.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({
    super.key,
  });

  @override
  State<StaffManagementPage> createState() =>
      _StaffManagementPageState();
}

class _StaffManagementPageState
    extends State<StaffManagementPage> {
  late Future<List<AdminStaffMember>> _staffFuture;

  String get _myRole =>
      AppServices.sessionStore.role ?? '';

  bool get _isSuperAdmin =>
      _myRole.toLowerCase() == 'super admin';

  bool get _isAdmin =>
      _myRole.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();

    _staffFuture =
        AppServices.adminStaffService.getStaff();
  }

  void _refresh() {
    setState(() {
      _staffFuture =
          AppServices.adminStaffService.getStaff();
    });
  }

  Future<void> _addMember() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddStaffDialog(
        isSuperAdmin: _isSuperAdmin,
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _editMember(
    AdminStaffMember member,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditStaffRoleDialog(
        member: member,
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _removeMember(
    AdminStaffMember member,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Team Member?',
          ),
          content: Text(
            '${member.displayName} will be removed '
            'from the staff team.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext)
                      .pop(true),
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await AppServices.adminStaffService
          .removeStaff(member.id);

      _refresh();
    } on ApiException catch (exception) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Unable to remove member '
              '(${exception.statusCode}): '
              '${exception.message}',
            ),
          ),
        );
    }
  }

  bool _canDelete(
    AdminStaffMember member,
  ) {
    final targetRole =
        member.role.toLowerCase();

    if (targetRole == 'super admin') {
      return false;
    }

    if (_isSuperAdmin) {
      return true;
    }

    if (_isAdmin &&
        targetRole == 'moderator') {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Admin Management',
      navigationItems:
          adminNavigationItems(
        AppRoutes.adminStaff,
      ),
      navigationFooter: const AdminProfileMenu(),

      body: Container(
        color: const Color(0xFFF8F9FB),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Management',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage dashboard access and staff roles.',
                        style: TextStyle(
                          color:
                              Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_isSuperAdmin || _isAdmin)
                  FilledButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(
                      Icons.person_add_alt_1_outlined,
                    ),
                    label: const Text(
                      'Add Team Member',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            FutureBuilder<List<AdminStaffMember>>(
              future: _staffFuture,
              builder: (context, snapshot) {
                final staff =
                    snapshot.data ??
                        const <AdminStaffMember>[];

                return Column(
                  children: [
                    _buildStats(staff),

                    const SizedBox(height: 20),

                    _buildTeamCard(
                      snapshot,
                      staff,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(
    List<AdminStaffMember> staff,
  ) {
    final superAdmins = staff
        .where(
          (x) =>
              x.role.toLowerCase() ==
              'super admin',
        )
        .length;

    final admins = staff
        .where(
          (x) =>
              x.role.toLowerCase() ==
              'admin',
        )
        .length;

    final moderators = staff
        .where(
          (x) =>
              x.role.toLowerCase() ==
              'moderator',
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            title: 'Super Admins',
            value: superAdmins,
            subtitle: 'Full system access',
            icon: Icons.workspace_premium_outlined,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _RoleCard(
            title: 'Admins',
            value: admins,
            subtitle: 'Management access',
            icon:
                Icons.shield_outlined,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _RoleCard(
            title: 'Moderators',
            value: moderators,
            subtitle: 'Content moderation',
            icon:
                Icons.group_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(
    AsyncSnapshot<List<AdminStaffMember>>
        snapshot,
    List<AdminStaffMember> staff,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Team Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 16),

            if (snapshot.connectionState ==
                ConnectionState.waiting)
              const SizedBox(
                height: 220,
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )
            else if (snapshot.hasError)
              SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.error is ApiException
                            ? (snapshot.error
                                    as ApiException)
                                .message
                            : 'Unable to load staff.',
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(
                          Icons.refresh,
                        ),
                        label:
                            const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (staff.isEmpty)
              const SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'No staff members.',
                  ),
                ),
              )
            else
              _buildTable(staff),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(
    List<AdminStaffMember> staff,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth:
                  constraints.maxWidth,
            ),
            child: DataTable(
              headingRowColor:
                  const WidgetStatePropertyAll(
                Color(0xFFF9FAFB),
              ),
              dataRowMinHeight: 62,
              dataRowMaxHeight: 72,
              columns: const [
                DataColumn(
                  label: Text('Member'),
                ),
                DataColumn(
                  label: Text('Role'),
                ),
                DataColumn(
                  label:
                      Text('Permissions'),
                ),
                DataColumn(
                  label:
                      Text('Joined Date'),
                ),
                DataColumn(
                  label: Text('Actions'),
                ),
              ],
              rows: [
                for (final member in staff)
                  _staffRow(member),
              ],
            ),
          ),
        );
      },
    );
  }

  DataRow _staffRow(
    AdminStaffMember member,
  ) {
    final avatarUrl =
        resolveMediaUrl(
      member.avatarUrl,
    );

    final isSuperAdminTarget =
        member.role.toLowerCase() ==
            'super admin';

    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundImage:
                    avatarUrl.isEmpty
                        ? null
                        : NetworkImage(
                            avatarUrl,
                          ),
                child: avatarUrl.isEmpty
                    ? Text(
                        _initials(
                          member.displayName,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 10),

              Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  Text(
                    member.email,
                    style: const TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        DataCell(
          _roleBadge(member.role),
        ),

        DataCell(
          _permissions(member.role),
        ),

        DataCell(
          Text(
            _formatDate(
              member.createdAtUtc,
            ),
          ),
        ),

        DataCell(
          Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (_isSuperAdmin &&
                  !isSuperAdminTarget)
                IconButton(
                  tooltip: 'Edit role',
                  onPressed: () =>
                      _editMember(member),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 19,
                  ),
                ),

              if (_canDelete(member))
                IconButton(
                  tooltip:
                      'Remove from staff',
                  onPressed: () =>
                      _removeMember(member),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 19,
                    color:
                        Color(0xFFDC2626),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleBadge(String role) {
    Color color;

    switch (role.toLowerCase()) {
      case 'super admin':
        color =
            const Color(0xFF9333EA);
        break;

      case 'admin':
        color =
            const Color(0xFF2563EB);
        break;

      default:
        color =
            const Color(0xFF16A34A);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        _prettyRole(role),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget _permissions(
    String role,
  ) {
    final permissions =
        switch (role.toLowerCase()) {
      'super admin' => [
          'All Permissions',
        ],
      'admin' => [
          'User Management',
          'Staff Management',
          'Reports',
        ],
      _ => [
          'User Management',
          'Reports',
        ],
    };

    return Wrap(
      spacing: 5,
      runSpacing: 4,
      children: [
        for (final permission
            in permissions.take(2))
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 3,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFF3F4F6),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Text(
              permission,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),

        if (permissions.length > 2)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 3,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFF3F4F6),
              borderRadius:
                  BorderRadius.circular(8),
            ),
            child: Text(
              '+${permissions.length - 2}',
              style: const TextStyle(
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  String _prettyRole(
    String role,
  ) {
    if (role.toLowerCase() ==
        'super admin') {
      return 'Super Admin';
    }

    return role;
  }

  String _initials(
    String value,
  ) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts[0][0]}${parts[1][0]}'
        .toUpperCase();
  }

  String _formatDate(
    DateTime? value,
  ) {
    if (value == null) {
      return '-';
    }

    final local =
        value.toLocal();

    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.'
        '${local.year}';
  }
}

class _RoleCard
    extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final int value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(12),
        side: const BorderSide(
          color:
              Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title),
                ),
                Icon(
                  icon,
                  size: 18,
                  color:
                      Color(0xFF6B7280),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color:
                    Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}