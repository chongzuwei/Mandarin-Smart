import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';

class EventRegistrationScreen extends StatefulWidget {
  const EventRegistrationScreen({super.key});

  @override
  State<EventRegistrationScreen> createState() =>
      _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  static const EventService _eventService = EventService();

  late final Future<Map<String, dynamic>?> _profileFuture;

  Set<String> _registeredEvents = {};

  @override
  void initState() {
    super.initState();
    _profileFuture = const AuthService().getUserProfile();
    _loadRegisteredEvents();
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
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _eventService.watchEvents(),
                builder: (context, eventSnapshot) {
                  final now = DateTime.now();

                  final docs =
                      (eventSnapshot.data?.docs.toList() ?? []).where((doc) {
                    final eventDate = _readEventDate(doc.data());

                    if (eventDate == null) {
                      return false;
                    }

                    return eventDate.isAfter(now);
                  }).toList();

                  docs.sort((left, right) {
                    final leftDate = _readEventDate(left.data());
                    final rightDate = _readEventDate(right.data());

                    if (leftDate == null && rightDate == null) {
                      return 0;
                    }

                    if (leftDate == null) return 1;
                    if (rightDate == null) return -1;

                    return leftDate.compareTo(rightDate);
                  });

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
                          'Event Registration',
                          style: AppTheme.headingLarge.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Browse upcoming club events and register instantly.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSummaryCard(docs.length),
                        const SizedBox(height: 20),
                        if (eventSnapshot.connectionState ==
                                ConnectionState.waiting &&
                            docs.isEmpty)
                          const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        else if (docs.isEmpty)
                          _buildEmptyState()
                        else
                          ...docs.map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 14,
                              ),
                              child: _buildEventCard(
                                doc.id,
                                doc.data(),
                              ),
                            ),
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

  Widget _buildSummaryCard(int eventCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(
                AppTheme.radiusMd,
              ),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppTheme.primaryRedLight,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$eventCount upcoming event${eventCount == 1 ? '' : 's'}',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Register and secure your participation for upcoming activities.',
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
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
            'No events available',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no upcoming events open for registration.',
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
    String eventId,
    Map<String, dynamic> data,
  ) {
    final title =
        (data['title'] ?? data['name'] ?? data['eventName'] ?? 'Untitled Event')
            .toString();

    final description = (data['description'] ?? '').toString();

    final location = (data['location'] ?? '').toString();

    final creatorName = (data['creatorName'] ?? 'Unknown').toString();

    final eventDate = _readEventDate(data);

    final isRegistered = _registeredEvents.contains(eventId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLg,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          icon: Icons.schedule_rounded,
                          label: eventDate == null
                              ? 'No date set'
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
                  ],
                ),
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
                onTap: isRegistered
                    ? null
                    : () => _confirmRegister(
                          eventId,
                          title,
                        ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: isRegistered ? null : AppTheme.primaryGradient,
                    color: isRegistered
                        ? Colors.green.withValues(alpha: 0.18)
                        : null,
                    borderRadius: BorderRadius.circular(
                      AppTheme.radiusMd,
                    ),
                    border: Border.all(
                      color: isRegistered
                          ? Colors.green.withValues(
                              alpha: 0.35,
                            )
                          : Colors.transparent,
                    ),
                    boxShadow: isRegistered ? [] : AppTheme.primaryShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRegistered
                            ? Icons.check_circle_rounded
                            : Icons.app_registration_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRegistered ? 'Registered' : 'Register Event',
                        style: AppTheme.buttonText.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
        color: Colors.white.withValues(alpha: 0.06),
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

  Future<void> _loadRegisteredEvents() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('event_registrations')
        .where(
          'studentId',
          isEqualTo: currentUser.uid,
        )
        .get();

    final registeredIds = snapshot.docs
        .map(
          (doc) => doc['eventId'].toString(),
        )
        .toSet();

    if (!mounted) return;

    setState(() {
      _registeredEvents = registeredIds;
    });
  }

  Future<void> _confirmRegister(
    String eventId,
    String title,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          'Confirm Registration',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to register for "$title"?',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryRedLight,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _registerForEvent(eventId, title);
    }
  }

  Future<void> _registerForEvent(
    String eventId,
    String title,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    final existingRegistration = await FirebaseFirestore.instance
        .collection('event_registrations')
        .where(
          'studentId',
          isEqualTo: currentUser.uid,
        )
        .where(
          'eventId',
          isEqualTo: eventId,
        )
        .get();

    if (!mounted) return;

    if (existingRegistration.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You already registered for this event'),
        ),
      );

      return;
    }

    await FirebaseFirestore.instance.collection('event_registrations').add({
      'studentId': currentUser.uid,
      'studentEmail': currentUser.email,
      'eventId': eventId,
      'registeredAt': Timestamp.now(),
    });

    if (!mounted) return;

    setState(() {
      _registeredEvents.add(eventId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Successfully registered for "$title"',
        ),
      ),
    );
  }

  DateTime? _readEventDate(
    Map<String, dynamic> data,
  ) {
    final dynamic raw =
        data['startAt'] ?? data['eventDate'] ?? data['dateTime'];

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

  String _formatDateTime(DateTime dateTime) {
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
