import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Our own result type (named differently to avoid clashing with barcode_scan2)
class BookScan {
  final String raw;        // exact scanned text
  final String normalized; // ISBN-13 if we can normalize; else raw
  final BarcodeFormat format;

  BookScan({
    required this.raw,
    required this.normalized,
    required this.format,
  });
}

/// Push a camera page, scan once, and pop back with a BookScan.
Future<BookScan?> scanWithCamera(BuildContext context) {
  return Navigator.push<BookScan?>(
    context,
    MaterialPageRoute(builder: (_) => const _ScannerPage()),
  );
}

class _ScannerPage extends StatefulWidget {
  const _ScannerPage();

  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  final _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    formats: const [
      // Retail ISBN + typical library formats
      BarcodeFormat.ean13, BarcodeFormat.ean8,
      BarcodeFormat.upcA,  BarcodeFormat.upcE,
      BarcodeFormat.code128, BarcodeFormat.code39,
      BarcodeFormat.itf,    BarcodeFormat.codabar,
    ],
  );

  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan a book barcode'),
        actions: [
          IconButton(
            onPressed: _controller.toggleTorch,
            icon: const Icon(Icons.flashlight_on),
            tooltip: 'Toggle torch',
          )
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture cap) async {
              if (_handled) return;
              for (final b in cap.barcodes) {
                final raw = b.rawValue;
                if (raw == null || raw.isEmpty) continue;

                _handled = true;
                await _controller.stop();

                final normalized = _normalize(raw);
                if (!mounted) return;
                Navigator.pop(
                  context,
                  BookScan(raw: raw.trim(), normalized: normalized, format: b.format),
                );
                break;
              }
            },
          ),
          // simple aiming box helps with 1D codes
          Center(
            child: Container(
              width: 260,
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- helpers ----

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');

    // EAN-13 (978/979)
    if (digits.length == 13 && (digits.startsWith('978') || digits.startsWith('979'))) {
      return _validEan13(digits) ? digits : raw.trim();
    }
    // ISBN-10 -> ISBN-13
    if (digits.length == 10) {
      final ean13 = _isbn10To13(digits);
      return _validEan13(ean13) ? ean13 : raw.trim();
    }
    // UPC-A (12) -> EAN-13 with leading 0
    if (digits.length == 12) {
      final ean13 = '0$digits';
      return _validEan13(ean13) ? ean13 : raw.trim();
    }
    // Likely a library copy ID; return as-is
    return raw.trim();
  }

  bool _validEan13(String code) {
    if (!RegExp(r'^\d{13}$').hasMatch(code)) return false;
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final d = code.codeUnitAt(i) - 48;
      sum += (i.isOdd ? 3 : 1) * d;
    }
    final check = (10 - (sum % 10)) % 10;
    return check == (code.codeUnitAt(12) - 48);
  }

  String _isbn10To13(String isbn10) {
    final core = isbn10.substring(0, 9);
    final base = '978$core';
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final d = base.codeUnitAt(i) - 48;
      sum += (i.isOdd ? 3 : 1) * d;
    }
    final check = (10 - (sum % 10)) % 10;
    return '$base$check';
  }
}
