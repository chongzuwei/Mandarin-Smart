import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  _ScanResult? _result;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  // ── Scan handler ────────────────────────────────────────────────
  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _result != null) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _isProcessing = true);

    try {
      final payload = jsonDecode(barcode.rawValue!) as Map<String, dynamic>;

      if (payload['type'] != 'attendance') {
        _setResult(_ScanResult.error('Invalid QR code — not an attendance QR.'));
        return;
      }

      final eventId = payload['eventId'] as String?;
      final eventTitle = payload['eventTitle'] as String?;
      final sessionId = payload['sessionId'] as String?;

      if (eventId == null || eventTitle == null || sessionId == null) {
        _setResult(_ScanResult.error('QR data is incomplete.'));
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _setResult(_ScanResult.error('You are not signed in.'));
        return;
      }

      // Check for duplicate attendance (same event + session + user)
      final existing = await FirebaseFirestore.instance
          .collection('attendance_records')
          .where('eventId', isEqualTo: eventId)
          .where('sessionId', isEqualTo: sessionId)
          .where('studentUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _setResult(_ScanResult.duplicate(eventTitle));
        return;
      }

      // Fetch student profile for name & extra info
      final profile = await const AuthService().getUserProfile();
      final studentName = (profile?['name'] ?? user.displayName ?? '').toString();
      final studentEmail = user.email ?? '';

      await FirebaseFirestore.instance.collection('attendance_records').add({
        'eventId': eventId,
        'eventTitle': eventTitle,
        'sessionId': sessionId,
        'studentUid': user.uid,
        'studentName': studentName,
        'studentEmail': studentEmail,
        'scannedAt': FieldValue.serverTimestamp(),
        'generatedBy': payload['generatedBy'] ?? '',
        'generatedByEmail': payload['generatedByEmail'] ?? '',
      });

      _setResult(_ScanResult.success(eventTitle));
    } on FormatException {
      _setResult(_ScanResult.error('Invalid QR format — could not read data.'));
    } catch (e) {
      _setResult(_ScanResult.error('Something went wrong: ${e.toString()}'));
    }
  }

  void _setResult(_ScanResult result) {
    if (!mounted) return;
    _scannerController.stop();
    setState(() {
      _result = result;
      _isProcessing = false;
    });
  }

  void _resetScanner() {
    setState(() {
      _result = null;
      _isProcessing = false;
    });
    _scannerController.start();
  }

  // ── Build ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: _result != null ? _buildResultView() : _buildScannerView(),
        ),
      ),
    );
  }

  // ── Scanner View ────────────────────────────────────────────────
  Widget _buildScannerView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
                'Scan Attendance QR',
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Point your camera at the QR code displayed by a committee member.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Camera preview
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(
                    controller: _scannerController,
                    onDetect: _onDetect,
                  ),

                  // Scanning overlay
                  _buildScanOverlay(),

                  // Loading indicator when processing
                  if (_isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Flash toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  label: 'Toggle Flash',
                  icon: Icons.flash_on_rounded,
                  onTap: () => _scannerController.toggleTorch(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildControlButton(
                  label: 'Switch Camera',
                  icon: Icons.cameraswitch_rounded,
                  onTap: () => _scannerController.switchCamera(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size.square(260),
          painter: _ScanFramePainter(
            color: AppTheme.primaryRedLight
                .withValues(alpha: 0.3 + 0.5 * _pulseAnimation.value),
            strokeWidth: 3,
            cornerLength: 30,
          ),
        );
      },
    );
  }

  // ── Result View ─────────────────────────────────────────────────
  Widget _buildResultView() {
    final result = _result!;

    final IconData icon;
    final Color iconColor;
    final String title;
    final String subtitle;

    switch (result.status) {
      case _ScanStatus.success:
        icon = Icons.check_circle_rounded;
        iconColor = const Color(0xFF4CAF50);
        title = 'Attendance Recorded!';
        subtitle =
            'Your attendance for "${result.eventTitle}" has been saved successfully.';
        break;
      case _ScanStatus.duplicate:
        icon = Icons.info_rounded;
        iconColor = AppTheme.accentGold;
        title = 'Already Checked In';
        subtitle =
            'You have already recorded attendance for "${result.eventTitle}" in this session.';
        break;
      case _ScanStatus.error:
        icon = Icons.error_rounded;
        iconColor = AppTheme.primaryRed;
        title = 'Scan Failed';
        subtitle = result.message ?? 'An unknown error occurred.';
        break;
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
          const SizedBox(height: 60),

          // Result card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(icon, color: iconColor, size: 44),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTheme.headingMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (result.status == _ScanStatus.success) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 16, color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Text(
                          _formattedNow(),
                          style: AppTheme.bodySmall.copyWith(
                            color: const Color(0xFF4CAF50),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          if (result.status == _ScanStatus.error ||
              result.status == _ScanStatus.duplicate)
            _buildPrimaryButton(
              label: 'Scan Again',
              icon: Icons.qr_code_scanner_rounded,
              onTap: _resetScanner,
            ),

          if (result.status == _ScanStatus.success)
            _buildPrimaryButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),

          const SizedBox(height: 12),

          if (result.status == _ScanStatus.success)
            _buildSecondaryButton(
              label: 'Scan Another',
              icon: Icons.qr_code_scanner_rounded,
              onTap: _resetScanner,
            ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────
  String _formattedNow() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months[now.month - 1];
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$m $d, ${now.year} • $h:$min';
  }

  Widget _buildPrimaryButton({
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
                Text(label,
                    style: AppTheme.buttonText.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
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
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: AppTheme.buttonText
                        .copyWith(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
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
              gradient: AppTheme.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppTheme.textPrimary, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: AppTheme.bodyMedium
                        .copyWith(color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Scan result model ───────────────────────────────────────────
enum _ScanStatus { success, duplicate, error }

class _ScanResult {
  const _ScanResult._({
    required this.status,
    this.eventTitle,
    this.message,
  });

  factory _ScanResult.success(String eventTitle) =>
      _ScanResult._(status: _ScanStatus.success, eventTitle: eventTitle);

  factory _ScanResult.duplicate(String eventTitle) =>
      _ScanResult._(status: _ScanStatus.duplicate, eventTitle: eventTitle);

  factory _ScanResult.error(String message) =>
      _ScanResult._(status: _ScanStatus.error, message: message);

  final _ScanStatus status;
  final String? eventTitle;
  final String? message;
}

// ── Custom scan-frame painter ───────────────────────────────────
class _ScanFramePainter extends CustomPainter {
  const _ScanFramePainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // Top-left
    canvas.drawLine(Offset.zero, Offset(cl, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, cl), paint);

    // Top-right
    canvas.drawLine(Offset(w, 0), Offset(w - cl, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cl), paint);

    // Bottom-left
    canvas.drawLine(Offset(0, h), Offset(cl, h), paint);
    canvas.drawLine(Offset(0, h), Offset(0, h - cl), paint);

    // Bottom-right
    canvas.drawLine(Offset(w, h), Offset(w - cl, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cl), paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter oldDelegate) =>
      color != oldDelegate.color;
}
