/// Predefined job roles with skill requirements
/// Synced with backend/data/job_roles.csv
library;

import '../models/skill_model.dart';
import '../models/job_role_model.dart';

class JobRolesData {
  static final List<JobRole> allRoles = [
    JobRole(
      id: 'software_developer',
      name: 'Software Developer',
      description: 'Build software applications and systems',
      icon: '💻',
      requiredSkills: {
        'python': SkillLevel.intermediate,
        'java': SkillLevel.intermediate,
        'dsa': SkillLevel.advanced,
        'oop': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
        'sql': SkillLevel.intermediate,
        'system_design': SkillLevel.beginner,
        'problem_solving': SkillLevel.advanced,
      },
    ),
    JobRole(
      id: 'web_developer',
      name: 'Web Developer',
      description: 'Create web applications and websites',
      icon: '🌐',
      requiredSkills: {
        'html': SkillLevel.advanced,
        'css': SkillLevel.advanced,
        'javascript': SkillLevel.advanced,
        'react': SkillLevel.intermediate,
        'nodejs': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
        'rest_api': SkillLevel.intermediate,
        'mongodb': SkillLevel.beginner,
      },
    ),
    JobRole(
      id: 'data_analyst',
      name: 'Data Analyst',
      description: 'Analyze data to drive business decisions',
      icon: '📊',
      requiredSkills: {
        'python': SkillLevel.intermediate,
        'sql': SkillLevel.advanced,
        'pandas': SkillLevel.intermediate,
        'numpy': SkillLevel.beginner,
        'data_viz': SkillLevel.intermediate,
        'problem_solving': SkillLevel.intermediate,
        'communication': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'data_scientist',
      name: 'Data Scientist',
      description: 'Build ML models and derive insights from data',
      icon: '🔬',
      requiredSkills: {
        'python': SkillLevel.advanced,
        'machine_learning': SkillLevel.advanced,
        'deep_learning': SkillLevel.intermediate,
        'pandas': SkillLevel.intermediate,
        'numpy': SkillLevel.intermediate,
        'sql': SkillLevel.intermediate,
        'data_viz': SkillLevel.intermediate,
        'tensorflow': SkillLevel.beginner,
      },
    ),
    JobRole(
      id: 'ai_engineer',
      name: 'AI/ML Engineer',
      description: 'Develop AI and machine learning solutions',
      icon: '🤖',
      requiredSkills: {
        'python': SkillLevel.advanced,
        'machine_learning': SkillLevel.advanced,
        'deep_learning': SkillLevel.intermediate,
        'tensorflow': SkillLevel.intermediate,
        'numpy': SkillLevel.intermediate,
        'pandas': SkillLevel.intermediate,
        'dsa': SkillLevel.intermediate,
        'system_design': SkillLevel.beginner,
      },
    ),
    JobRole(
      id: 'backend_developer',
      name: 'Backend Developer',
      description: 'Build server-side applications and APIs',
      icon: '⚙️',
      requiredSkills: {
        'python': SkillLevel.intermediate,
        'java': SkillLevel.intermediate,
        'nodejs': SkillLevel.intermediate,
        'sql': SkillLevel.advanced,
        'mongodb': SkillLevel.intermediate,
        'rest_api': SkillLevel.advanced,
        'docker': SkillLevel.intermediate,
        'aws': SkillLevel.beginner,
        'git': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'frontend_developer',
      name: 'Frontend Developer',
      description: 'Create user interfaces and experiences',
      icon: '🎨',
      requiredSkills: {
        'html': SkillLevel.advanced,
        'css': SkillLevel.advanced,
        'javascript': SkillLevel.advanced,
        'react': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
        'rest_api': SkillLevel.intermediate,
        'problem_solving': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'fullstack_developer',
      name: 'Full Stack Developer',
      description: 'End-to-end web development',
      icon: '🚀',
      requiredSkills: {
        'html': SkillLevel.intermediate,
        'css': SkillLevel.intermediate,
        'javascript': SkillLevel.advanced,
        'react': SkillLevel.intermediate,
        'nodejs': SkillLevel.intermediate,
        'mongodb': SkillLevel.intermediate,
        'sql': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
        'rest_api': SkillLevel.intermediate,
        'docker': SkillLevel.beginner,
      },
    ),
    JobRole(
      id: 'devops_engineer',
      name: 'DevOps Engineer',
      description: 'Manage deployment and infrastructure',
      icon: '🔧',
      requiredSkills: {
        'docker': SkillLevel.advanced,
        'aws': SkillLevel.intermediate,
        'gcp': SkillLevel.beginner,
        'git': SkillLevel.advanced,
        'python': SkillLevel.intermediate,
        'system_design': SkillLevel.intermediate,
        'agile': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'cybersecurity',
      name: 'Cybersecurity Analyst',
      description: 'Protect systems from security threats',
      icon: '🔒',
      requiredSkills: {
        'python': SkillLevel.beginner,
        'networking': SkillLevel.advanced,
        'security': SkillLevel.advanced,
        'linux': SkillLevel.intermediate,
        'problem_solving': SkillLevel.advanced,
        'communication': SkillLevel.intermediate,
      },
    ),
  ];

  static JobRole? getRoleById(String id) {
    try {
      return allRoles.firstWhere((role) => role.id == id);
    } catch (_) {
      return null;
    }
  }
}

