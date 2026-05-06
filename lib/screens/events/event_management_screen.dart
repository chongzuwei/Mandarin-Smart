import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/event_service.dart';
import '../../theme/app_theme.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({super.key});

  @override
  State<EventManagementScreen> createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  static const EventService _eventService = EventService();

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
            builder: (context, profileSnapshot) {
              final role = (profileSnapshot.data?['role'] ?? '').toString().toLowerCase();
              final isCommittee = role == 'committee';

              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              if (!isCommittee) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppTheme.primaryRedLight,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Committee only',
                            style: AppTheme.headingMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Only committee members can create, update, or delete events.',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _eventService.watchEvents(),
                builder: (context, eventSnapshot) {
                  final docs = eventSnapshot.data?.docs.toList() ?? [];
                  docs.sort((left, right) {
                    final leftDate = _readEventDate(left.data());
                    final rightDate = _readEventDate(right.data());

                    if (leftDate == null && rightDate == null) return 0;
                    if (leftDate == null) return 1;
                    if (rightDate == null) return -1;
                    return leftDate.compareTo(rightDate);
                  });

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
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
                              'Event Manager',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create, update, and remove club events from one place.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSummaryCard(docs.length),
                            const SizedBox(height: 20),
                            if (eventSnapshot.connectionState == ConnectionState.waiting && docs.isEmpty)
                              const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            else if (docs.isEmpty)
                              _buildEmptyState()
                            else
                              ...docs.map((doc) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildEventCard(doc.id, doc.data()),
                                );
                              }),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        child: SizedBox(
                          height: 54,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              onTap: _openCreateEventForm,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  boxShadow: AppTheme.primaryShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Create Event',
                                      style: AppTheme.buttonText.copyWith(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(Icons.event_rounded, color: AppTheme.primaryRedLight, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$eventCount event${eventCount == 1 ? '' : 's'}',
                  style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage the event schedule used by attendance QR generation.',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
            'No events yet',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create the first event to make it available for attendance QR sessions.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String eventId, Map<String, dynamic> data) {
    final title = (data['title'] ?? data['name'] ?? data['eventName'] ?? 'Untitled Event')
        .toString();
    final description = (data['description'] ?? '').toString();
    final location = (data['location'] ?? '').toString();
    final creatorName = (data['creatorName'] ?? data['creatorEmail'] ?? 'Unknown').toString();
    final eventDate = _readEventDate(data);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                      style: AppTheme.headingSmall.copyWith(color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChip(
                          icon: Icons.schedule_rounded,
                          label: eventDate == null ? 'No date set' : _formatDateTime(eventDate),
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
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: AppTheme.textSecondary.withValues(alpha: 0.9),
                ),
                color: AppTheme.bgDark,
                onSelected: (value) {
                  if (value == 'edit') {
                    _openEditEventForm(eventId, data);
                  } else if (value == 'delete') {
                    _confirmDelete(eventId, title);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 20, color: AppTheme.primaryRed),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppTheme.primaryRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              description,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            'Created by $creatorName',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryRedLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  DateTime? _readEventDate(Map<String, dynamic> data) {
    final dynamic raw = data['startAt'] ?? data['eventDate'] ?? data['dateTime'];

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
    final months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[local.month - 1];
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$month $day, ${local.year} • $hour:$minute';
  }

  Future<void> _openCreateEventForm() async {
    final result = await showDialog<_EventFormResult>(
      context: context,
      builder: (context) => const _EventFormDialog(),
    );

    if (result == null) return;

    final error = await _eventService.createEvent(
      title: result.title,
      startAt: result.startAt,
      location: result.location,
      description: result.description,
    );

    _showSnackBar(error, successMessage: 'Event created');
  }

  Future<void> _openEditEventForm(String eventId, Map<String, dynamic> data) async {
    final result = await showDialog<_EventFormResult>(
      context: context,
      builder: (context) => _EventFormDialog(existingData: data),
    );

    if (result == null) return;

    final error = await _eventService.updateEvent(
      eventId: eventId,
      title: result.title,
      startAt: result.startAt,
      location: result.location,
      description: result.description,
    );

    _showSnackBar(error, successMessage: 'Event updated');
  }

  Future<void> _confirmDelete(String eventId, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          'Delete event',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Delete "$title"? This cannot be undone.',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRedLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    final error = await _eventService.deleteEvent(eventId);
    _showSnackBar(error, successMessage: 'Event deleted');
  }

  void _showSnackBar(String? error, {required String successMessage}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? successMessage)),
    );
  }
}

class _EventFormResult {
  const _EventFormResult({
    required this.title,
    required this.startAt,
    required this.location,
    required this.description,
  });

  final String title;
  final DateTime startAt;
  final String location;
  final String description;
}

class _EventFormDialog extends StatefulWidget {
  const _EventFormDialog({this.existingData});

  final Map<String, dynamic>? existingData;

  @override
  State<_EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<_EventFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: (widget.existingData?['title'] ?? widget.existingData?['name'] ?? widget.existingData?['eventName'] ?? '')
          .toString(),
    );
    _locationController = TextEditingController(
      text: (widget.existingData?['location'] ?? '').toString(),
    );
    _descriptionController = TextEditingController(
      text: (widget.existingData?['description'] ?? '').toString(),
    );
    _selectedDateTime = _readExistingDateTime(widget.existingData) ??
        DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bgDark,
      title: Text(
        widget.existingData == null ? 'Create event' : 'Edit event',
        style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(controller: _titleController, label: 'Event title'),
            const SizedBox(height: 12),
            _buildField(controller: _locationController, label: 'Location'),
            const SizedBox(height: 12),
            _buildField(
              controller: _descriptionController,
              label: 'Description',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event date and time',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatLocalDateTime(_selectedDateTime),
                      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRedLight),
          ),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            'Save',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRed),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
      cursorColor: AppTheme.primaryRedLight,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primaryRedLight),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (!mounted || pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (!mounted || pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event title is required')),
      );
      return;
    }

    Navigator.of(context).pop(
      _EventFormResult(
        title: title,
        startAt: _selectedDateTime,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  DateTime? _readExistingDateTime(Map<String, dynamic>? data) {
    final dynamic raw = data?['startAt'] ?? data?['eventDate'] ?? data?['dateTime'];

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

  String _formatLocalDateTime(DateTime dateTime) {
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