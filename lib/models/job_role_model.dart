/// Job Role model with required skills
library;

import 'skill_model.dart';

class JobRole {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Map<String, SkillLevel> requiredSkills; // skillId -> minimum level required

  const JobRole({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredSkills,
  });
}

class SkillGap {
  final String skillId;
  final String skillName;
  final SkillLevel? currentLevel;
  final SkillLevel requiredLevel;
  final bool isMissing;

  const SkillGap({
    required this.skillId,
    required this.skillName,
    required this.currentLevel,
    required this.requiredLevel,
    required this.isMissing,
  });

  int get gapSize {
    if (isMissing) return requiredLevel.value;
    return requiredLevel.value - (currentLevel?.value ?? 0);
  }

  String get gapDescription {
    if (isMissing) {
      return 'Missing - Need ${requiredLevel.displayName} level';
    }
    if (gapSize > 0) {
      return 'Current: ${currentLevel?.displayName} → Required: ${requiredLevel.displayName}';
    }
    return 'Proficient';
  }
}

class SkillGapAnalysis {
  final JobRole targetRole;
  final List<SkillGap> gaps;
  final int matchPercentage;
  final List<String> strongSkills;

  const SkillGapAnalysis({
    required this.targetRole,
    required this.gaps,
    required this.matchPercentage,
    required this.strongSkills,
  });

  List<SkillGap> get missingSkills => 
      gaps.where((g) => g.isMissing).toList();
  
  List<SkillGap> get skillsToImprove => 
      gaps.where((g) => !g.isMissing && g.gapSize > 0).toList();
  
  List<SkillGap> get proficientSkills => 
      gaps.where((g) => g.gapSize <= 0).toList();
}
