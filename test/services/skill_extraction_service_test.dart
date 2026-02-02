/// Unit tests for SkillExtractionService
import 'package:flutter_test/flutter_test.dart';
import 'package:skillsync/services/skill_extraction_service.dart';
import 'package:skillsync/models/ocr_result_model.dart';

void main() {
  late SkillExtractionService service;

  setUp(() {
    service = SkillExtractionService();
  });

  group('SkillExtractionService', () {
    group('processExtractedText', () {
      test('returns empty result for empty text', () {
        final result = service.processExtractedText('', OcrImageSource.gallery);

        expect(result.hasText, isFalse);
        expect(result.hasSkills, isFalse);
        expect(result.extractedSkills, isEmpty);
      });

      test('returns empty result for whitespace-only text', () {
        final result = service.processExtractedText(
          '   \n\t  ',
          OcrImageSource.camera,
        );

        expect(result.hasText, isFalse);
        expect(result.extractedSkills, isEmpty);
      });

      test('matches exact skill name (Python)', () {
        final result = service.processExtractedText(
          'I am proficient in Python programming',
          OcrImageSource.gallery,
        );

        expect(result.hasSkills, isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'python'), isTrue);
      });

      test('matches case-insensitive skill name (JAVASCRIPT)', () {
        final result = service.processExtractedText(
          'Skills: JAVASCRIPT, HTML, CSS',
          OcrImageSource.gallery,
        );

        expect(result.extractedSkills.any((s) => s.id == 'javascript'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'html'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'css'), isTrue);
      });

      test('matches skill variations (Node.js -> nodejs)', () {
        final result = service.processExtractedText(
          'Experience with Node.js and React.js',
          OcrImageSource.gallery,
        );

        expect(result.extractedSkills.any((s) => s.id == 'nodejs'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'react'), isTrue);
      });

      test('matches C++ skill', () {
        final result = service.processExtractedText(
          'Programming Languages: C++, Java',
          OcrImageSource.gallery,
        );

        expect(result.extractedSkills.any((s) => s.id == 'cpp'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'java'), isTrue);
      });

      test('matches machine learning spelled out', () {
        final result = service.processExtractedText(
          'Machine Learning and Deep Learning experience',
          OcrImageSource.gallery,
        );

        expect(result.extractedSkills.any((s) => s.id == 'ml'), isTrue);
        expect(
          result.extractedSkills.any((s) => s.id == 'deep_learning'),
          isTrue,
        );
      });

      test('does not duplicate skills when matched multiple times', () {
        final result = service.processExtractedText(
          'Python, python, PYTHON are mentioned multiple times',
          OcrImageSource.gallery,
        );

        final pythonMatches = result.extractedSkills.where(
          (s) => s.id == 'python',
        );
        expect(pythonMatches.length, equals(1));
      });

      test('handles resume-like content', () {
        final resumeText = '''
          RESUME
          John Doe
          Software Developer
          
          Technical Skills:
          - Python
          - JavaScript
          - React
          - Docker
          - Git
          
          Soft Skills:
          - Communication
          - Problem Solving
          - Teamwork
        ''';

        final result = service.processExtractedText(
          resumeText,
          OcrImageSource.gallery,
        );

        expect(result.hasSkills, isTrue);
        expect(result.extractedSkills.length, greaterThanOrEqualTo(5));
        expect(result.extractedSkills.any((s) => s.id == 'python'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'javascript'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'react'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'docker'), isTrue);
        expect(result.extractedSkills.any((s) => s.id == 'git'), isTrue);
        expect(
          result.extractedSkills.any((s) => s.id == 'communication'),
          isTrue,
        );
      });

      test('preserves raw text in result', () {
        const originalText = 'Python and Java developer';
        final result = service.processExtractedText(
          originalText,
          OcrImageSource.camera,
        );

        expect(result.rawText, equals(originalText));
      });

      test('sets correct source type', () {
        final cameraResult = service.processExtractedText(
          'test',
          OcrImageSource.camera,
        );
        final galleryResult = service.processExtractedText(
          'test',
          OcrImageSource.gallery,
        );

        expect(cameraResult.sourceType, equals(OcrImageSource.camera));
        expect(galleryResult.sourceType, equals(OcrImageSource.gallery));
      });

      test('sets timestamp', () {
        final before = DateTime.now();
        final result = service.processExtractedText(
          'Python',
          OcrImageSource.gallery,
        );
        final after = DateTime.now();

        expect(
          result.timestamp.isAfter(before) ||
              result.timestamp.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          result.timestamp.isBefore(after) ||
              result.timestamp.isAtSameMomentAs(after),
          isTrue,
        );
      });

      test(
        'returns text with no matching skills when non-skill text provided',
        () {
          final result = service.processExtractedText(
            'This is just regular text with no skills mentioned',
            OcrImageSource.gallery,
          );

          expect(result.hasText, isTrue);
          expect(result.hasSkills, isFalse);
          expect(result.rawText, isNotEmpty);
        },
      );
    });
  });
}
