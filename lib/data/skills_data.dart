/// Predefined skills data organized by category
/// Synced with backend/data/skills.csv
library;

import '../models/skill_model.dart';

class SkillsData {
  static const List<Skill> allSkills = [
    // Programming Languages
    Skill(
      id: 'python',
      name: 'Python',
      category: SkillCategory.programming,
      description: 'General-purpose programming language popular for data science and backend',
    ),
    Skill(
      id: 'java',
      name: 'Java',
      category: SkillCategory.programming,
      description: 'Object-oriented language for enterprise and Android development',
    ),
    Skill(
      id: 'javascript',
      name: 'JavaScript',
      category: SkillCategory.programming,
      description: 'Core language for web development',
    ),
    Skill(
      id: 'cpp',
      name: 'C++',
      category: SkillCategory.programming,
      description: 'System-level programming and competitive coding',
    ),
    Skill(
      id: 'sql',
      name: 'SQL',
      category: SkillCategory.programming,
      description: 'Query language for relational databases',
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
      description: 'Markup language for web pages',
    ),
    Skill(
      id: 'css',
      name: 'CSS',
      category: SkillCategory.webDevelopment,
      description: 'Styling language for web pages',
    ),
    Skill(
      id: 'react',
      name: 'React',
      category: SkillCategory.webDevelopment,
      description: 'JavaScript library for building user interfaces',
    ),
    Skill(
      id: 'nodejs',
      name: 'Node.js',
      category: SkillCategory.webDevelopment,
      description: 'JavaScript runtime for backend development',
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
    Skill(
      id: 'flask',
      name: 'Flask',
      category: SkillCategory.webDevelopment,
      description: 'Python web microframework',
    ),
    Skill(
      id: 'django',
      name: 'Django',
      category: SkillCategory.webDevelopment,
      description: 'Python web framework',
    ),
    Skill(
      id: 'rest_api',
      name: 'REST API',
      category: SkillCategory.webDevelopment,
      description: 'RESTful API design and development',
    ),

    // Database
    Skill(
      id: 'mongodb',
      name: 'MongoDB',
      category: SkillCategory.tools,
      description: 'NoSQL document database',
    ),

    // Data Science & AI
    Skill(
      id: 'machine_learning',
      name: 'Machine Learning',
      category: SkillCategory.dataScience,
      description: 'Building predictive models and algorithms',
    ),
    Skill(
      id: 'deep_learning',
      name: 'Deep Learning',
      category: SkillCategory.dataScience,
      description: 'Neural networks and AI systems',
    ),
    Skill(
      id: 'tensorflow',
      name: 'TensorFlow',
      category: SkillCategory.dataScience,
      description: 'Machine learning framework by Google',
    ),
    Skill(
      id: 'pandas',
      name: 'Pandas',
      category: SkillCategory.dataScience,
      description: 'Data manipulation library for Python',
    ),
    Skill(
      id: 'numpy',
      name: 'NumPy',
      category: SkillCategory.dataScience,
      description: 'Numerical computing library for Python',
    ),
    Skill(
      id: 'data_viz',
      name: 'Data Visualization',
      category: SkillCategory.dataScience,
      description: 'Creating charts and visual representations',
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
      id: 'nlp',
      name: 'Natural Language Processing',
      category: SkillCategory.dataScience,
      description: 'Processing and analyzing text data',
    ),

    // Core CS
    Skill(
      id: 'dsa',
      name: 'Data Structures & Algorithms',
      category: SkillCategory.programming,
      description: 'Fundamental CS concepts',
    ),
    Skill(
      id: 'oop',
      name: 'OOP',
      category: SkillCategory.programming,
      description: 'Object Oriented Programming concepts',
    ),
    Skill(
      id: 'system_design',
      name: 'System Design',
      category: SkillCategory.programming,
      description: 'Designing scalable software systems',
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
      description: 'Containerization platform',
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
      id: 'gcp',
      name: 'GCP',
      category: SkillCategory.tools,
      description: 'Google Cloud Platform services',
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

    // Soft Skills & Methodology
    Skill(
      id: 'communication',
      name: 'Communication',
      category: SkillCategory.softSkills,
      description: 'Professional communication skills',
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
      description: 'Collaboration and team management',
    ),
    Skill(
      id: 'agile',
      name: 'Agile',
      category: SkillCategory.softSkills,
      description: 'Agile development methodology',
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

