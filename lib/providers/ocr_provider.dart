/// OCR Provider for managing OCR state and operations
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ocr_result_model.dart';
import '../services/ocr_service.dart';
import '../services/skill_extraction_service.dart';

/// State management provider for OCR functionality
class OcrProvider extends ChangeNotifier {
  final OcrService _ocrService = OcrService();
  final SkillExtractionService _skillExtractionService =
      SkillExtractionService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;
  OcrResult? _result;
  String? _error;

  /// Whether OCR is currently processing an image
  bool get isProcessing => _isProcessing;

  /// The latest OCR result
  OcrResult? get result => _result;

  /// Error message if last operation failed
  String? get error => _error;

  /// Whether there's a valid result available
  bool get hasResult => _result != null && _result!.hasText;

  /// Pick an image and process it for skill extraction
  Future<OcrResult?> pickAndProcessImage(OcrImageSource source) async {
    try {
      _setProcessing(true);
      _clearError();

      // Pick image based on source
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source == OcrImageSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: 2048, // Resize to prevent memory issues
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        // User cancelled
        _setProcessing(false);
        return null;
      }

      final imageFile = File(pickedFile.path);

      // Extract text using OCR
      final rawText = await _ocrService.extractTextFromImage(imageFile);

      // Process text to find skills
      _result = _skillExtractionService.processExtractedText(rawText, source);

      notifyListeners();
      return _result;
    } on OcrException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to process image. Please try again.');
      return null;
    } finally {
      _setProcessing(false);
    }
  }

  /// Clear the current result
  void clearResult() {
    _result = null;
    _error = null;
    notifyListeners();
  }

  void _setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _result = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
