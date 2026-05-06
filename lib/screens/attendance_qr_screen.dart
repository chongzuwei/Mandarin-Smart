import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../theme/app_theme.dart';

class AttendanceQrScreen extends StatefulWidget {
  const AttendanceQrScreen({super.key});

  @override
  State<AttendanceQrScreen> createState() => _AttendanceQrScreenState();
}

class _AttendanceQrScreenState extends State<AttendanceQrScreen> {
  String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  String? _selectedEventId;
  String? _selectedEventTitle;
  String? _payload;

  @override
  void initState() {
    super.initState();
  }

  String _buildPayload() {
    final user = FirebaseAuth.instance.currentUser;

    return jsonEncode({
      'type': 'attendance',
      'eventId': _selectedEventId,
      'eventTitle': _selectedEventTitle,
      'sessionId': _sessionId,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'generatedBy': user?.uid ?? 'unknown',
      'generatedByEmail': user?.email ?? '',
    });
  }

  void _generateQr() {
    if (_selectedEventId == null || _selectedEventTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event first')),
      );
      return;
    }

    setState(() {
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _payload = _buildPayload();
    });
  }

  void _regenerateQr() {
    if (_payload == null) {
      _generateQr();
      return;
    }

    setState(() {
      _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
      _payload = _buildPayload();
    });
  }

  Future<void> _copyPayload() async {
    if (_payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate the event QR first')),
      );
      return;
    }

    final payloadToCopy = _payload!;
    await Clipboard.setData(ClipboardData(text: payloadToCopy));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance QR payload copied')),
    );
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
            future: const AuthService().getUserProfile(),
            builder: (context, snapshot) {
              final role = (snapshot.data?['role'] ?? '').toString().toLowerCase();
              final isCommittee = role == 'committee';

              if (snapshot.connectionState == ConnectionState.waiting) {
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
                            'Only committee members can generate attendance QR codes.',
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

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                              child: Icon(Icons.arrow_back_ios_new,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Attendance QR',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Select an event, then share the generated QR so students can check in.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildEventSelector(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          onTap: _generateQr,
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              boxShadow: AppTheme.primaryShadow,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Generate for Event',
                                  style: AppTheme.buttonText.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            child: QrImageView(
                              data: _payload ?? 'attendance:no-event-selected',
                              size: 240,
                              backgroundColor: Colors.white,
                              version: QrVersions.auto,
                              gapless: true,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _selectedEventTitle == null
                                ? 'No event selected yet'
                                : 'Event: $_selectedEventTitle',
                            textAlign: TextAlign.center,
                            style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _payload == null
                                ? 'Pick an event and tap Generate for Event.'
                                : 'Session ID: $_sessionId',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildButton(
                            label: 'Regenerate',
                            icon: Icons.refresh_rounded,
                            onTap: _regenerateQr,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildButton(
                            label: 'Copy Data',
                            icon: Icons.copy_rounded,
                            onTap: _copyPayload,
                          ),
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

  Widget _buildEventSelector() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Text(
        'Unable to load events. Please sign in again.',
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.primaryRedLight),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: const EventService().watchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(
                  'Loading events...',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        final eventDocs = snapshot.data?.docs ?? [];

        if (eventDocs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'No events found. Create an event first to generate event-specific attendance QR.',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          );
        }

        final selectedStillExists = eventDocs.any((doc) => doc.id == _selectedEventId);
        final selectedId = selectedStillExists ? _selectedEventId : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              dropdownColor: AppTheme.bgDark,
              iconEnabledColor: AppTheme.textSecondary,
              hint: Text(
                'Select event',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              items: eventDocs.map((doc) {
                final data = doc.data();
                final title = (data['title'] ?? data['name'] ?? data['eventName'] ?? 'Untitled Event')
                    .toString();

                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                Map<String, dynamic>? selectedData;
                for (final doc in eventDocs) {
                  if (doc.id == value) {
                    selectedData = doc.data();
                    break;
                  }
                }
                final selectedTitle = (selectedData?['title'] ??
                        selectedData?['name'] ??
                        selectedData?['eventName'] ??
                        'Untitled Event')
                    .toString();

                setState(() {
                  _selectedEventId = value;
                  _selectedEventTitle = value == null ? null : selectedTitle;
                  _payload = null;
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.primaryShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTheme.buttonText.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}