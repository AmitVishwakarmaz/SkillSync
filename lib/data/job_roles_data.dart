/// Predefined job roles with skill requirements
library;

import '../models/skill_model.dart';
import '../models/job_role_model.dart';

class JobRolesData {
  static final List<JobRole> allRoles = [
    JobRole(
      id: 'software_developer',
      name: 'Software Developer',
      description: 'Build and maintain software applications across various domains',
      icon: '💻',
      requiredSkills: {
        'java': SkillLevel.intermediate,
        'python': SkillLevel.intermediate,
        'dsa': SkillLevel.advanced,
        'git': SkillLevel.intermediate,
        'problem_solving': SkillLevel.advanced,
        'communication': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'web_developer',
      name: 'Web Developer',
      description: 'Create and maintain websites and web applications',
      icon: '🌐',
      requiredSkills: {
        'html': SkillLevel.advanced,
        'css': SkillLevel.advanced,
        'javascript': SkillLevel.advanced,
        'react': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
        'nodejs': SkillLevel.beginner,
      },
    ),
    JobRole(
      id: 'data_analyst',
      name: 'Data Analyst',
      description: 'Analyze data to help organizations make better decisions',
      icon: '📊',
      requiredSkills: {
        'python': SkillLevel.intermediate,
        'sql': SkillLevel.advanced,
        'statistics': SkillLevel.intermediate,
        'data_analysis': SkillLevel.advanced,
        'communication': SkillLevel.intermediate,
        'problem_solving': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'ai_engineer',
      name: 'AI/ML Engineer',
      description: 'Design and implement AI and machine learning solutions',
      icon: '🤖',
      requiredSkills: {
        'python': SkillLevel.advanced,
        'ml': SkillLevel.advanced,
        'deep_learning': SkillLevel.intermediate,
        'statistics': SkillLevel.intermediate,
        'dsa': SkillLevel.intermediate,
        'problem_solving': SkillLevel.advanced,
      },
    ),
    JobRole(
      id: 'cybersecurity_analyst',
      name: 'Cybersecurity Analyst',
      description: 'Protect organizations from cyber threats and vulnerabilities',
      icon: '🔐',
      requiredSkills: {
        'networking': SkillLevel.advanced,
        'security': SkillLevel.advanced,
        'linux': SkillLevel.intermediate,
        'python': SkillLevel.beginner,
        'problem_solving': SkillLevel.advanced,
        'communication': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'fullstack_developer',
      name: 'Full Stack Developer',
      description: 'Work on both frontend and backend of web applications',
      icon: '⚡',
      requiredSkills: {
        'html': SkillLevel.intermediate,
        'css': SkillLevel.intermediate,
        'javascript': SkillLevel.advanced,
        'react': SkillLevel.intermediate,
        'nodejs': SkillLevel.intermediate,
        'sql': SkillLevel.intermediate,
        'git': SkillLevel.intermediate,
      },
    ),
    JobRole(
      id: 'devops_engineer',
      name: 'DevOps Engineer',
      description: 'Automate and streamline software development and deployment',
      icon: '🔧',
      requiredSkills: {
        'linux': SkillLevel.advanced,
        'docker': SkillLevel.advanced,
        'aws': SkillLevel.intermediate,
        'git': SkillLevel.advanced,
        'python': SkillLevel.intermediate,
        'networking': SkillLevel.intermediate,
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
