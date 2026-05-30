import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import 'profile_screen.dart';
import 'auth/login_screen.dart';
import 'attendance_qr_screen.dart';
import 'scan_qr_screen.dart';
import 'events/event_management_screen.dart';
import 'events/event_registration_screen.dart';
import 'events/registered_events_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final Future<Map<String, dynamic>?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = const AuthService().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final role = (profile?['role'] ?? '').toString().toLowerCase();
              final isCommittee = role == 'committee';

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                              isCommittee
                                  ? 'Committee attendance tools'
                                  : 'Student attendance view',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        _buildProfileMenu(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroCard(isCommittee: isCommittee),
                          const SizedBox(height: 20),
                          if (isCommittee) ...[
                            _buildActionCard(
                              title: 'Manage Events',
                              description:
                                  'Create, update, and delete events used by attendance QR sessions.',
                              icon: Icons.event_rounded,
                              onTap: _openEventManagementScreen,
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (!isCommittee) ...[
                            _buildActionCard(
                              title: 'Register Events',
                              description:
                                  'Browse upcoming club events and register for participation.',
                              icon: Icons.app_registration_rounded,
                              onTap: _openEventRegistrationScreen,
                            ),
                            const SizedBox(height: 16),
                            _buildActionCard(
                              title: 'My Registered Events',
                              description:
                                  'View your registered events and manage upcoming registrations.',
                              icon: Icons.event_available_rounded,
                              onTap: _openRegisteredEventsScreen,
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildActionCard(
                            title: isCommittee
                                ? 'Generate Attendance QR'
                                : 'Attendance QR',
                            description: isCommittee
                                ? 'Create a fresh QR code for students to scan and record attendance.'
                                : 'Ask a committee member for the live attendance QR code.',
                            icon: isCommittee
                                ? Icons.qr_code_2_rounded
                                : Icons.qr_code_scanner_rounded,
                            onTap: isCommittee
                                ? _openAttendanceQrScreen
                                : _openScanQrScreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({required bool isCommittee}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.buildCardDecoration(
        borderRadius: AppTheme.radiusLg,
        shadows: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCommittee ? Icons.verified_user_rounded : Icons.school_rounded,
            color: AppTheme.primaryRedLight,
            size: 34,
          ),
          const SizedBox(height: 16),
          Text(
            isCommittee ? 'Committee controls' : 'Student access',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            isCommittee
                ? 'Generate and share the attendance QR from here.'
                : 'View attendance tools and wait for the active QR session.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.buildCardDecoration(
            borderRadius: AppTheme.radiusLg,
            shadows: AppTheme.softShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: AppTheme.primaryRedLight, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'profile') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
        } else if (value == 'logout') {
          _handleLogout();
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 12),
              Text(
                'Edit Profile',
                style: AppTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 20, color: AppTheme.primaryRed),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRed),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryRed.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.person,
            color: AppTheme.primaryRed,
            size: 24,
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          'Logout',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRed),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
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

  void _openEventRegistrationScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EventRegistrationScreen(),
      ),
    );
  }

  void _openRegisteredEventsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisteredEventsScreen(),
      ),
    );
  }
}
