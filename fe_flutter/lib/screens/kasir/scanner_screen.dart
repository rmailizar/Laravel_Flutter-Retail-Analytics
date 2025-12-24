import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _found = false;
  late MobileScannerController cameraController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      
      await cameraController.start();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View or Error
          if (_error != null)
            _buildError()
          else if (!_isInitialized)
            _buildLoading()
          else
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (_found) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;
                final code = barcodes.first.rawValue ?? barcodes.first.displayValue;
                if (code == null || code.isEmpty) return;
                
                setState(() => _found = true);
                
                // Vibrate or show feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Barcode terdeteksi: $code'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Close after short delay
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    Navigator.of(context).pop(code);
                  }
                });
              },
            ),
          // Overlay
          if (_isInitialized)
            CustomPaint(
              painter: ScannerOverlay(),
              child: Container(),
            ),
          // Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Scan Barcode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (_isInitialized)
                    Material(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => cameraController.toggleTorch(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.flashlight_on_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Bottom Instructions
          if (_isInitialized)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Arahkan kamera ke barcode\nproduk untuk scan otomatis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF2DD4BF),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat kamera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak dapat mengakses kamera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan browser memiliki izin akses kamera',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isInitialized = false;
                });
                _initializeScanner();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DD4BF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kembali',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanArea = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw darkened overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(20))),
      ),
      paint,
    );

    // Draw corner borders
    final borderPaint = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final cornerLength = 30.0;
    
    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top)
        ..lineTo(left + cornerLength, top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top)
        ..lineTo(left + scanAreaSize, top)
        ..lineTo(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - cornerLength)
        ..lineTo(left, top + scanAreaSize)
        ..lineTo(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - cornerLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize)
        ..lineTo(left + scanAreaSize, top + scanAreaSize - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
