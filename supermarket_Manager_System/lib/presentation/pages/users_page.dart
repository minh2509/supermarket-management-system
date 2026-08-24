import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/user_api_service.dart';
import 'package:supermarket_manager_system/domain/models/role_option.dart';
import 'package:supermarket_manager_system/domain/models/user_list_item.dart';
import 'package:supermarket_manager_system/presentation/pages/user_detail_page.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final _userApiService = UserApiService();
  final _searchController = TextEditingController();
  late Future<List<UserListItem>> _usersFuture;
  int? _selectedUserId;
  int? _statusLoadingUserId;
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';
  String _selectedRoleFilter = 'all';

  @override
  void initState() {
    super.initState();
    _usersFuture = _userApiService.getUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadUsers() {
    setState(() {
      _usersFuture = _userApiService.getUsers();
    });
  }

  Future<void> _openAddUserDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddUserDialog(userApiService: _userApiService),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = widget.isCompact ? 16.0 : 24.0;
    return Container(
      color: const Color(0xFFF7F8FC),
      child: Column(
        children: [
          _UsersHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _selectedUserId == null
                        ? FutureBuilder<List<UserListItem>>(
                            future: _usersFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Cannot load users: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _reloadUsers,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final users = snapshot.data ?? [];
                              final filteredUsers = _filterUsers(users);
                              final roleOptions = _extractRoleOptions(users);
                              return Column(
                                children: [
                                  _UsersFilterBar(
                                    isCompact: widget.isCompact,
                                    searchController: _searchController,
                                    searchQuery: _searchQuery,
                                    selectedStatus: _selectedStatusFilter,
                                    selectedRole: _selectedRoleFilter,
                                    roleOptions: roleOptions,
                                    totalUsers: users.length,
                                    filteredUsers: filteredUsers.length,
                                    onSearchChanged: (value) => setState(
                                      () => _searchQuery = value.trim(),
                                    ),
                                    onClearSearch: () => setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    }),
                                    onStatusChanged: (value) => setState(
                                      () => _selectedStatusFilter = value,
                                    ),
                                    onRoleChanged: (value) => setState(
                                      () => _selectedRoleFilter = value,
                                    ),
                                    onRefresh: _reloadUsers,
                                    onAddUser: _openAddUserDialog,
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: users.isEmpty
                                        ? _UsersEmptyState(
                                            icon: Icons.person_search_outlined,
                                            title: 'No users found',
                                            message:
                                                'Start by creating a new account to populate this list.',
                                            primaryLabel: 'Add first user',
                                            onPrimaryAction: _openAddUserDialog,
                                          )
                                        : filteredUsers.isEmpty
                                        ? _UsersEmptyState(
                                            icon: Icons.filter_alt_off_outlined,
                                            title: 'No matching users',
                                            message:
                                                'Try another name, status or type filter to see more results.',
                                            primaryLabel: 'Clear filters',
                                            onPrimaryAction: _clearFilters,
                                          )
                                        : ListView.separated(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: filteredUsers.length,
                                            separatorBuilder: (_, _) =>
                                                const SizedBox(height: 16),
                                            itemBuilder: (context, index) {
                                              final user = filteredUsers[index];
                                              return _buildUserCard(
                                                index + 1,
                                                user,
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              );
                            },
                          )
                        : UserDetailContent(
                            userId: _selectedUserId!,
                            onBack: () =>
                                setState(() => _selectedUserId = null),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(int index, UserListItem user) {
    final displayName = user.fullname.isEmpty ? 'Unknown user' : user.fullname;
    final isBusy = _statusLoadingUserId == user.id;
    final canDeactivate = _isActiveStatus(user.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFF3EDED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 28,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UserAvatar(index: index, fullName: displayName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role.isEmpty ? 'USER' : user.role.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 13,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7B1E2B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: user.status),
                  const SizedBox(height: 6),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditUserDialog(user);
                        return;
                      }
                      if (!isBusy && value == 'toggle') {
                        _confirmToggleUserStatus(user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit user'),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Text(
                          canDeactivate ? 'Deactivate user' : 'Activate user',
                        ),
                      ),
                    ],
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                    splashRadius: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          _UserDetailRow(
            icon: Icons.email_outlined,
            label: user.email.isEmpty ? 'No email available' : user.email,
          ),
          const SizedBox(height: 10),
          _UserDetailRow(
            icon: Icons.badge_outlined,
            label: user.idCard.isEmpty ? 'ID ${user.id}' : user.idCard,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF5EDED)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _openUserDetails(user.id),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFFF6F6),
                foregroundColor: const Color(0xFF7B1E2B),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isBusy ? 'Updating...' : 'View Details',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openUserDetails(int userId) {
    setState(() => _selectedUserId = userId);
  }

  Future<void> _openEditUserDialog(UserListItem user) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _EditUserDialog(userApiService: _userApiService, user: user),
    );

    if (!mounted) {
      return;
    }

    if (updated == true) {
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    }
  }

  Future<void> _confirmToggleUserStatus(UserListItem user) async {
    final targetStatus = _isActiveStatus(user.status) ? 'deactive' : 'active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Status Change'),
          content: Text(
            'Are you sure you want to change ${user.username} status to ${targetStatus.toUpperCase()}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(dialogContext, rootNavigator: true).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _toggleUserStatus(user);
    }
  }

  Future<void> _toggleUserStatus(UserListItem user) async {
    final targetStatus = _isActiveStatus(user.status) ? 'deactive' : 'active';
    setState(() => _statusLoadingUserId = user.id);
    try {
      await _userApiService.updateUserStatus(
        userId: user.id,
        status: targetStatus,
      );
      if (!mounted) {
        return;
      }
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User status updated to $targetStatus')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _statusLoadingUserId = null);
      }
    }
  }

  bool _isActiveStatus(String status) =>
      status.trim().toLowerCase() == 'active';

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedStatusFilter = 'all';
      _selectedRoleFilter = 'all';
    });
  }

  List<UserListItem> _filterUsers(List<UserListItem> users) {
    return users.where((user) {
      final normalizedName = user.fullname.trim().toLowerCase();
      final normalizedUsername = user.username.trim().toLowerCase();
      final normalizedIdCard = user.idCard.trim().toLowerCase();
      final normalizedId = user.id.toString().toLowerCase();
      final normalizedStatus = user.status.trim().toLowerCase();
      final normalizedRole = user.role.trim().toLowerCase();
      final normalizedQuery = _searchQuery.toLowerCase();

      final matchesSearch =
          normalizedQuery.isEmpty ||
          normalizedName.contains(normalizedQuery) ||
          normalizedUsername.contains(normalizedQuery) ||
          normalizedIdCard.contains(normalizedQuery) ||
          normalizedId.contains(normalizedQuery);
      final matchesStatus =
          _selectedStatusFilter == 'all' ||
          normalizedStatus == _selectedStatusFilter;
      final matchesRole =
          _selectedRoleFilter == 'all' || normalizedRole == _selectedRoleFilter;

      return matchesSearch && matchesStatus && matchesRole;
    }).toList();
  }

  List<String> _extractRoleOptions(List<UserListItem> users) {
    final roles =
        users
            .map((user) => user.role.trim())
            .where((role) => role.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return roles;
  }
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isCompact)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          else
            const SizedBox(width: 48),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentTimeText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fullName.isEmpty ? 'Administrator' : fullName),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsersFilterBar extends StatelessWidget {
  const _UsersFilterBar({
    required this.isCompact,
    required this.searchController,
    required this.searchQuery,
    required this.selectedStatus,
    required this.selectedRole,
    required this.roleOptions,
    required this.totalUsers,
    required this.filteredUsers,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onStatusChanged,
    required this.onRoleChanged,
    required this.onRefresh,
    required this.onAddUser,
  });

  final bool isCompact;
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedStatus;
  final String selectedRole;
  final List<String> roleOptions;
  final int totalUsers;
  final int filteredUsers;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onRefresh;
  final VoidCallback onAddUser;

  @override
  Widget build(BuildContext context) {
    final actionButtonSize = isCompact ? 58.0 : 62.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$filteredUsers of $totalUsers users',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C83FD), Color(0xFF8B5CF6)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x337C83FD),
                    blurRadius: 14,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: onAddUser,
                icon: const Icon(Icons.add, color: Colors.white, size: 15),
                label: const Text(
                  'Add User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7B1E2B),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by name or ID',
                  hintStyle: const TextStyle(
                    color: Color(0xFFD38E9A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 24,
                    color: Color(0xFF9B2743),
                  ),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClearSearch,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF9B2743),
                          ),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFFFF6F6),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFFF1D9DD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(
                      color: Color(0xFF9B2743),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: actionButtonSize,
              height: actionButtonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF9B0D2B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x339B0D2B),
                    blurRadius: 12,
                    offset: Offset(0, 7),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: onRefresh,
                tooltip: 'Refresh',
                icon: const Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: isCompact ? 132 : 148,
              child: _FilterDropdown(
                value: selectedStatus,
                hint: 'Status',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All status')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'deactive', child: Text('Deactive')),
                ],
                onChanged: onStatusChanged,
              ),
            ),
            SizedBox(
              width: isCompact ? 132 : 148,
              child: _FilterDropdown(
                value: selectedRole,
                hint: 'Type',
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All type')),
                  ...roleOptions.map(
                    (role) => DropdownMenuItem(
                      value: role.toLowerCase(),
                      child: Text(_formatRoleLabel(role)),
                    ),
                  ),
                ],
                onChanged: onRoleChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFFFF1F2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFFE9C7CE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Color(0xFF9B2743), width: 1.4),
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF9B2743),
      ),
      style: const TextStyle(
        color: Color(0xFF7B1E2B),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      dropdownColor: Colors.white,
    );
  }
}

