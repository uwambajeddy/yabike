import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptData {
  final double? amount;
  final DateTime? date;
  final String? merchantName;
  final double confidence; // 0.0 to 1.0
  final String? errorMessage;

  ReceiptData({
    this.amount, 
    this.date, 
    this.merchantName,
    this.confidence = 0.0,
    this.errorMessage,
  });
  
  bool get hasData => amount != null || date != null || merchantName != null;
  bool get isLowConfidence => confidence < 0.5;
  
  @override
  String toString() => 'ReceiptData(amount: $amount, date: $date, merchant: $merchantName, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
}

class ReceiptScannerService {
  final _textRecognizer = TextRecognizer();
  final _imagePicker = ImagePicker();

  Future<ReceiptData?> scanReceiptFromCamera() async {
    try {
      debugPrint('Opening camera for receipt scanning...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100, // High quality for better OCR
      );
      
      if (image == null) {
        debugPrint('User cancelled camera');
        return null;
      }
      
      return await _processImage(File(image.path));
    } catch (e) {
      debugPrint('Error scanning from camera: $e');
      return ReceiptData(errorMessage: 'Failed to access camera. Please check permissions.');
    }
  }

  Future<ReceiptData?> scanReceiptFromGallery() async {
    try {
      debugPrint('Opening gallery for receipt scanning...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      
      if (image == null) {
        debugPrint('User cancelled gallery picker');
        return null;
      }
      
      return await _processImage(File(image.path));
    } catch (e) {
      debugPrint('Error scanning from gallery: $e');
      return ReceiptData(errorMessage: 'Failed to access gallery. Please check permissions.');
    }
  }

  Future<ReceiptData> _processImage(File imageFile) async {
    try {
      debugPrint('Processing image: ${imageFile.path}');
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final text = recognizedText.text;
      debugPrint('Recognized text length: ${text.length} characters');
      
      if (text.isEmpty) {
        debugPrint('No text recognized in image');
        return ReceiptData(
          confidence: 0.0,
          errorMessage: 'No text found in image. Please try again with better lighting.',
        );
      }
      
      debugPrint('Recognized text: $text');
      final result = _parseText(text);
      debugPrint('Parsed result: $result');
      
      return result;
    } catch (e) {
      debugPrint('Error processing image: $e');
      return ReceiptData(
        confidence: 0.0,
        errorMessage: 'Failed to process image. Please try again.',
      );
    }
  }

  ReceiptData _parseText(String text) {
    double? amount;
    DateTime? date;
    String? merchant;
    
    final lines = text.split('\n');
    
    // 1. Find Merchant - Look for recognizable business names
    // Priority: Look for lines with common business keywords or clean text
    for (var line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.isEmpty || cleanLine.length < 3) continue;
      
      // Skip lines that are mostly garbage (too many special chars)
      final alphaNumCount = cleanLine.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').length;
      if (alphaNumCount < cleanLine.length * 0.4) continue;
      
      // Look for business-related keywords
      if (cleanLine.toLowerCase().contains('market') ||
          cleanLine.toLowerCase().contains('store') ||
          cleanLine.toLowerCase().contains('shop') ||
          cleanLine.toLowerCase().contains('restaurant') ||
          cleanLine.toLowerCase().contains('cafe') ||
          cleanLine.toLowerCase().contains('nutrition') ||
          cleanLine.toLowerCase().contains('pharmacy')) {
        merchant = cleanLine;
        break;
      }
      
      // If no keyword found, use first clean line with reasonable length
      if (merchant == null && cleanLine.length > 5 && cleanLine.length < 50 && 
          !RegExp(r'^\d').hasMatch(cleanLine)) {
        merchant = cleanLine;
      }
    }
    
    // 2. Find Date - More flexible patterns
    // Matches: DD/MM/YYYY, MM/DD/YYYY, YYYY-MM-DD, DD-MM-YY, etc.
    final dateRegex = RegExp(r'\b(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})\b');
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      try {
        final dateStr = dateMatch.group(1)!;
        final parts = dateStr.split(RegExp(r'[/-]'));
        if (parts.length == 3) {
          int p1 = int.parse(parts[0]);
          int p2 = int.parse(parts[1]);
          int p3 = int.parse(parts[2]);
          
          // Guess year
          int year = p3 > 100 ? p3 : 2000 + p3;
          
          // Guess month/day (DD/MM/YYYY format common in Rwanda)
          int month = p2;
          int day = p1;
          if (p1 > 12 && p2 <= 12) {
            month = p2;
            day = p1;
          } else if (p2 > 12 && p1 <= 12) {
            month = p1;
            day = p2;
          }
          
          date = DateTime(year, month, day);
        }
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }
    
    // 3. Find Amount - More flexible patterns
    // Look for currency symbols and numbers
    final amountPatterns = [
      RegExp(r'(?:total|amount|pay|frw|rwf)[:\s]*(\d{1,10}(?:[.,]\d{2,3})?)', caseSensitive: false),
      RegExp(r'(\d{1,10}(?:[.,]\d{2,3})?)\s*(?:frw|rwf)', caseSensitive: false),
      RegExp(r'(?:[\$€£])\s*(\d{1,10}(?:[.,]\d{2,3})?)'),
      RegExp(r'(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})'), // Standard currency format
    ];
    
    double maxAmount = 0.0;
    bool foundTotal = false;
    
    // Try each pattern
    for (var pattern in amountPatterns) {
      for (var line in lines) {
        final match = pattern.firstMatch(line);
        if (match != null) {
          String amountStr = match.group(1)!;
          
          // Normalize amount string
          if (amountStr.contains(',') && amountStr.contains('.')) {
            if (amountStr.lastIndexOf(',') > amountStr.lastIndexOf('.')) {
              // European format: 1.234,56
              amountStr = amountStr.replaceAll('.', '').replaceAll(',', '.');
            } else {
              // US format: 1,234.56
              amountStr = amountStr.replaceAll(',', '');
            }
          } else if (amountStr.contains(',')) {
            // Ambiguous comma - check position
            if (amountStr.length - amountStr.lastIndexOf(',') == 3) {
              amountStr = amountStr.replaceAll(',', '.');
            } else {
              amountStr = amountStr.replaceAll(',', '');
            }
          }
          
          double? val = double.tryParse(amountStr);
          if (val != null && val > maxAmount && val < 10000000) { // Sanity check
            maxAmount = val;
            if (line.toLowerCase().contains('total')) {
              foundTotal = true;
            }
          }
        }
      }
      if (foundTotal) break; // If we found a total, stop looking
    }
    
    amount = maxAmount > 0 ? maxAmount : null;
    
    // Calculate confidence based on what we found
    double confidence = 0.0;
    int fieldsFound = 0;
    if (merchant != null && merchant.isNotEmpty) {
      fieldsFound++;
      confidence += 0.33;
    }
    if (amount != null) {
      fieldsFound++;
      confidence += 0.33;
      if (foundTotal) confidence += 0.1; // Bonus for finding "total"
    }
    if (date != null) {
      fieldsFound++;
      confidence += 0.33;
    }
    
    debugPrint('Final parsed - Merchant: $merchant, Amount: $amount, Date: $date, Fields: $fieldsFound/3');
    return ReceiptData(
      amount: amount, 
      date: date, 
      merchantName: merchant,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }
  
  void dispose() {
    _textRecognizer.close();
  }
}
