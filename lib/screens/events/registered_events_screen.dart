import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class RegisteredEventsScreen extends StatefulWidget {
  const RegisteredEventsScreen({super.key});

  @override
  State<RegisteredEventsScreen> createState() => _RegisteredEventsScreenState();
}

class _RegisteredEventsScreenState extends State<RegisteredEventsScreen> {
  final AuthService _authService = const AuthService();

  String _selectedFilter = 'upcoming';

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
            future: _authService.getUserProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                );
              }

              final currentUser = FirebaseAuth.instance.currentUser;

              final studentId = currentUser?.uid ?? '';

              if (studentId.isEmpty) {
                return Center(
                  child: Text(
                    'Unable to load student data',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('event_registrations')
                    .where('studentId', isEqualTo: studentId)
                    .snapshots(),
                builder: (context, registrationSnapshot) {
                  if (registrationSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    );
                  }

                  final registrations = registrationSnapshot.data?.docs ?? [];

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .snapshots(),
                    builder: (context, eventSnapshot) {
                      final eventDocs = eventSnapshot.data?.docs ?? [];

                      final eventMap = {
                        for (final doc in eventDocs) doc.id: doc.data(),
                      };

                      final now = DateTime.now();

                      final filteredEvents = registrations.where((reg) {
                        final eventId = reg['eventId'];

                        final eventData = eventMap[eventId];

                        if (eventData == null) {
                          return false;
                        }

                        final eventDate = _readEventDate(
                          eventData,
                        );

                        if (eventDate == null) {
                          return false;
                        }

                        final isUpcoming = eventDate.isAfter(now);

                        return _selectedFilter == 'upcoming'
                            ? isUpcoming
                            : !isUpcoming;
                      }).toList();

                      filteredEvents.sort(
                        (a, b) {
                          final eventA = eventMap[a['eventId']];
                          final eventB = eventMap[b['eventId']];

                          final dateA = _readEventDate(
                                eventA,
                              ) ??
                              DateTime.now();

                          final dateB = _readEventDate(
                                eventB,
                              ) ??
                              DateTime.now();

                          return _selectedFilter == 'upcoming'
                              ? dateA.compareTo(
                                  dateB,
                                )
                              : dateB.compareTo(
                                  dateA,
                                );
                        },
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull,
                                    ),
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'My Registered Events',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'View and manage your registered club events.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildFilterTabs(),
                            const SizedBox(height: 20),
                            if (filteredEvents.isEmpty)
                              _buildEmptyState()
                            else
                              ...filteredEvents.map(
                                (registration) {
                                  final eventData =
                                      eventMap[registration['eventId']];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 14,
                                    ),
                                    child: _buildEventCard(
                                      registration.id,
                                      eventData,
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterButton(
              label: 'Upcoming',
              value: 'upcoming',
            ),
          ),
          Expanded(
            child: _buildFilterButton(
              label: 'Past',
              value: 'past',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required String value,
  }) {
    final isSelected = _selectedFilter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(
            AppTheme.radiusMd,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            color: AppTheme.primaryRedLight,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'No events found',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'upcoming'
                ? 'You have no upcoming registered events.'
                : 'You have no past registered events.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    String registrationId,
    Map<String, dynamic>? eventData,
  ) {
    final title = (eventData?['title'] ?? 'Untitled Event').toString();

    final description = (eventData?['description'] ?? '').toString();

    final location = (eventData?['location'] ?? '').toString();

    final creatorName = (eventData?['creatorName'] ?? 'Unknown').toString();

    final eventDate = _readEventDate(eventData);

    final canUnregister = eventDate != null &&
        eventDate.difference(
              DateTime.now(),
            ) >=
            const Duration(days: 2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                icon: Icons.schedule_rounded,
                label: eventDate == null
                    ? 'No date'
                    : _formatDateTime(
                        eventDate,
                      ),
              ),
              if (location.isNotEmpty)
                _buildChip(
                  icon: Icons.place_rounded,
                  label: location,
                ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Organized by $creatorName',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (_selectedFilter == 'upcoming') ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    AppTheme.radiusMd,
                  ),
                  onTap: canUnregister
                      ? () => _unregisterEvent(
                            registrationId,
                            title,
                          )
                      : null,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: canUnregister
                          ? AppTheme.primaryRed
                          : Colors.grey.withValues(
                              alpha: 0.25,
                            ),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMd,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        canUnregister
                            ? 'Unregister'
                            : 'Cannot unregister within 2 days',
                        textAlign: TextAlign.center,
                        style: AppTheme.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.06,
        ),
        borderRadius: BorderRadius.circular(
          AppTheme.radiusFull,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryRedLight,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unregisterEvent(
    String registrationId,
    String title,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          'Unregister Event',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to unregister from "$title"?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryRedLight,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unregister',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    await FirebaseFirestore.instance
        .collection('event_registrations')
        .doc(registrationId)
        .delete();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully unregistered from "$title"',
        ),
      ),
    );
  }

  DateTime? _readEventDate(
    Map<String, dynamic>? data,
  ) {
    final dynamic raw = data?['startAt'];

    if (raw is Timestamp) {
      return raw.toDate();
    }

    if (raw is DateTime) {
      return raw;
    }

    if (raw is String) {
      return DateTime.tryParse(raw);
    }

    return null;
  }

  String _formatDateTime(
    DateTime dateTime,
  ) {
    final local = dateTime.toLocal();

    const months = <String>[
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
      'Dec',
    ];

    final month = months[local.month - 1];

    final day = local.day.toString().padLeft(2, '0');

    final hour = local.hour.toString().padLeft(2, '0');

    final minute = local.minute.toString().padLeft(2, '0');

    return '$month $day, ${local.year} • $hour:$minute';
  }
}
