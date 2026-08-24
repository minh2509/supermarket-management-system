import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/user_api_service.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';

class UserDetailContent extends StatefulWidget {
  const UserDetailContent({
    super.key,
    required this.userId,
    required this.onBack,
  });

  final int userId;
  final VoidCallback onBack;

  @override
  State<UserDetailContent> createState() => _UserDetailContentState();
}

class _UserDetailContentState extends State<UserDetailContent> {
  final _userApiService = UserApiService();
  late Future<UserDetail> _detailFuture;
  bool _showSchedule = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _userApiService.getUserDetail(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserDetail>(
      future: _detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Cannot load user detail: ${snapshot.error}'),
          );
        }
        final user = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: const Color(0xFF2E7D32),
                padding: EdgeInsets.zero,
              ),
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text(
                'Back to Users list',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'User Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 20),
            _DetailCard(user: user),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C5DAB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => setState(() => _showSchedule = !_showSchedule),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (_showSchedule) ...[
              const SizedBox(height: 24),
              const Text(
                'Work schedule (week)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              _ScheduleTable(schedule: user.schedule),
            ],
          ],
        );
      },
    );
  }
}

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({
    super.key,
    required this.userId,
    required this.currentAdminName,
  });

  final int userId;
  final String currentAdminName;

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1024;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          drawer: isCompact ? Drawer(width: 280, child: _sidebar()) : null,
          body: SafeArea(
            child: Row(
              children: [
                if (!isCompact) SizedBox(width: 260, child: _sidebar()),
                Expanded(
                  child: Column(
                    children: [
                      _header(isCompact: isCompact),
                      Expanded(
                        child: UserDetailContent(
                          userId: widget.userId,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sidebar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            child: const Row(
              children: [
                _LogoBox(),
                SizedBox(width: 10),
                Text(
                  'SMS SYSTEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _SidebarItem(label: 'Dashboard'),
                    _SidebarItem(label: 'Users', active: true),
                    _SidebarItem(label: 'Customer'),
                    _SidebarItem(label: 'Discount'),
                    _SidebarItem(label: 'Suppliers'),
                    _SidebarItem(label: 'Category'),
                    _SidebarItem(label: 'Products'),
                    _SidebarItem(label: 'Orders'),
                    _SidebarItem(label: 'Creditors'),
                    _SidebarItem(label: 'Expired'),
                    _SidebarItem(label: 'Reports'),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Color.fromRGBO(255, 255, 255, 0.25), height: 1),
          const _SidebarItem(label: 'Logout'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _header({required bool isCompact}) {
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
                child: const Text(
                  '11:14:36 AM',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.currentAdminName.isEmpty
                        ? 'Administrator'
                        : widget.currentAdminName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    'Administrator',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _Avatar(user: user),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullname,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1.5, height: 1),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _DetailRow(label: 'Fullname', value: user.fullname),
                _DetailRow(label: 'Username', value: user.username),
                _DetailRow(label: 'e-Mail', value: user.email),
                _DetailRow(label: 'Role', value: user.role),
                _DetailRow(
                  label: 'ID Card',
                  value: user.idCard.isEmpty ? '—' : user.idCard,
                ),
                _DetailRow(label: 'Status', value: user.status, isStatus: true),
                _DetailRow(
                  label: 'Last Login',
                  value: user.lastLogin,
                  isLastLogin: true,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final UserDetail user;

  @override
  Widget build(BuildContext context) {
    final initial = user.fullname.isNotEmpty
        ? user.fullname[0].toUpperCase()
        : 'U';
    if (user.avatar.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: Image.network(
          user.avatar,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, error, stackTrace) => _avatarFallback(initial),
        ),
      );
    }
    return _avatarFallback(initial);
  }

  Widget _avatarFallback(String initial) {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE2E8F0),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isStatus = false,
    this.isLastLogin = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isStatus;
  final bool isLastLogin;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    Widget valueWidget;

    if (isStatus || isLastLogin) {
      final isActive = value.toLowerCase() == 'active';
      final bgColor = (isStatus && isActive) || isLastLogin
          ? const Color(0xFFD1FAE5)
          : const Color(0xFFFEE2E2);
      final textColor = (isStatus && isActive) || isLastLogin
          ? const Color(0xFF059669)
          : const Color(0xFFDC2626);

      valueWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          value.isEmpty ? '—' : value,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );
    } else {
      valueWidget = Text(
        value.isEmpty ? '—' : value,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: valueWidget),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({required this.schedule});

  final List<UserScheduleItem> schedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Day')),
            DataColumn(label: Text('Login time')),
            DataColumn(label: Text('Logout time')),
            DataColumn(label: Text('Shift revenue')),
          ],
          rows: schedule
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(Text(item.day)),
                    DataCell(Text(item.loginTime)),
                    DataCell(Text(item.logoutTime)),
                    DataCell(Text(item.shiftRevenue)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'P',
        style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.label, this.active = false});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active
            ? const Color.fromRGBO(255, 255, 255, 0.18)
            : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
