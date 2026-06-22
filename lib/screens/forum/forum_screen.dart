import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/forum_service.dart';
import '../../theme/app_theme.dart';
import 'forum_post_screen.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  static const ForumService _forumService = ForumService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _forumService.watchPosts(),
            builder: (context, snapshot) {
              final posts = snapshot.data?.docs ?? [];

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSummaryCard(posts.length),
                        const SizedBox(height: 20),
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            posts.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else if (posts.isEmpty)
                          _buildEmptyState()
                        else
                          ...posts.map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _buildPostCard(doc.id, doc.data()),
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
                          onTap: _openCreatePostDialog,
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
                                  Icons.add_comment_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'New Discussion',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Forum',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ask questions and discuss club activities.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(int postCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(
              Icons.forum_rounded,
              color: AppTheme.primaryRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$postCount discussion${postCount == 1 ? '' : 's'}',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Share updates, questions, and event feedback.',
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
      decoration: AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
      child: Column(
        children: [
          const Icon(
            Icons.forum_outlined,
            color: AppTheme.primaryRed,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            'No discussions yet',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the first forum post for members to reply to.',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(String postId, Map<String, dynamic> data) {
    final title = (data['title'] ?? 'Untitled Discussion').toString();
    final body = (data['body'] ?? '').toString();
    final authorName = (data['authorName'] ?? 'User').toString();
    final authorId = (data['authorId'] ?? '').toString();
    final replyCount =
        data['replyCount'] is int ? data['replyCount'] as int : 0;
    final createdAt = _readDate(data['createdAt']);
    final canDelete = FirebaseAuth.instance.currentUser?.uid == authorId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ForumPostScreen(
                postId: postId,
                postData: data,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration:
              AppTheme.buildCardDecoration(borderRadius: AppTheme.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.headingSmall.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (canDelete)
                    PopupMenuButton<String>(
                      color: AppTheme.surfaceLight,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDeletePost(postId, title);
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
              if (body.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildMetaChip(Icons.person_rounded, authorName),
                  _buildMetaChip(
                    Icons.chat_bubble_outline_rounded,
                    '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
                  ),
                  if (createdAt != null)
                    _buildMetaChip(
                        Icons.schedule_rounded, _formatDate(createdAt)),
                ],
              ),
            ],
          ),
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

  Future<void> _openCreatePostDialog() async {
    final result = await showDialog<_ForumPostFormResult>(
      context: context,
      builder: (context) => const _ForumPostDialog(),
    );

    if (result == null) return;

    final error = await _forumService.createPost(
      title: result.title,
      body: result.body,
    );

    _showSnackBar(error, successMessage: 'Discussion posted');
  }

  Future<void> _confirmDeletePost(String postId, String title) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: AppTheme.lightTheme,
        child: AlertDialog(
          backgroundColor: AppTheme.surfaceLight,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Delete discussion',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Delete "$title"? This cannot be undone.',
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

    final error = await _forumService.deletePost(postId);
    _showSnackBar(error, successMessage: 'Discussion deleted');
  }

  void _showSnackBar(String? error, {required String successMessage}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? successMessage)),
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

    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }
}

class _ForumPostFormResult {
  const _ForumPostFormResult({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class _ForumPostDialog extends StatefulWidget {
  const _ForumPostDialog();

  @override
  State<_ForumPostDialog> createState() => _ForumPostDialogState();
}

class _ForumPostDialogState extends State<_ForumPostDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: AlertDialog(
        backgroundColor: AppTheme.surfaceLight,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: AppTheme.dividerColor.withValues(alpha: 0.8)),
        ),
        title: Text(
          'New discussion',
          style: AppTheme.headingMedium.copyWith(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(controller: _titleController, label: 'Title'),
              const SizedBox(height: 12),
              _buildField(
                controller: _bodyController,
                label: 'Message',
                maxLines: 5,
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
              'Post',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRed),
            ),
          ),
        ],
      ),
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
      cursorColor: AppTheme.primaryRed,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        filled: true,
        fillColor: AppTheme.surfaceLightAlt,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(
            color: AppTheme.dividerColor.withValues(alpha: 0.9),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppTheme.primaryRed),
        ),
      ),
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required')),
      );
      return;
    }

    Navigator.of(context).pop(
      _ForumPostFormResult(title: title, body: body),
    );
  }
}
