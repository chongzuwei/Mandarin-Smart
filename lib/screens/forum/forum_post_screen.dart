import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/forum_service.dart';
import '../../theme/app_theme.dart';

class ForumPostScreen extends StatefulWidget {
  const ForumPostScreen({
    super.key,
    required this.postId,
    required this.postData,
  });

  final String postId;
  final Map<String, dynamic> postData;

  @override
  State<ForumPostScreen> createState() => _ForumPostScreenState();
}

class _ForumPostScreenState extends State<ForumPostScreen> {
  static const ForumService _forumService = ForumService();

  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.postData['title'] ?? 'Untitled Discussion').toString();
    final body = (widget.postData['body'] ?? '').toString();
    final authorName = (widget.postData['authorName'] ?? 'User').toString();
    final createdAt = _readDate(widget.postData['createdAt']);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildPostCard(
                        title: title,
                        body: body,
                        authorName: authorName,
                        createdAt: createdAt,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Replies',
                        style: AppTheme.headingSmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _forumService.watchReplies(widget.postId),
                        builder: (context, snapshot) {
                          final replies = snapshot.data?.docs ?? [];

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              replies.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (replies.isEmpty) {
                            return _buildEmptyReplies();
                          }

                          return Column(
                            children: replies.map((doc) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildReplyCard(doc.id, doc.data()),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              _buildReplyComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
                color: AppTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Discussion',
            style: AppTheme.headingLarge.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard({
    required String title,
    required String body,
    required String authorName,
    required DateTime? createdAt,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildMetaChip(Icons.person_rounded, authorName),
              if (createdAt != null)
                _buildMetaChip(Icons.schedule_rounded, _formatDate(createdAt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyCard(String replyId, Map<String, dynamic> data) {
    final body = (data['body'] ?? '').toString();
    final authorName = (data['authorName'] ?? 'User').toString();
    final authorId = (data['authorId'] ?? '').toString();
    final createdAt = _readDate(data['createdAt']);
    final canDelete = FirebaseAuth.instance.currentUser?.uid == authorId;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildMetaChip(Icons.person_rounded, authorName),
                    if (createdAt != null)
                      _buildMetaChip(
                        Icons.schedule_rounded,
                        _formatDate(createdAt),
                      ),
                  ],
                ),
              ),
              if (canDelete)
                PopupMenuButton<String>(
                  color: AppTheme.surfaceLight,
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDeleteReply(replyId);
                    }
                  },
                  itemBuilder: (context) => const [
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
          const SizedBox(height: 12),
          Text(
            body,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReplies() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
      child: Text(
        'No replies yet. Be the first to respond.',
        textAlign: TextAlign.center,
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildReplyComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                minLines: 1,
                maxLines: 4,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a reply',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceLightAlt,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: BorderSide(
                      color: AppTheme.dividerColor.withValues(alpha: 0.9),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    borderSide: const BorderSide(color: AppTheme.primaryRed),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  onTap: _isSubmitting ? null : _submitReply,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: _isSubmitting
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryRed),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReply() async {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final error = await _forumService.addReply(
      postId: widget.postId,
      body: body,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (error == null) {
      _replyController.clear();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Reply posted')),
    );
  }

  Future<void> _confirmDeleteReply(String replyId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.lightTheme,
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceLight,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Delete reply',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Delete this reply? This cannot be undone.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
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
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (shouldDelete != true) return;

    final error = await _forumService.deleteReply(
      postId: widget.postId,
      replyId: replyId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Reply deleted')),
    );
  }

  DateTime? _readDate(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  String _formatDate(DateTime dateTime) {
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

    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '${months[local.month - 1]} ${local.day}, ${local.year} • $hour:$minute';
  }
}
