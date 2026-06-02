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

import 'accessibility_settings_screen.dart';

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
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profile = snapshot.data;

              final role = (profile?['role'] ?? '').toString().toLowerCase();

              final isCommittee = role == 'committee';

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildWelcomeCard(isCommittee),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount:
                                                MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.82,
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
              'Welcome back',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        _buildProfileMenu(),
      ],
    );
  }

  Widget _buildWelcomeCard(bool isCommittee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.buildCardDecoration(
        borderRadius: 28,
      ),
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
                      ? 'Manage events, attendance and club activities.'
                      : 'Register for events and track your attendance.',
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
          decoration: AppTheme.buildCardDecoration(
            borderRadius: 24,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
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
              MaterialPageRoute(
                builder: (_) => const ProfileScreen(),
              ),
            );
            break;

          case 'accessibility':
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AccessibilitySettingsScreen(),
              ),
            );
            break;

          case 'logout':
            _handleLogout();
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'profile',
          child: Text('Profile'),
        ),
        const PopupMenuItem(
          value: 'accessibility',
          child: Text('Accessibility'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryRed.withValues(alpha: 0.5),
          ),
        ),
        child: const Icon(
          Icons.person,
        ),
      ),
    );
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _openAttendanceQrScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AttendanceQrScreen(),
      ),
    );
  }

  void _openScanQrScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScanQrScreen(),
      ),
    );
  }

  void _openEventManagementScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EventManagementScreen(),
      ),
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
