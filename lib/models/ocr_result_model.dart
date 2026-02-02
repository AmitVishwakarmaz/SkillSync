/// OCR Result model for storing extracted text and matched skills
library;

import 'skill_model.dart';

/// Source of the image used for OCR
enum OcrImageSource { camera, gallery }

/// Result of OCR processing
class OcrResult {
  /// Raw text extracted from the image
  final String rawText;

  /// Skills that were matched against our skills database
  final List<Skill> extractedSkills;

  /// Keywords found in text that might be skills but aren't in our database
  final List<String> unmatchedKeywords;

  /// Source of the image (camera or gallery)
  final OcrImageSource sourceType;

  /// When the extraction occurred
  final DateTime timestamp;

  /// Whether any text was found in the image
  bool get hasText => rawText.isNotEmpty;

  /// Whether any skills were matched
  bool get hasSkills => extractedSkills.isNotEmpty;

  const OcrResult({
    required this.rawText,
    required this.extractedSkills,
    required this.unmatchedKeywords,
    required this.sourceType,
    required this.timestamp,
  });

  /// Creates an empty result (no text found)
  factory OcrResult.empty(OcrImageSource source) {
    return OcrResult(
      rawText: '',
      extractedSkills: const [],
      unmatchedKeywords: const [],
      sourceType: source,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'OcrResult(skills: ${extractedSkills.length}, unmatched: ${unmatchedKeywords.length})';
  }
}
