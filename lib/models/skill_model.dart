/// Skill model for skill assessment
library;

enum SkillLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }

  int get value {
    switch (this) {
      case SkillLevel.beginner:
        return 1;
      case SkillLevel.intermediate:
        return 2;
      case SkillLevel.advanced:
        return 3;
    }
  }

  static SkillLevel fromString(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return SkillLevel.beginner;
      case 'intermediate':
        return SkillLevel.intermediate;
      case 'advanced':
        return SkillLevel.advanced;
      default:
        return SkillLevel.beginner;
    }
  }
}

enum SkillCategory {
  programming,
  webDevelopment,
  dataScience,
  softSkills,
  tools;

  String get displayName {
    switch (this) {
      case SkillCategory.programming:
        return 'Programming';
      case SkillCategory.webDevelopment:
        return 'Web Development';
      case SkillCategory.dataScience:
        return 'Data Science & AI';
      case SkillCategory.softSkills:
        return 'Soft Skills';
      case SkillCategory.tools:
        return 'Tools & Technologies';
    }
  }
}

class Skill {
  final String id;
  final String name;
  final SkillCategory category;
  final String? description;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Skill && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UserSkill {
  final Skill skill;
  final SkillLevel level;

  const UserSkill({
    required this.skill,
    required this.level,
  });

  int get levelValue => level.value;
}
