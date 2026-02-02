/// Flutter-only Roadmap Service
/// Generates personalized learning roadmaps without requiring backend
library;

import '../data/skills_data.dart';
import '../data/job_roles_data.dart';
import '../data/learning_resources_data.dart';
import '../models/skill_model.dart';

class RoadmapStep {
  final int step;
  final String skillId;
  final String skillName;
  final String category;
  final String status; // 'New Skill' or 'Upgrade'
  final String? currentLevel;
  final String targetLevel;
  final int estimatedHours;
  final List<Map<String, dynamic>> resources;

  RoadmapStep({
    required this.step,
    required this.skillId,
    required this.skillName,
    required this.category,
    required this.status,
    this.currentLevel,
    required this.targetLevel,
    required this.estimatedHours,
    required this.resources,
  });
}

class RoadmapResult {
  final List<RoadmapStep> roadmap;
  final int totalSkills;
  final int totalEstimatedHours;
  final int estimatedWeeks;

  RoadmapResult({
    required this.roadmap,
    required this.totalSkills,
    required this.totalEstimatedHours,
    required this.estimatedWeeks,
  });
}

class SkillGapResult {
  final String targetRoleId;
  final String targetRoleName;
  final String targetRoleIcon;
  final int matchPercentage;
  final List<Map<String, dynamic>> proficientSkills;
  final List<Map<String, dynamic>> skillsToImprove;
  final List<Map<String, dynamic>> missingSkills;
  final Map<String, dynamic> summary;

  SkillGapResult({
    required this.targetRoleId,
    required this.targetRoleName,
    required this.targetRoleIcon,
    required this.matchPercentage,
    required this.proficientSkills,
    required this.skillsToImprove,
    required this.missingSkills,
    required this.summary,
  });
}

class RoadmapService {
  static const Map<String, int> _skillLevelValues = {
    'beginner': 1,
    'intermediate': 2,
    'advanced': 3,
  };

  /// Analyze skill gap between user skills and job role requirements
  static SkillGapResult analyzeSkillGap({
    required Map<String, String> userSkills,
    required String targetRoleId,
  }) {
    // Get job role requirements
    final role = JobRolesData.getRoleById(targetRoleId);
    if (role == null) {
      return SkillGapResult(
        targetRoleId: targetRoleId,
        targetRoleName: 'Unknown Role',
        targetRoleIcon: '❓',
        matchPercentage: 0,
        proficientSkills: [],
        skillsToImprove: [],
        missingSkills: [],
        summary: {'error': 'Role not found'},
      );
    }

    final proficientSkills = <Map<String, dynamic>>[];
    final skillsToImprove = <Map<String, dynamic>>[];
    final missingSkills = <Map<String, dynamic>>[];

    // Analyze each required skill
    for (final entry in role.requiredSkills.entries) {
      final skillId = entry.key;
      final requiredLevel = entry.value;
      final requiredLevelStr = _levelToString(requiredLevel);
      final requiredLevelValue = _skillLevelValues[requiredLevelStr] ?? 2;

      // Get skill info
      final skill = SkillsData.getSkillById(skillId);
      final skillName = skill?.name ?? skillId;
      final category = skill?.category.name ?? 'Other';

      if (userSkills.containsKey(skillId)) {
        // User has this skill
        final userLevel = userSkills[skillId]!.toLowerCase();
        final userLevelValue = _skillLevelValues[userLevel] ?? 0;

        if (userLevelValue >= requiredLevelValue) {
          // Proficient
          proficientSkills.add({
            'skill_id': skillId,
            'skill_name': skillName,
            'category': category,
            'current_level': userLevel,
            'required_level': requiredLevelStr,
          });
        } else {
          // Needs improvement
          skillsToImprove.add({
            'skill_id': skillId,
            'skill_name': skillName,
            'category': category,
            'current_level': userLevel,
            'required_level': requiredLevelStr,
            'gap': requiredLevelValue - userLevelValue,
          });
        }
      } else {
        // Missing skill
        missingSkills.add({
          'skill_id': skillId,
          'skill_name': skillName,
          'category': category,
          'required_level': requiredLevelStr,
        });
      }
    }

    // Calculate match percentage
    final totalRequired = role.requiredSkills.length;
    final proficientCount = proficientSkills.length;
    final matchPercentage = totalRequired > 0
        ? ((proficientCount / totalRequired) * 100).round()
        : 0;

    return SkillGapResult(
      targetRoleId: role.id,
      targetRoleName: role.name,
      targetRoleIcon: role.icon,
      matchPercentage: matchPercentage,
      proficientSkills: proficientSkills,
      skillsToImprove: skillsToImprove,
      missingSkills: missingSkills,
      summary: {
        'total_required': totalRequired,
        'proficient': proficientCount,
        'to_improve': skillsToImprove.length,
        'missing': missingSkills.length,
      },
    );
  }

