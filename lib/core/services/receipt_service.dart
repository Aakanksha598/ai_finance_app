import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ReceiptService {
  static final ImagePicker _picker = ImagePicker();
  static final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  // Capture receipt using camera
  static Future<File?> captureReceipt() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error capturing receipt: $e');
      return null;
    }
  }

  // Pick receipt from gallery
  static Future<File?> pickReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking receipt from gallery: $e');
      return null;
    }
  }

  // Process receipt image and extract information
  static Future<Map<String, dynamic>> processReceipt(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text;
      final result = _extractReceiptData(extractedText);

      // Save the image
      final savedPath = await _saveReceiptImage(imageFile);
      result['receiptPath'] = savedPath;

      return result;
    } catch (e) {
      print('Error processing receipt: $e');
      return {
        'error': 'Failed to process receipt: $e',
        'amount': 0.0,
        'merchant': '',
        'date': DateTime.now(),
        'category': 'other',
        'description': '',
      };
    }
  }

  // Extract data from receipt text
  static Map<String, dynamic> _extractReceiptData(String text) {
    final result = <String, dynamic>{
      'amount': 0.0,
      'merchant': '',
      'date': DateTime.now(),
      'category': 'other',
      'description': '',
    };

    final lines = text.split('\n');

    // Extract amount (look for total, grand total, etc.)
    final amountPatterns = [
      RegExp(r'total[\s:]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'grand total[\s:]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'amount[\s:]*\$?(\d+\.?\d*)', caseSensitive: false),
      RegExp(r'\$(\d+\.?\d*)', caseSensitive: false),
    ];

    for (final pattern in amountPatterns) {
      for (final line in lines) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          final amount = double.tryParse(match.group(1) ?? '');
          if (amount != null && amount > result['amount']) {
            result['amount'] = amount;
          }
        }
      }
    }

    // Extract merchant name (usually in first few lines)
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty && 
          !line.contains('receipt') && 
          !line.contains('total') && 
          !line.contains('date') &&
          !line.contains('time') &&
          !line.contains('cashier') &&
          !line.contains('register')) {
        result['merchant'] = line;
        break;
      }
    }

    // Extract date
    final datePatterns = [
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
      RegExp(r'(\d{1,2})\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\s+(\d{2,4})', caseSensitive: false),
    ];

    for (final pattern in datePatterns) {
      for (final line in lines) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          try {
            if (pattern == datePatterns[0]) {
              final month = int.parse(match.group(1) ?? '1');
              final day = int.parse(match.group(2) ?? '1');
              final year = int.parse(match.group(3) ?? '2024');
              result['date'] = DateTime(year, month, day);
            } else {
              final day = int.parse(match.group(1) ?? '1');
              final monthStr = match.group(2)?.toLowerCase() ?? 'jan';
              final year = int.parse(match.group(3) ?? '2024');
              final month = _getMonthNumber(monthStr);
              result['date'] = DateTime(year, month, day);
            }
            break;
          } catch (e) {
            // Continue to next pattern if parsing fails
          }
        }
      }
    }

    // Categorize based on merchant and items
    result['category'] = _categorizeReceipt(text, result['merchant']);

    // Generate description
    result['description'] = 'Receipt from ${result['merchant']}';

    return result;
  }

  // Save receipt image to app directory
  static Future<String> _saveReceiptImage(File imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final receiptsDir = Directory('${appDir.path}/receipts');
    
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }

    final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = File('${receiptsDir.path}/$fileName');
    
    await imageFile.copy(savedFile.path);
    return savedFile.path;
  }

  // Delete receipt image
  static Future<void> deleteReceiptImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting receipt image: $e');
    }
  }

  // Categorize receipt based on content
  static String _categorizeReceipt(String text, String merchant) {
    final lowerText = text.toLowerCase();
    final lowerMerchant = merchant.toLowerCase();

    // Food and dining
    if (lowerText.contains('restaurant') || 
        lowerText.contains('food') || 
        lowerText.contains('dinner') ||
        lowerText.contains('lunch') ||
        lowerText.contains('breakfast') ||
        lowerText.contains('coffee') ||
        lowerText.contains('pizza') ||
        lowerText.contains('burger') ||
        lowerMerchant.contains('restaurant') ||
        lowerMerchant.contains('cafe') ||
        lowerMerchant.contains('diner')) {
      return 'food';
    }

    // Groceries
    if (lowerText.contains('grocery') || 
        lowerText.contains('supermarket') ||
        lowerText.contains('market') ||
        lowerMerchant.contains('walmart') ||
        lowerMerchant.contains('target') ||
        lowerMerchant.contains('kroger') ||
        lowerMerchant.contains('safeway')) {
      return 'groceries';
    }

    // Transportation
    if (lowerText.contains('gas') || 
        lowerText.contains('fuel') ||
        lowerText.contains('uber') ||
        lowerText.contains('lyft') ||
        lowerText.contains('taxi') ||
        lowerText.contains('parking') ||
        lowerMerchant.contains('shell') ||
        lowerMerchant.contains('exxon') ||
        lowerMerchant.contains('chevron')) {
      return 'transport';
    }

    // Shopping
    if (lowerText.contains('clothing') || 
        lowerText.contains('shoes') ||
        lowerText.contains('electronics') ||
        lowerText.contains('amazon') ||
        lowerMerchant.contains('nike') ||
        lowerMerchant.contains('adidas') ||
        lowerMerchant.contains('apple') ||
        lowerMerchant.contains('best buy')) {
      return 'shopping';
    }

    // Entertainment
    if (lowerText.contains('movie') || 
        lowerText.contains('theater') ||
        lowerText.contains('concert') ||
        lowerText.contains('game') ||
        lowerText.contains('netflix') ||
        lowerText.contains('spotify')) {
      return 'entertainment';
    }

    // Health
    if (lowerText.contains('pharmacy') || 
        lowerText.contains('medical') ||
        lowerText.contains('doctor') ||
        lowerText.contains('medicine') ||
        lowerMerchant.contains('cvs') ||
        lowerMerchant.contains('walgreens')) {
      return 'health';
    }

    // Utilities
    if (lowerText.contains('electricity') || 
        lowerText.contains('water') ||
        lowerText.contains('internet') ||
        lowerText.contains('phone') ||
        lowerText.contains('wifi')) {
      return 'utilities';
    }

    return 'other';
  }

  // Helper method to get month number from string
  static int _getMonthNumber(String monthStr) {
    final months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'may': 5, 'jun': 6, 'jul': 7, 'aug': 8,
      'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    return months[monthStr] ?? 1;
  }

  // Dispose resources
  static Future<void> dispose() async {
    await _textRecognizer.close();
  }
}