import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AnnouncementManagementScreen extends StatefulWidget {
  const AnnouncementManagementScreen({super.key});

  @override
  State<AnnouncementManagementScreen> createState() =>
      _AnnouncementManagementScreenState();
}

class _AnnouncementManagementScreenState
    extends State<AnnouncementManagementScreen> {
  static const AnnouncementService _announcementService = AnnouncementService();

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
              final role = (profileSnapshot.data?['role'] ?? '')
                  .toString()
                  .toLowerCase();
              final isCommittee = role == 'committee';

              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }

              if (!isCommittee) {
                return _buildAccessDenied();
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _announcementService.watchAnnouncements(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs.toList() ?? [];

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
                              'Announcement Manager',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create and publish updates for all club members.',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSummaryCard(docs),
                            const SizedBox(height: 20),
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                docs.isEmpty)
                              const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            else if (docs.isEmpty)
                              _buildEmptyState()
                            else
                              ...docs.map(
                                (doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildAnnouncementCard(
                                      doc.id, doc.data()),
                                ),
                              ),
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
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
                              onTap: _openCreateAnnouncementForm,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusMd),
                                  boxShadow: AppTheme.primaryShadow,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Create Announcement',
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

  Widget _buildAccessDenied() {
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
                'Only committee members can manage announcements.',
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

  Widget _buildSummaryCard(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final publishedCount = docs.where((doc) {
      return doc.data()['isPublished'] == true;
    }).length;

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
            child: const Icon(
              Icons.campaign_rounded,
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
                  '$publishedCount published',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${docs.length} total announcement${docs.length == 1 ? '' : 's'}',
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.campaign_outlined,
            color: AppTheme.primaryRedLight,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'No announcements yet',
            style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create the first update to show it on member dashboards.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
      String announcementId, Map<String, dynamic> data) {
    final title = (data['title'] ?? 'Untitled Announcement').toString();
    final message = (data['message'] ?? '').toString();
    final creatorName =
        (data['creatorName'] ?? data['creatorEmail'] ?? 'Unknown').toString();
    final isPublished = data['isPublished'] == true;
    final updatedAt =
        _readDate(data['updatedAt']) ?? _readDate(data['createdAt']);

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
                          icon: isPublished
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          label: isPublished ? 'Published' : 'Draft',
                        ),
                        if (updatedAt != null)
                          _buildChip(
                            icon: Icons.schedule_rounded,
                            label: _formatDateTime(updatedAt),
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
                    _openEditAnnouncementForm(announcementId, data);
                  } else if (value == 'delete') {
                    _confirmDelete(announcementId, title);
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
                        Icon(
                          Icons.delete_rounded,
                          size: 20,
                          color: AppTheme.primaryRed,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Delete',
                          style: TextStyle(color: AppTheme.primaryRed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              message,
              style:
                  AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
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

  Future<void> _openCreateAnnouncementForm() async {
    final result = await showDialog<_AnnouncementFormResult>(
      context: context,
      builder: (context) => const _AnnouncementFormDialog(),
    );

    if (result == null) return;

    final error = await _announcementService.createAnnouncement(
      title: result.title,
      message: result.message,
      isPublished: result.isPublished,
    );

    _showSnackBar(error, successMessage: 'Announcement created');
  }

  Future<void> _openEditAnnouncementForm(
    String announcementId,
    Map<String, dynamic> data,
  ) async {
    final result = await showDialog<_AnnouncementFormResult>(
      context: context,
      builder: (context) => _AnnouncementFormDialog(existingData: data),
    );

    if (result == null) return;

    final error = await _announcementService.updateAnnouncement(
      announcementId: announcementId,
      title: result.title,
      message: result.message,
      isPublished: result.isPublished,
    );

    _showSnackBar(error, successMessage: 'Announcement updated');
  }

  Future<void> _confirmDelete(String announcementId, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgDark,
        title: Text(
          'Delete announcement',
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
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryRedLight,
              ),
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

    final error = await _announcementService.deleteAnnouncement(announcementId);
    _showSnackBar(error, successMessage: 'Announcement deleted');
  }

  void _showSnackBar(String? error, {required String successMessage}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? successMessage)),
    );
  }

  DateTime? _readDate(dynamic raw) {
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

class _AnnouncementFormResult {
  const _AnnouncementFormResult({
    required this.title,
    required this.message,
    required this.isPublished,
  });

  final String title;
  final String message;
  final bool isPublished;
}

class _AnnouncementFormDialog extends StatefulWidget {
  const _AnnouncementFormDialog({this.existingData});

  final Map<String, dynamic>? existingData;

  @override
  State<_AnnouncementFormDialog> createState() =>
      _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState extends State<_AnnouncementFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late bool _isPublished;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: (widget.existingData?['title'] ?? '').toString(),
    );
    _messageController = TextEditingController(
      text: (widget.existingData?['message'] ?? '').toString(),
    );
    _isPublished = widget.existingData?['isPublished'] != false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.bgDark,
      title: Text(
        widget.existingData == null
            ? 'Create announcement'
            : 'Edit announcement',
        style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildField(controller: _titleController, label: 'Title'),
            const SizedBox(height: 12),
            _buildField(
              controller: _messageController,
              label: 'Message',
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _isPublished,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppTheme.primaryRedLight,
              title: Text(
                'Published',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                _isPublished
                    ? 'Visible on member dashboards'
                    : 'Saved as a draft',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isPublished = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryRedLight,
            ),
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

  void _submit() {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement title is required')),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement message is required')),
      );
      return;
    }

    Navigator.of(context).pop(
      _AnnouncementFormResult(
        title: title,
        message: message,
        isPublished: _isPublished,
      ),
    );
  }
}
