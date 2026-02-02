/// Predefined skills data organized by category
library;

import '../models/skill_model.dart';

class SkillsData {
  static const List<Skill> allSkills = [
    // Programming Languages
    Skill(
      id: 'java',
      name: 'Java',
      category: SkillCategory.programming,
      description: 'Object-oriented programming language',
    ),
    Skill(
      id: 'python',
      name: 'Python',
      category: SkillCategory.programming,
      description: 'General-purpose programming language',
    ),
    Skill(
      id: 'javascript',
      name: 'JavaScript',
      category: SkillCategory.programming,
      description: 'Web programming language',
    ),
    Skill(
      id: 'cpp',
      name: 'C++',
      category: SkillCategory.programming,
      description: 'Systems programming language',
    ),
    Skill(
      id: 'sql',
      name: 'SQL',
      category: SkillCategory.programming,
      description: 'Database query language',
    ),
    Skill(
      id: 'typescript',
      name: 'TypeScript',
      category: SkillCategory.programming,
      description: 'Typed superset of JavaScript',
    ),

    // Web Development
    Skill(
      id: 'html',
      name: 'HTML',
      category: SkillCategory.webDevelopment,
      description: 'Web markup language',
    ),
    Skill(
      id: 'css',
      name: 'CSS',
      category: SkillCategory.webDevelopment,
      description: 'Web styling language',
    ),
    Skill(
      id: 'react',
      name: 'React',
      category: SkillCategory.webDevelopment,
      description: 'JavaScript library for building UIs',
    ),
    Skill(
      id: 'nodejs',
      name: 'Node.js',
      category: SkillCategory.webDevelopment,
      description: 'JavaScript runtime environment',
    ),
    Skill(
      id: 'angular',
      name: 'Angular',
      category: SkillCategory.webDevelopment,
      description: 'Web application framework',
    ),
    Skill(
      id: 'vue',
      name: 'Vue.js',
      category: SkillCategory.webDevelopment,
      description: 'Progressive JavaScript framework',
    ),

    // Data Science & AI
    Skill(
      id: 'ml',
      name: 'Machine Learning',
      category: SkillCategory.dataScience,
      description: 'Building predictive models',
    ),
    Skill(
      id: 'data_analysis',
      name: 'Data Analysis',
      category: SkillCategory.dataScience,
      description: 'Analyzing and interpreting data',
    ),
    Skill(
      id: 'statistics',
      name: 'Statistics',
      category: SkillCategory.dataScience,
      description: 'Statistical analysis and modeling',
    ),
    Skill(
      id: 'deep_learning',
      name: 'Deep Learning',
      category: SkillCategory.dataScience,
      description: 'Neural network architectures',
    ),
    Skill(
      id: 'nlp',
      name: 'Natural Language Processing',
      category: SkillCategory.dataScience,
      description: 'Processing and analyzing text data',
    ),

    // Tools & Technologies
    Skill(
      id: 'git',
      name: 'Git',
      category: SkillCategory.tools,
      description: 'Version control system',
    ),
    Skill(
      id: 'docker',
      name: 'Docker',
      category: SkillCategory.tools,
      description: 'Container platform',
    ),
    Skill(
      id: 'linux',
      name: 'Linux',
      category: SkillCategory.tools,
      description: 'Operating system',
    ),
    Skill(
      id: 'aws',
      name: 'AWS',
      category: SkillCategory.tools,
      description: 'Amazon Web Services cloud platform',
    ),
    Skill(
      id: 'networking',
      name: 'Networking',
      category: SkillCategory.tools,
      description: 'Computer networks and protocols',
    ),
    Skill(
      id: 'security',
      name: 'Cybersecurity',
      category: SkillCategory.tools,
      description: 'Information security practices',
    ),

    // Soft Skills
    Skill(
      id: 'communication',
      name: 'Communication',
      category: SkillCategory.softSkills,
      description: 'Effective verbal and written communication',
    ),
    Skill(
      id: 'problem_solving',
      name: 'Problem Solving',
      category: SkillCategory.softSkills,
      description: 'Analytical and critical thinking',
    ),
    Skill(
      id: 'teamwork',
      name: 'Teamwork',
      category: SkillCategory.softSkills,
      description: 'Collaborative work skills',
    ),
    Skill(
      id: 'dsa',
      name: 'Data Structures & Algorithms',
      category: SkillCategory.programming,
      description: 'Fundamental CS concepts',
    ),
  ];

  static List<Skill> getSkillsByCategory(SkillCategory category) {
    return allSkills.where((skill) => skill.category == category).toList();
  }

  static Skill? getSkillById(String id) {
    try {
      return allSkills.firstWhere((skill) => skill.id == id);
    } catch (_) {
      return null;
    }
  }

  static Map<SkillCategory, List<Skill>> get skillsByCategory {
    final map = <SkillCategory, List<Skill>>{};
    for (final category in SkillCategory.values) {
      map[category] = getSkillsByCategory(category);
    }
    return map;
  }
}