class _UsersEmptyState extends StatelessWidget {
  const _UsersEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EAF4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, size: 34, color: const Color(0xFF7C3AED)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C83FD),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}

String _formatRoleLabel(String roleName) {
  if (roleName.isEmpty) {
    return '';
  }
  final lower = roleName.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.index, required this.fullName});

  final int index;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials = parts.isEmpty
        ? 'U'
        : parts.take(2).map((part) => part[0].toUpperCase()).join();

    return Container(
      width: 62,
      height: 62,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFF3D7DD), Color(0xFFE2E8F0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF7B1E2B),
        ),
      ),
    );
  }
}

class _UserDetailRow extends StatelessWidget {
  const _UserDetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF7C8699)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isActive = normalized == 'active';
    final bg = isActive ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC);
    final fg = isActive ? const Color(0xFF047857) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: bg,
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({required this.userApiService});

  final UserApiService userApiService;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idCardController = TextEditingController();

  String _selectedRole = '';
  bool _showPassword = false;
  bool _isSubmitting = false;
  bool _isLoadingRoles = true;
  List<RoleOption> _roles = const [];
  String? _errorText;
  String? _rolesErrorText;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _rolesErrorText = null;
    });
    try {
      final roles = await widget.userApiService.getRoles();
      if (!mounted) {
        return;
      }
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRoles = false;
        _rolesErrorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoadingRoles) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.userApiService.createUser(
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        idCard: _idCardController.text.trim(),
        userRole: _selectedRole,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      String errorMessage = error.toString().replaceFirst('Exception: ', '');
      if (errorMessage.toLowerCase().contains('duplicate') ||
          errorMessage.toLowerCase().contains('already exists') ||
          errorMessage.toLowerCase().contains('unique')) {
        errorMessage = 'Account already exists.';
      }
      setState(() {
        _errorText = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Create User Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _fullnameController,
                          label: 'Fullname',
                          hint: 'Enter name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Fullname is required'
                              : null,
                        ),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Enter Username',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Username is required'
                              : null,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'e-Mail',
                          hint: 'Enter e-mail...',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Email must contain @';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter password',
                          obscureText: !_showPassword,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 8) {
                              return 'Must be at least 8 characters';
                            }
                            if (!v.contains(RegExp(r'[A-Z]'))) {
                              return 'Must contain at least 1 uppercase letter';
                            }
                            if (!v.contains(RegExp(r'[a-z]'))) {
                              return 'Must contain at least 1 lowercase letter';
                            }
                            if (!v.contains(RegExp(r'[0-9]'))) {
                              return 'Must contain at least 1 number';
                            }
                            if (!v.contains(
                              RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                            )) {
                              return 'Must contain at least 1 special character';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _showPassword,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) => setState(
                                          () => _showPassword = value ?? false,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Show password',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _idCardController,
                          labelWidget: RichText(
                            text: const TextSpan(
                              text: 'ID Card ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                                fontFamily: 'Inter',
                              ),
                              children: [
                                TextSpan(
                                  text: '(có thể để trống)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hint: 'Enter ID card (optional)',
                        ),
                        if (_isLoadingRoles)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: LinearProgressIndicator(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'User Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedRole.isEmpty
                                      ? null
                                      : _selectedRole,
                                  items: _roles
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role.name,
                                          child: Text(
                                            _formatRoleLabel(role.name),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (_isSubmitting || _roles.isEmpty)
                                      ? null
                                      : (value) => setState(
                                          () => _selectedRole = value ?? '',
                                        ),
                                  decoration: InputDecoration(
                                    hintText: 'Choose User Role..',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF14B8A6),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF6B7280),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'User role is required'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        if (_rolesErrorText != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _rolesErrorText!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isSubmitting ? null : _loadRoles,
                                child: const Text('Retry roles'),
                              ),
                            ],
                          ),
                        ],
                        if (_errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorText!,
                            style: const TextStyle(color: Color(0xFFB91C1C)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFE53E3E,
                        ), // Red to match image
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          (_isSubmitting || _isLoadingRoles || _roles.isEmpty)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF14B8A6,
                        ), // Teal to match image
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    Widget? labelWidget,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelWidget != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: labelWidget,
            )
          else if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF14B8A6)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRoleLabel(String roleName) {
    if (roleName.isEmpty) {
      return '';
    }
    final lower = roleName.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({required this.userApiService, required this.user});

  final UserApiService userApiService;
  final UserListItem user;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _idCardController;

  String _selectedRole = '';
  bool _showPassword = false;
  bool _isSubmitting = false;
  bool _isLoadingRoles = true;
  List<RoleOption> _roles = const [];
  String? _errorText;
  String? _rolesErrorText;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.user.fullname);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _idCardController = TextEditingController(text: widget.user.idCard);
    _loadRoles();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _rolesErrorText = null;
    });
    try {
      final roles = await widget.userApiService.getRoles();
      if (!mounted) {
        return;
      }
      String selected = '';
      for (final role in roles) {
        if (role.name.toLowerCase() == widget.user.role.toLowerCase()) {
          selected = role.name;
          break;
        }
      }
      setState(() {
        _roles = roles;
        _selectedRole = selected;
        _isLoadingRoles = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRoles = false;
        _rolesErrorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoadingRoles) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.userApiService.updateUser(
        userId: widget.user.id,
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        userRole: _selectedRole,
        idCard: _idCardController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      String errorMessage = error.toString().replaceFirst('Exception: ', '');
      if (errorMessage.toLowerCase().contains('duplicate') ||
          errorMessage.toLowerCase().contains('already exists') ||
          errorMessage.toLowerCase().contains('unique')) {
        errorMessage = 'Account already exists.';
      }
      setState(() {
        _errorText = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Update User Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pop(false),
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _fullnameController,
                          label: 'Fullname',
                          hint: 'Enter name',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Fullname is required'
                              : null,
                        ),
                        _buildTextField(
                          controller: _usernameController,
                          label: 'Username',
                          hint: 'Enter Username',
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Username is required'
                              : null,
                        ),
                        _buildTextField(
                          controller: _emailController,
                          label: 'e-Mail',
                          hint: 'Enter e-mail...',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) {
                              return 'Email must contain @';
                            }
                            return null;
                          },
                        ),
                        _buildTextField(
                          controller: _passwordController,
                          labelWidget: RichText(
                            text: const TextSpan(
                              text: 'Password ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                                fontFamily: 'Inter',
                              ),
                              children: [
                                TextSpan(
                                  text: '(có thể để trống)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hint: 'Leave blank to keep current',
                          obscureText: !_showPassword,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return null;
                            }
                            if (v.length < 8) {
                              return 'Must be at least 8 characters';
                            }
                            if (!v.contains(RegExp(r'[A-Z]'))) {
                              return 'Must contain at least 1 uppercase letter';
                            }
                            if (!v.contains(RegExp(r'[a-z]'))) {
                              return 'Must contain at least 1 lowercase letter';
                            }
                            if (!v.contains(RegExp(r'[0-9]'))) {
                              return 'Must contain at least 1 number';
                            }
                            if (!v.contains(
                              RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                            )) {
                              return 'Must contain at least 1 special character';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _showPassword,
                                  onChanged: _isSubmitting
                                      ? null
                                      : (value) => setState(
                                          () => _showPassword = value ?? false,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Show password',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _idCardController,
                          labelWidget: RichText(
                            text: const TextSpan(
                              text: 'ID Card ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4B5563),
                                fontFamily: 'Inter',
                              ),
                              children: [
                                TextSpan(
                                  text: '(có thể để trống)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hint: 'Enter ID card (optional)',
                        ),
                        if (_isLoadingRoles)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: LinearProgressIndicator(),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'User Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4B5563),
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedRole.isEmpty
                                      ? null
                                      : _selectedRole,
                                  items: _roles
                                      .map(
                                        (role) => DropdownMenuItem(
                                          value: role.name,
                                          child: Text(
                                            _formatRoleLabel(role.name),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (_isSubmitting || _roles.isEmpty)
                                      ? null
                                      : (value) => setState(
                                          () => _selectedRole = value ?? '',
                                        ),
                                  decoration: InputDecoration(
                                    hintText: 'Choose User Role..',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF14B8A6),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF6B7280),
                                  ),
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'User role is required'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        if (_rolesErrorText != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _rolesErrorText!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _isSubmitting ? null : _loadRoles,
                                child: const Text('Retry roles'),
                              ),
                            ],
                          ),
                        ],
                        if (_errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorText!,
                            style: const TextStyle(color: Color(0xFFB91C1C)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E), // Red
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          (_isSubmitting || _isLoadingRoles || _roles.isEmpty)
                          ? null
                          : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B8A6), // Teal
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Update'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    Widget? labelWidget,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelWidget != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: labelWidget,
            )
          else if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF14B8A6)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE53E3E)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRoleLabel(String roleName) {
    if (roleName.isEmpty) {
      return '';
    }
    final lower = roleName.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
