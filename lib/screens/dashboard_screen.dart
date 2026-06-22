import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/announcement_service.dart';
import '../theme/app_theme.dart';

import 'profile_screen.dart';
import 'auth/login_screen.dart';

import 'announcements/announcement_management_screen.dart';
import 'attendance_qr_screen.dart';
import 'scan_qr_screen.dart';

import 'events/event_management_screen.dart';
import 'events/event_registration_screen.dart';
import 'events/registered_events_screen.dart';

import 'accessibility_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const AnnouncementService _announcementService = AnnouncementService();

  late final Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = const AuthService().getUserProfile();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchUpcomingEvents() {
    return FirebaseFirestore.instance
        .collection('events')
        .where('startAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('startAt')
        .limit(5)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchAllEvents() {
    return FirebaseFirestore.instance.collection('events').snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchActiveAnnouncements() {
    return _announcementService.watchActiveAnnouncements(limit: 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final profile = profileSnapshot.data;
              final role = (profile?['role'] ?? '').toString().toLowerCase();
              final name = (profile?['name'] ?? 'User').toString();
              final isCommittee = role == 'committee';

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _watchAllEvents(),
                builder: (context, allEventsSnapshot) {
                  final allEvents = allEventsSnapshot.data?.docs ?? [];
                  final now = DateTime.now();

                  final upcomingEvents = allEvents.where((doc) {
                    final data = doc.data();
                    final timestamp = data['startAt'];
                    if (timestamp is! Timestamp) return false;
                    return timestamp.toDate().isAfter(now);
                  }).toList();

                  final thisWeekEvents = upcomingEvents.where((doc) {
                    final timestamp = doc.data()['startAt'];
                    if (timestamp is! Timestamp) return false;
                    final date = timestamp.toDate();
                    return date.difference(now).inDays <= 7;
                  }).length;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(name),
                        const SizedBox(height: 24),
                        _buildWelcomeCard(isCommittee),
                        const SizedBox(height: 24),
                        _buildKpiSection(
                          totalEvents: allEvents.length,
                          upcomingEvents: upcomingEvents.length,
                          thisWeekEvents: thisWeekEvents,
                          isCommittee: isCommittee,
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _watchUpcomingEvents(),
                          builder: (context, eventSnapshot) {
                            final events = eventSnapshot.data?.docs ?? [];

                            return _buildUpcomingEventSection(
                                events, isCommittee);
                          },
                        ),
                        const SizedBox(height: 24),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _watchActiveAnnouncements(),
                          builder: (context, announcementSnapshot) {
                            final announcements =
                                announcementSnapshot.data?.docs ?? [];

                            return _buildAnnouncementSection(
                              announcements,
                              isCommittee,
                              isLoading: announcementSnapshot.connectionState ==
                                  ConnectionState.waiting,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Quick Access',
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.95,
                          children: [
                            if (isCommittee)
                              _buildDashboardTile(
                                title: 'Events',
                                subtitle: 'Manage events',
                                icon: Icons.event_rounded,
                                onTap: _openEventManagementScreen,
                              )
                            else
                              _buildDashboardTile(
                                title: 'Events',
                                subtitle: 'Register events',
                                icon: Icons.event_rounded,
                                onTap: _openEventRegistrationScreen,
                              ),
                            if (isCommittee)
                              _buildDashboardTile(
                                title: 'Announcements',
                                subtitle: 'Manage updates',
                                icon: Icons.campaign_rounded,
                                onTap: _openAnnouncementManagementScreen,
                              ),
                            _buildDashboardTile(
                              title: 'QR Code',
                              subtitle: isCommittee ? 'Generate QR' : 'Scan QR',
                              icon: isCommittee
                                  ? Icons.qr_code_2_rounded
                                  : Icons.qr_code_scanner_rounded,
                              onTap: isCommittee
                                  ? _openAttendanceQrScreen
                                  : _openScanQrScreen,
                            ),
                            _buildDashboardTile(
                              title: 'Profile',
                              subtitle: 'Manage account',
                              icon: Icons.person_rounded,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            if (isCommittee)
                              _buildDashboardTile(
                                title: 'Attendance',
                                subtitle: 'QR sessions',
                                icon: Icons.fact_check_rounded,
                                onTap: _openAttendanceQrScreen,
                              )
                            else
                              _buildDashboardTile(
                                title: 'Attendance',
                                subtitle: 'My events',
                                icon: Icons.event_available_rounded,
                                onTap: _openRegisteredEventsScreen,
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Welcome back, $name',
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildNotificationIcon(),
            const SizedBox(width: 12),
            _buildProfileMenu(),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _watchUpcomingEvents(),
      builder: (context, snapshot) {
        final events = snapshot.data?.docs ?? [];
        final count = events.length;

        return GestureDetector(
          onTap: _openEventRegistrationScreen,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryRed.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(Icons.notifications_none),
              ),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(bool isCommittee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.buildCardDecoration(borderRadius: 28),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isCommittee ? Icons.verified_user_rounded : Icons.school_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCommittee ? 'Committee Dashboard' : 'Student Dashboard',
                  style: AppTheme.headingMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  isCommittee
                      ? 'Manage event updates, QR attendance and club activities.'
                      : 'View upcoming events, updates and track your attendance.',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSection({
    required int totalEvents,
    required int upcomingEvents,
    required int thisWeekEvents,
    required bool isCommittee,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        _buildKpiCard(
          title: 'Total Events',
          value: totalEvents.toString(),
          icon: Icons.event_note_rounded,
        ),
        _buildKpiCard(
          title: 'Upcoming',
          value: upcomingEvents.toString(),
          icon: Icons.upcoming_rounded,
        ),
        _buildKpiCard(
          title: 'This Week',
          value: thisWeekEvents.toString(),
          icon: Icons.calendar_month_rounded,
        ),
        if (!isCommittee)
          _buildKpiCard(
            title: 'Attendance',
            value: 'View',
            icon: Icons.fact_check_rounded,
          ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.buildCardDecoration(borderRadius: 22),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.primaryRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> events,
    bool isCommittee,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.buildCardDecoration(borderRadius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Upcoming Events',
            actionText: isCommittee ? 'Manage' : 'View all',
            onTap: isCommittee
                ? _openEventManagementScreen
                : _openEventRegistrationScreen,
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            Text(
              'No upcoming events available yet.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            Column(
              children: events.map((doc) {
                final data = doc.data();
                final title = (data['title'] ?? 'Untitled Event').toString();
                final location = (data['location'] ?? 'No location').toString();
                final timestamp = data['startAt'];
                final date = timestamp is Timestamp
                    ? _formatDate(timestamp.toDate())
                    : 'No date';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_available_rounded,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTheme.headingSmall),
                            const SizedBox(height: 4),
                            Text(
                              '$date • $location',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> announcements,
    bool isCommittee, {
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.buildCardDecoration(borderRadius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            title: 'Announcements & Updates',
            actionText: isCommittee ? 'Manage' : null,
            onTap: isCommittee ? _openAnnouncementManagementScreen : null,
          ),
          const SizedBox(height: 14),
          if (isLoading && announcements.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (announcements.isEmpty)
            Text(
              isCommittee
                  ? 'No published announcements yet. Create one to update members.'
                  : 'No announcements available right now.',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...announcements.map(
              (doc) {
                final data = doc.data();
                final title =
                    (data['title'] ?? 'Untitled Announcement').toString();
                final message = (data['message'] ?? '').toString();
                final timestamp = data['createdAt'];
                final date = timestamp is Timestamp
                    ? _formatDate(timestamp.toDate())
                    : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.campaign_rounded,
                        size: 22,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTheme.headingSmall),
                            if (message.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                message,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                            if (date != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                date,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    String? actionText,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTheme.headingSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionText != null && onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionText,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }

  Widget _buildDashboardTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: AppTheme.buildCardDecoration(borderRadius: 24),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppTheme.primaryRed, size: 26),
              ),
              const SizedBox(height: 12),
              Flexible(
                fit: FlexFit.loose,
                child: FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
            break;
          case 'accessibility':
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const AccessibilitySettingsScreen()),
            );
            break;
          case 'logout':
            _handleLogout();
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'profile', child: Text('Profile')),
        PopupMenuItem(value: 'accessibility', child: Text('Accessibility')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryRed.withValues(alpha: 0.5),
          ),
        ),
        child: const Icon(Icons.person),
      ),
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openAttendanceQrScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AttendanceQrScreen()),
    );
  }

  void _openScanQrScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ScanQrScreen()),
    );
  }

  void _openEventManagementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EventManagementScreen()),
    );
  }

  void _openAnnouncementManagementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnnouncementManagementScreen()),
    );
  }

  void _openEventRegistrationScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EventRegistrationScreen()),
    );
  }

  void _openRegisteredEventsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisteredEventsScreen()),
    );
  }
}
