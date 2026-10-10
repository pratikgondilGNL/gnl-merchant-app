import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../routing/app_routes.dart';
import '../../../shared/widgets/global_app_bar.dart';

class ScanQRScreen extends StatefulWidget {
  const ScanQRScreen({super.key});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  late final AnimationController _scanController;
  late final Animation<double> _scanAnimation;

  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncScannerWithRoute();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  void _syncScannerWithRoute() {
    if (!mounted) return;
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrent) {
      _handled = false;
      unawaited(_resumeScanner());
    } else {
      unawaited(_scannerController.stop());
    }
  }

  Future<void> _resumeScanner() async {
    try {
      await _scannerController.start();
    } catch (_) {
      // The camera may still be starting up; the scanner widget handles it.
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final token = barcode.rawValue;
      if (token == null || token.isEmpty) continue;
      _handled = true;
      context.pushReplacementNamed(
        AppRoutes.scanQrDetails,
        queryParameters: {'qr': token},
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: GlobalAppBar(title: 'QR Scanner'),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(
                        color: AppColors.hint,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = constraints.maxWidth;
                          return Center(
                            child: Container(
                              width: size,
                              height: size,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: MobileScanner(
                                      controller: _scannerController,
                                      onDetect: _onDetect,
                                      placeholderBuilder: (context) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      errorBuilder:
                                          _buildScannerError,
                                    ),
                                  ),
                                  Center(
                                    child: SizedBox(
                                      width: size * 0.65,
                                      height: size * 0.65,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: _cornerPiece(
                                              borderTop: true,
                                              borderLeft: true,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: _cornerPiece(
                                              borderTop: true,
                                              borderRight: true,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            child: _cornerPiece(
                                              borderBottom: true,
                                              borderLeft: true,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: _cornerPiece(
                                              borderBottom: true,
                                              borderRight: true,
                                            ),
                                          ),
                                          AnimatedBuilder(
                                            animation: _scanAnimation,
                                            builder: (context, child) {
                                              return Positioned(
                                                top: _scanAnimation.value *
                                                    (size * 0.65),
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 2,
                                                  decoration:
                                                      const BoxDecoration(
                                                    gradient:
                                                        LinearGradient(
                                                      colors: [
                                                        Colors.transparent,
                                                        AppColors
                                                            .primaryDark,
                                                        Colors.transparent,
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerError(
    BuildContext context,
    MobileScannerException error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: AppColors.hint,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to access the camera. Please grant camera permission.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.hint, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              error.errorCode.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.hint, fontSize: 12),
            ),
            const SizedBox(height: 24),
            Material(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _resumeScanner(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  Widget _cornerPiece({
    bool borderTop = false,
    bool borderBottom = false,
    bool borderLeft = false,
    bool borderRight = false,
  }) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: borderTop
              ? const BorderSide(color: AppColors.primaryDark, width: 3)
              : BorderSide.none,
          bottom: borderBottom
              ? const BorderSide(color: AppColors.primaryDark, width: 3)
              : BorderSide.none,
          left: borderLeft
              ? const BorderSide(color: AppColors.primaryDark, width: 3)
              : BorderSide.none,
          right: borderRight
              ? const BorderSide(color: AppColors.primaryDark, width: 3)
              : BorderSide.none,
        ),
      ),
    );
  }
}
