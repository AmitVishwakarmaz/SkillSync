/// Service for extracting and matching skills from OCR text
library;

import '../data/skills_data.dart';
import '../models/skill_model.dart';
import '../models/ocr_result_model.dart';

/// Service that processes raw OCR text and matches it against known skills
class SkillExtractionService {
  /// Process extracted text and match against known skills
  OcrResult processExtractedText(String rawText, OcrImageSource sourceType) {
    if (rawText.trim().isEmpty) {
      return OcrResult.empty(sourceType);
    }

    final normalizedText = _normalizeText(rawText);
    final matchedSkills = <Skill>[];
    final unmatchedKeywords = <String>[];

    // Match against all known skills
    for (final skill in SkillsData.allSkills) {
      if (_textContainsSkill(normalizedText, skill)) {
        if (!matchedSkills.contains(skill)) {
          matchedSkills.add(skill);
        }
      }
    }

    // Extract potential skill keywords that aren't in our database
    final potentialKeywords = _extractPotentialKeywords(normalizedText);
    for (final keyword in potentialKeywords) {
      final isAlreadyMatched = matchedSkills.any(
        (s) => s.name.toLowerCase() == keyword.toLowerCase(),
      );
      if (!isAlreadyMatched && !unmatchedKeywords.contains(keyword)) {
        unmatchedKeywords.add(keyword);
      }
    }

    return OcrResult(
      rawText: rawText,
      extractedSkills: matchedSkills,
      unmatchedKeywords: unmatchedKeywords,
      sourceType: sourceType,
      timestamp: DateTime.now(),
    );
  }

  /// Normalize text for matching (lowercase, clean up whitespace)
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s\+\#\.]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Check if text contains a skill (with fuzzy matching for variations)
  bool _textContainsSkill(String normalizedText, Skill skill) {
    final skillName = skill.name.toLowerCase();
    final skillId = skill.id.toLowerCase();

    // Direct match
    if (_matchesWord(normalizedText, skillName)) return true;
    if (_matchesWord(normalizedText, skillId)) return true;

    // Handle common variations
    final variations = _getSkillVariations(skill);
    for (final variation in variations) {
      if (_matchesWord(normalizedText, variation)) return true;
    }

    return false;
  }

  /// Check if a word exists in text as a complete word
  bool _matchesWord(String text, String word) {
    // For words with special regex characters like c++, use direct check
    if (word.contains('+') || word.contains('#')) {
      // Direct substring check with word boundaries
      final textWithSpaces = ' $text ';
      if (textWithSpaces.contains(' $word ') ||
          textWithSpaces.contains(' $word,') ||
          textWithSpaces.contains(' $word.') ||
          textWithSpaces.contains(',$word ') ||
          textWithSpaces.contains(':$word ')) {
        return true;
      }
      return false;
    }

    // Use word boundary matching for normal words
    final pattern = RegExp(
      r'\b' + RegExp.escape(word) + r'\b',
      caseSensitive: false,
    );
    return pattern.hasMatch(text);
  }

  /// Get common variations of skill names
  List<String> _getSkillVariations(Skill skill) {
    final variations = <String>[];
    final name = skill.name.toLowerCase();
    final id = skill.id.toLowerCase();

    // Add variations based on skill
    switch (id) {
      case 'javascript':
        variations.addAll(['js', 'java script']);
        break;
      case 'typescript':
        variations.addAll(['ts', 'type script']);
        break;
      case 'python':
        variations.addAll(['py', 'python3', 'python 3']);
        break;
      case 'cpp':
        variations.addAll(['c++', 'cplusplus', 'c plus plus']);
        break;
      case 'nodejs':
        variations.addAll(['node', 'node.js', 'node js']);
        break;
      case 'react':
        variations.addAll(['reactjs', 'react.js', 'react js']);
        break;
      case 'vue':
        variations.addAll(['vuejs', 'vue.js', 'vue js']);
        break;
      case 'angular':
        variations.addAll(['angularjs', 'angular.js', 'angular js']);
        break;
      case 'ml':
        variations.addAll(['machine learning', 'ml/ai']);
        break;
      case 'deep_learning':
        variations.addAll(['deep learning', 'dl', 'neural networks']);
        break;
      case 'nlp':
        variations.addAll(['natural language processing', 'text processing']);
        break;
      case 'dsa':
        variations.addAll([
          'data structures',
          'algorithms',
          'data structures and algorithms',
        ]);
        break;
      case 'data_analysis':
        variations.addAll(['data analytics', 'analytics']);
        break;
      case 'aws':
        variations.addAll(['amazon web services', 'amazon aws']);
        break;
      case 'security':
        variations.addAll([
          'cyber security',
          'infosec',
          'information security',
        ]);
        break;
    }

    // Also add the name with spaces replaced by underscores and vice versa
    if (name.contains(' ')) {
      variations.add(name.replaceAll(' ', '_'));
      variations.add(name.replaceAll(' ', '-'));
    }
    if (name.contains('_')) {
      variations.add(name.replaceAll('_', ' '));
    }

    return variations;
  }

  /// Extract potential keywords that might be skills
  List<String> _extractPotentialKeywords(String normalizedText) {
    final keywords = <String>[];

    // Common technology-related patterns
    final techPatterns = [
      RegExp(r'\b[a-z]+\.js\b'), // *.js frameworks
      RegExp(r'\b[a-z]+\+\+\b'), // C++, etc.
      RegExp(r'\b[a-z]+#\b'), // C#, etc.
    ];

    for (final pattern in techPatterns) {
      final matches = pattern.allMatches(normalizedText);
      for (final match in matches) {
        final keyword = match.group(0)!;
        if (!keywords.contains(keyword)) {
          keywords.add(keyword);
        }
      }
    }

    return keywords;
  }
}
