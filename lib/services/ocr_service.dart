/// OCR Service using Google ML Kit for on-device text recognition
library;

import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Service for extracting text from images using ML Kit
class OcrService {
  TextRecognizer? _textRecognizer;

  /// Initialize the text recognizer
  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Extract text from an image file
  ///
  /// Returns the raw extracted text, or empty string if no text found.
  /// Throws [OcrException] if processing fails.
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) {
        throw OcrException('Image file does not exist');
      }

      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await _recognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('Failed to process image: $e');
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _textRecognizer?.close();
    _textRecognizer = null;
  }
}

/// Exception thrown when OCR processing fails
class OcrException implements Exception {
  final String message;

  OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
