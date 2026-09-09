import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../../../shared/models/paged_result.dart';
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
  static const int _pageSize = 10;

  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  late Future<PagedResult<AdminStaffMember>> _staffFuture;
  late Future<List<int>> _statsFuture;

  int _page = 1;
  String? _search;
  String? _role;

  String get _myRole =>
      AppServices.sessionStore.role ?? '';

  bool get _isSuperAdmin =>
      _myRole.toLowerCase() == 'super admin';

  bool get _isAdmin =>
      _myRole.toLowerCase() == 'admin';

  @override
  void initState() {
    super.initState();

    _staffFuture = _load();
    _statsFuture = _loadStats();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResult<AdminStaffMember>> _load() {
    return AppServices.adminStaffService.getStaff(
      search: _search,
      role: _role,
      page: _page,
      pageSize: _pageSize,
    );
  }

  Future<List<int>> _loadStats() async {
    final results = await Future.wait([
      AppServices.adminStaffService.getStaff(
        role: 'Super Admin',
        page: 1,
        pageSize: 1,
      ),
      AppServices.adminStaffService.getStaff(
        role: 'Admin',
        page: 1,
        pageSize: 1,
      ),
      AppServices.adminStaffService.getStaff(
        role: 'Moderator',
        page: 1,
        pageSize: 1,
      ),
    ]);

    return [
      results[0].totalCount,
      results[1].totalCount,
      results[2].totalCount,
    ];
  }

  void _refresh({bool firstPage = false}) {
    setState(() {
      if (firstPage) {
        _page = 1;
      }

      _staffFuture = _load();
      _statsFuture = _loadStats();
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _search = value.trim().isEmpty ? null : value.trim();
          _page = 1;
          _staffFuture = _load();
        });
      },
    );
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _role = role;
      _page = 1;
      _staffFuture = _load();
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

      if (!mounted) {
        return;
      }

      final current = await _load();

      if (!mounted) {
        return;
      }

      if (current.items.isEmpty && _page > 1) {
        _page--;
      }

      _refresh();
    } on ApiException catch (exception) {
      AppServices.errorHandler.showApiException(
        exception,
        title: 'Unable to remove member',
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

            FutureBuilder<PagedResult<AdminStaffMember>>(
              future: _staffFuture,
              builder: (context, snapshot) {
                
                final result = snapshot.data;
                return Column(
                  children: [
                    FutureBuilder<List<int>>(
                      future: _statsFuture,
                      builder: (context, statsSnapshot) {
                        final stats = statsSnapshot.data;

                        return _buildStats(
                          superAdmins: stats?[0] ?? 0,
                          admins: stats?[1] ?? 0,
                          moderators: stats?[2] ?? 0,
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    _buildTeamCard(
                      snapshot,
                      result,
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

 Widget _buildStats({
    required int superAdmins,
    required int admins,
    required int moderators,
  }) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            title: 'Super Admins',
            value: superAdmins,
            subtitle: 'Total',
            icon: Icons.workspace_premium_outlined,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _RoleCard(
            title: 'Admins',
            value: admins,
            subtitle: 'Total',
            icon: Icons.shield_outlined,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _RoleCard(
            title: 'Moderators',
            value: moderators,
            subtitle: 'Total',
            icon: Icons.group_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(
    AsyncSnapshot<PagedResult<AdminStaffMember>> snapshot,
    PagedResult<AdminStaffMember>? result,
  ) {
    final staff = result?.items ?? const <AdminStaffMember>[];

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
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Team Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search staff...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String?>(
                    initialValue: _role,
                    isDense: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All roles'),
                      ),
                      DropdownMenuItem(
                        value: 'Super Admin',
                        child: Text('Super Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'Admin',
                        child: Text('Admin'),
                      ),
                      DropdownMenuItem(
                        value: 'Moderator',
                        child: Text('Moderator'),
                      ),
                    ],
                    onChanged: _onRoleChanged,
                  ),
                ),
              ],
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
              Column(
                children: [
                  _buildTable(staff),
                  const SizedBox(height: 14),
                  _buildPagination(result!),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(PagedResult<AdminStaffMember> result) {
    final totalPages = result.totalCount == 0
        ? 1
        : (result.totalCount / result.pageSize).ceil();

    return Row(
      children: [
        Text(
          '${result.totalCount} total',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: result.page > 1
              ? () {
                  setState(() {
                    _page = result.page - 1;
                    _staffFuture = _load();
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Page ${result.page} of $totalPages'),
        IconButton(
          tooltip: 'Next page',
          onPressed: result.page < totalPages
              ? () {
                  setState(() {
                    _page = result.page + 1;
                    _staffFuture = _load();
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
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
