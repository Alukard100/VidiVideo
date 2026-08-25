import 'package:flutter/material.dart';

import '../../../app/app_routes.dart';
import '../../../core/dependency/app_services.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/media_url.dart';
import '../../../shared/models/paged_result.dart';
import '../../../shared/widgets/responsive_scaffold.dart';
import '../models/admin_user_sort.dart';
import '../models/admin_user_summary.dart';
import 'admin_navigation.dart';
import 'widgets/admin_profile_menu.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  final _searchController = TextEditingController();
  final int _pageSize = 10;

  PagedResult<AdminUserSummary>? _result;
  bool _isLoading = false;
  Object? _error;
  int _page = 1;
  AdminUserStatusFilter _statusFilter = AdminUserStatusFilter.all;
  AdminUserSort _sortBy = AdminUserSort.registrationDate;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'Users',
      navigationItems:
          adminNavigationItems(AppRoutes.adminUsers),

      navigationFooter: const AdminProfileMenu(),
          
      body: Container(
        color: const Color(0xFFF8F9FB),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Members Management',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage all members and their account status.',
              style: TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 18),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildToolbar(),
                    const SizedBox(height: 16),
                    _buildTable(),
                    const SizedBox(height: 14),
                    _buildPagination(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await AppServices.adminUserService.getUsers(
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        status: _statusFilter.apiValue,
        sortBy: _sortBy.apiValue,
        sortWay: _ascending ? 'Ascending' : 'Descending',
        page: _page,
        pageSize: _pageSize,
      );

      if (!mounted) return;
      setState(() => _result = result);
    } catch (exception) {
      if (!mounted) return;
      setState(() => _error = exception);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _changeSort(AdminUserSort sort) {
    setState(() {
      if (_sortBy == sort) {
        _ascending = !_ascending;
      } else {
        _sortBy = sort;
        _ascending = true;
      }
      _page = 1;
    });
    _loadUsers();
  }

  int get _totalPages {
    final total = _result?.totalCount ?? 0;
    return total == 0 ? 1 : (total / _pageSize).ceil();
  }

  Future<void> _previousPage() async {
    if (_page <= 1) return;
    setState(() => _page--);
    await _loadUsers();
  }

  Future<void> _nextPage() async {
    if (_page >= _totalPages) return;
    setState(() => _page++);
    await _loadUsers();
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Member Directory',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(
          width: 250,
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search members...',
              prefixIcon: Icon(
                Icons.search,
                size: 18,
              ),
              isDense: true,
            ),
            onSubmitted: (_) {
              _page = 1;
              _loadUsers();
            },
          ),
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 150,
          child:
              DropdownButtonFormField<
                  AdminUserStatusFilter>(
            initialValue: _statusFilter,
            isDense: true,
            items: [
              for (final status
                  in AdminUserStatusFilter.values)
                DropdownMenuItem(
                  value: status,
                  child: Text(status.label),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                _statusFilter = value;
                _page = 1;
              });

              _loadUsers();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    if (_isLoading && _result == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null && _result == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage(_error!),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    final users = _result?.items ?? const <AdminUserSummary>[];
    if (users.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No members found.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: _sortBy.index,
        sortAscending: _ascending,
        columns: [
          _sortableColumn(label: 'Member', sort: AdminUserSort.userName),
          _sortableColumn(
            label: 'Registration Date',
            sort: AdminUserSort.registrationDate,
          ),
          _sortableColumn(label: 'Videos', sort: AdminUserSort.videoCount),
          _sortableColumn(
            label: 'Followers',
            sort: AdminUserSort.followersCount,
          ),
          _sortableColumn(label: 'Status', sort: AdminUserSort.status),
          const DataColumn(label: Text('Actions')),
        ],
        rows: users.map(_buildRow).toList(),
      ),
    );
  }

  DataColumn _sortableColumn({
    required String label,
    required AdminUserSort sort,
  }) {
    final isSelected = _sortBy == sort;
    return DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              _ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 14,
            ),
          ],
        ],
      ),
      onSort: (_, _) => _changeSort(sort),
    );
  }

  DataRow _buildRow(AdminUserSummary user) {
    final resolvedAvatarUrl = resolveMediaUrl(user.avatarUrl);
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: resolvedAvatarUrl.isNotEmpty
                    ? NetworkImage(resolvedAvatarUrl)
                    : null,
                child: resolvedAvatarUrl.isEmpty
                  ? Text(
                      user.userName.isEmpty
                          ? '?'
                          : user.userName[0].toUpperCase(),
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
                    user.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(_formatDate(user.createdAtUtc))),
        DataCell(Text('${user.videoCount}')),
        DataCell(Text('${user.followersCount}')),
        DataCell(_statusBadge(user.status)),
        DataCell(
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'suspend') {
                _updateUserStatus(user, 2);
              } else if (value == 'activate') {
                _updateUserStatus(user, 1);
              }
            },
            itemBuilder: (_) => [
              if (user.status.toLowerCase() == 'active')
                const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              if (user.status.toLowerCase() == 'suspended')
                const PopupMenuItem(value: 'activate', child: Text('Activate')),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  String _errorMessage(Object error) {
    if (error is ApiException) {
      return 'Unable to load members '
          '(${error.statusCode}): '
          '${error.message}';
    }

    return 'Unable to load members.';
  }

  Widget _statusBadge(String status) {
    final isInactive = status.toLowerCase() == 'suspended' ||
        status.toLowerCase() == 'deleted';
    final color = isInactive
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);
    final background = isInactive
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFF0FDF4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _updateUserStatus(AdminUserSummary user, int status) async {
    try {
      await AppServices.adminUserService.updateStatus(
        userId: user.id,
        status: status,
      );
      await _loadUsers();
    } on ApiException catch (exception) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update member '
            '(${exception.statusCode}): '
            '${exception.message}',
          ),
        ),
      );
  } catch (_) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update member.',
          ),
        ),
      );
    }
  }

  Widget _buildPagination() {
    return Row(
      children: [
        Text(
          '${_result?.totalCount ?? 0} members',
          style: const TextStyle(color: Color(0xFF6B7280)),
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: _page > 1 ? _previousPage : null,
          child: const Text('Previous'),
        ),
        const SizedBox(width: 10),
        Text('Page $_page of $_totalPages'),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: _page < _totalPages ? _nextPage : null,
          child: const Text('Next'),
        ),
      ],
    );
  }
}