  /// Generate learning roadmap based on skill gaps
  static RoadmapResult generateRoadmap({
    required List<Map<String, dynamic>> missingSkills,
    required List<Map<String, dynamic>> skillsToImprove,
  }) {
    final roadmap = <RoadmapStep>[];
    var step = 1;
    var totalHours = 0;

    // Category priority for ordering
    const categoryPriority = {
      'programming': 1,
      'webDevelopment': 2,
      'dataScience': 3,
      'tools': 4,
      'softSkills': 5,
    };

    // Sort missing skills by category priority
    final sortedMissing = List<Map<String, dynamic>>.from(missingSkills);
    sortedMissing.sort((a, b) {
      final aPriority = categoryPriority[a['category']] ?? 99;
      final bPriority = categoryPriority[b['category']] ?? 99;
      return aPriority.compareTo(bPriority);
    });

    // Add missing skills to roadmap
    for (final skillData in sortedMissing) {
      final skillId = skillData['skill_id'] as String;
      final resources = _getResourcesForSkill(skillId, 'beginner');

      var skillHours = 0;
      for (final res in resources) {
        skillHours += res['hours'] as int;
      }

      roadmap.add(RoadmapStep(
        step: step,
        skillId: skillId,
        skillName: skillData['skill_name'] as String,
        category: skillData['category'] as String,
        status: 'New Skill',
        targetLevel: skillData['required_level'] as String? ?? 'intermediate',
        estimatedHours: skillHours,
        resources: resources,
      ));

      totalHours += skillHours;
      step++;
    }

    // Add skills to improve
    for (final skillData in skillsToImprove) {
      final skillId = skillData['skill_id'] as String;
      final currentLevel = skillData['current_level'] as String;
      final nextLevel = currentLevel == 'beginner' ? 'intermediate' : 'advanced';
      final resources = _getResourcesForSkill(skillId, nextLevel);

      var skillHours = 0;
      for (final res in resources) {
        skillHours += res['hours'] as int;
      }

      roadmap.add(RoadmapStep(
        step: step,
        skillId: skillId,
        skillName: skillData['skill_name'] as String,
        category: skillData['category'] as String,
        status: 'Upgrade',
        currentLevel: currentLevel,
        targetLevel: skillData['required_level'] as String? ?? nextLevel,
        estimatedHours: skillHours,
        resources: resources,
      ));

      totalHours += skillHours;
      step++;
    }

    return RoadmapResult(
      roadmap: roadmap,
      totalSkills: roadmap.length,
      totalEstimatedHours: totalHours,
      estimatedWeeks: (totalHours / 10).ceil().clamp(1, 52),
    );
  }

  /// Get learning resources for a skill at specified level
  static List<Map<String, dynamic>> _getResourcesForSkill(
    String skillId,
    String targetLevel,
  ) {
    final allResources = LearningResourcesData.getResourcesForSkill(skillId);
    final result = <Map<String, dynamic>>[];

    // Filter by target level and below
    for (final res in allResources) {
      if (_matchesLevel(res.difficulty, targetLevel)) {
        result.add({
          'name': res.name,
          'type': res.type,
          'url': res.url,
          'difficulty': res.difficulty,
          'hours': res.estimatedHours,
        });
      }
    }

    // Return top 3 resources, or all if less than 3
    return result.take(3).toList();
  }

  /// Check if resource difficulty matches target level
  static bool _matchesLevel(String resourceLevel, String targetLevel) {
    final resourceValue = _skillLevelValues[resourceLevel] ?? 1;
    final targetValue = _skillLevelValues[targetLevel] ?? 2;
    // Include resources at or below target level
    return resourceValue <= targetValue;
  }

  /// Convert SkillLevel enum to string
  static String _levelToString(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'beginner';
      case SkillLevel.intermediate:
        return 'intermediate';
      case SkillLevel.advanced:
        return 'advanced';
    }
  }
}
