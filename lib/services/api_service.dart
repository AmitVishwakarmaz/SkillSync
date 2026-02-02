/// API Service for connecting Flutter app to Flask backend
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Change this to your server IP when running on device
  // Use 10.0.2.2 for Android Emulator, localhost for web
  static const String baseUrl = 'http://172.50.9.34:5000/api';
  
  // For physical device, use your computer's IP address:
  // static const String baseUrl = 'http://192.168.1.xxx:5000/api';

  /// Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get all skills grouped by category
  static Future<Map<String, dynamic>> getSkills() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/skills'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load skills');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get all job roles
  static Future<List<dynamic>> getJobRoles() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-roles'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      throw Exception('Failed to load job roles');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get specific job role with details
  static Future<Map<String, dynamic>> getJobRole(String roleId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/job-roles/$roleId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }
      throw Exception('Failed to load job role');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Analyze skill gap
  static Future<Map<String, dynamic>> analyzeGap({
    required Map<String, String> userSkills,
    required String targetRole,
  }) async {
    try {
      final requestBody = json.encode({
        'user_skills': userSkills,
        'target_role': targetRole,
      });
      
      debugPrint('ApiService.analyzeGap - URL: $baseUrl/analyze-gap');
      debugPrint('ApiService.analyzeGap - Request: $requestBody');
      
      final response = await http.post(
        Uri.parse('$baseUrl/analyze-gap'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      debugPrint('ApiService.analyzeGap - Status: ${response.statusCode}');
      debugPrint('ApiService.analyzeGap - Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['data'] ?? {};
        debugPrint('ApiService.analyzeGap - Parsed data keys: ${result.keys.toList()}');
        return result;
      }
      throw Exception('Failed to analyze skill gap: ${response.statusCode}');
    } catch (e) {
      debugPrint('ApiService.analyzeGap - ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Generate learning roadmap
  static Future<Map<String, dynamic>> generateRoadmap({
    required List<String> missingSkills,
    required List<Map<String, dynamic>> skillsToImprove,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/roadmap'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'missing_skills': missingSkills,
          'skills_to_improve': skillsToImprove,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }
      throw Exception('Failed to generate roadmap');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Save user data
  static Future<bool> saveUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get user progress
  static Future<Map<String, dynamic>> getUserProgress(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/progress'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Update skill progress
  static Future<bool> updateProgress({
    required String userId,
    required String skillId,
    required String status, // not_started, in_progress, completed
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/progress'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'skill_id': skillId,
          'status': status,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get learning resources for a skill
  static Future<List<dynamic>> getResources(String skillId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/resources/$skillId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
