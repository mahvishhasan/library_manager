import 'package:barcode_scan2/barcode_scan2.dart';

class BarcodeService {
  Future<String?> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      return result.rawContent.isNotEmpty ? result.rawContent : null;
    } catch (e) {
      return null;
    }
  }
}
