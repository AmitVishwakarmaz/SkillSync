/// Learning resources data for the roadmap
/// Contains course links, videos, and documentation for each skill
library;

class LearningResource {
  final String name;
  final String type; // Video, Course, Documentation, Tutorial, Book, Practice
  final String url;
  final String difficulty; // beginner, intermediate, advanced
  final int estimatedHours;

  const LearningResource({
    required this.name,
    required this.type,
    required this.url,
    required this.difficulty,
    required this.estimatedHours,
  });
}

class LearningResourcesData {
  /// Get resources for a specific skill
  static List<LearningResource> getResourcesForSkill(String skillId) {
    return _resourcesBySkill[skillId] ?? [];
  }

  /// All learning resources organized by skill ID
  static const Map<String, List<LearningResource>> _resourcesBySkill = {
    // ===== Programming Languages =====
    'python': [
      LearningResource(
        name: 'Python for Beginners - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=rfscVS0vtbw',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: '100 Days of Code - Angela Yu (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/100-days-of-code/',
        difficulty: 'beginner',
        estimatedHours: 60,
      ),
      LearningResource(
        name: 'Python Official Tutorial',
        type: 'Documentation',
        url: 'https://docs.python.org/3/tutorial/',
        difficulty: 'beginner',
        estimatedHours: 10,
      ),
      LearningResource(
        name: 'Python Intermediate - Corey Schafer',
        type: 'Video',
        url: 'https://www.youtube.com/playlist?list=PL-osiE80TeTt2d9bfVyTiXJA-UTHn6WwU',
        difficulty: 'intermediate',
        estimatedHours: 8,
      ),
    ],
    'java': [
      LearningResource(
        name: 'Java Tutorial - Programming with Mosh',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=eIrMbAQSU34',
        difficulty: 'beginner',
        estimatedHours: 3,
      ),
      LearningResource(
        name: 'Java Programming Masterclass (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/java-the-complete-java-developer-course/',
        difficulty: 'intermediate',
        estimatedHours: 80,
      ),
      LearningResource(
        name: 'Java Official Documentation',
        type: 'Documentation',
        url: 'https://docs.oracle.com/javase/tutorial/',
        difficulty: 'beginner',
        estimatedHours: 15,
      ),
    ],
    'javascript': [
      LearningResource(
        name: 'JavaScript for Beginners - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=PkZNo7MFNFg',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: 'JavaScript30 - Wes Bos',
        type: 'Course',
        url: 'https://javascript30.com/',
        difficulty: 'intermediate',
        estimatedHours: 30,
      ),
      LearningResource(
        name: 'JavaScript.info',
        type: 'Tutorial',
        url: 'https://javascript.info/',
        difficulty: 'intermediate',
        estimatedHours: 20,
      ),
    ],
    'cpp': [
      LearningResource(
        name: 'C++ Tutorial - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=vLnPwxZdW4Y',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: 'C++ Complete Course',
        type: 'Course',
        url: 'https://www.udemy.com/course/beginning-c-plus-plus-programming/',
        difficulty: 'beginner',
        estimatedHours: 45,
      ),
    ],
    'sql': [
      LearningResource(
        name: 'SQL Tutorial - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=HXV3zeQKqGY',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: 'Complete SQL Bootcamp (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/the-complete-sql-bootcamp/',
        difficulty: 'intermediate',
        estimatedHours: 22,
      ),
      LearningResource(
        name: 'SQLZoo Interactive',
        type: 'Practice',
        url: 'https://sqlzoo.net/',
        difficulty: 'beginner',
        estimatedHours: 8,
      ),
    ],
    'typescript': [
      LearningResource(
        name: 'TypeScript Tutorial - The Net Ninja',
        type: 'Video',
        url: 'https://www.youtube.com/playlist?list=PL4cUxeGkcC9gUgr39Q_yD6v-bSyMwKPUI',
        difficulty: 'beginner',
        estimatedHours: 5,
      ),
      LearningResource(
        name: 'TypeScript Official Handbook',
        type: 'Documentation',
        url: 'https://www.typescriptlang.org/docs/handbook/',
        difficulty: 'intermediate',
        estimatedHours: 10,
      ),
    ],

    // ===== Web Development =====
    'html': [
      LearningResource(
        name: 'HTML Crash Course - Traversy Media',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=UB1O30fR-EE',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'MDN HTML Guide',
        type: 'Documentation',
        url: 'https://developer.mozilla.org/en-US/docs/Learn/HTML',
        difficulty: 'beginner',
        estimatedHours: 5,
      ),
    ],
    'css': [
      LearningResource(
        name: 'CSS Crash Course - Traversy Media',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=yfoY53QXEnI',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'Advanced CSS and Sass (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/advanced-css-and-sass/',
        difficulty: 'intermediate',
        estimatedHours: 28,
      ),
      LearningResource(
        name: 'CSS Flexbox & Grid - Kevin Powell',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=8QKOaTYvYUA',
        difficulty: 'intermediate',
        estimatedHours: 2,
      ),
    ],
    'react': [
      LearningResource(
        name: 'React Official Tutorial',
        type: 'Documentation',
        url: 'https://react.dev/learn',
        difficulty: 'beginner',
        estimatedHours: 8,
      ),
      LearningResource(
        name: 'React Course - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=bMknfKXIFA8',
        difficulty: 'beginner',
        estimatedHours: 12,
      ),
      LearningResource(
        name: 'React Complete Guide (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/react-the-complete-guide-incl-redux/',
        difficulty: 'intermediate',
        estimatedHours: 48,
      ),
    ],
    'nodejs': [
      LearningResource(
        name: 'Node.js Tutorial - Programming with Mosh',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=TlB_eWDSMt4',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'Node.js Complete Course (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/nodejs-the-complete-guide/',
        difficulty: 'intermediate',
        estimatedHours: 40,
      ),
      LearningResource(
        name: 'Express.js Crash Course',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=L72fhGm1tfE',
        difficulty: 'intermediate',
        estimatedHours: 2,
      ),
    ],
    'angular': [
      LearningResource(
        name: 'Angular Official Tutorial',
        type: 'Documentation',
        url: 'https://angular.io/tutorial',
        difficulty: 'beginner',
        estimatedHours: 8,
      ),
      LearningResource(
        name: 'Angular Complete Course (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/the-complete-guide-to-angular-2/',
        difficulty: 'intermediate',
        estimatedHours: 35,
      ),
    ],
    'vue': [
      LearningResource(
        name: 'Vue.js 3 Tutorial - The Net Ninja',
        type: 'Video',
        url: 'https://www.youtube.com/playlist?list=PL4cUxeGkcC9hYYGbV60Vq3IXYNfDk8At1',
        difficulty: 'beginner',
        estimatedHours: 6,
      ),
      LearningResource(
        name: 'Vue.js Official Guide',
        type: 'Documentation',
        url: 'https://vuejs.org/guide/introduction.html',
        difficulty: 'beginner',
        estimatedHours: 10,
      ),
    ],

    // ===== Data Science & AI =====
    'ml': [
      LearningResource(
        name: 'Machine Learning - Andrew Ng (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/machine-learning',
        difficulty: 'intermediate',
        estimatedHours: 60,
      ),
      LearningResource(
        name: 'ML Crash Course - Google',
        type: 'Course',
        url: 'https://developers.google.com/machine-learning/crash-course',
        difficulty: 'beginner',
        estimatedHours: 15,
      ),
      LearningResource(
        name: 'ML with Python - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=tPYj3fFJGjk',
        difficulty: 'beginner',
        estimatedHours: 10,
      ),
    ],
    'data_analysis': [
      LearningResource(
        name: 'Data Analysis with Python - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=r-uOLxNrNk8',
        difficulty: 'beginner',
        estimatedHours: 5,
      ),
      LearningResource(
        name: 'Pandas Tutorial - Kaggle',
        type: 'Tutorial',
        url: 'https://www.kaggle.com/learn/pandas',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: 'Data Analysis with Python (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/data-analysis-with-python',
        difficulty: 'intermediate',
        estimatedHours: 25,
      ),
    ],
    'statistics': [
      LearningResource(
        name: 'Statistics Fundamentals - StatQuest',
        type: 'Video',
        url: 'https://www.youtube.com/playlist?list=PLblh5JKOoLUK0FLuzwntyYI10UQFUhsY9',
        difficulty: 'beginner',
        estimatedHours: 10,
      ),
      LearningResource(
        name: 'Statistics with Python (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/specializations/statistics-with-python',
        difficulty: 'intermediate',
        estimatedHours: 40,
      ),
    ],
    'deep_learning': [
      LearningResource(
        name: 'Deep Learning Specialization (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/specializations/deep-learning',
        difficulty: 'advanced',
        estimatedHours: 80,
      ),
      LearningResource(
        name: 'Fast.ai Practical Deep Learning',
        type: 'Course',
        url: 'https://course.fast.ai/',
        difficulty: 'intermediate',
        estimatedHours: 40,
      ),
    ],
    'nlp': [
      LearningResource(
        name: 'NLP with Python - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=X2vAabgKiuM',
        difficulty: 'intermediate',
        estimatedHours: 3,
      ),
      LearningResource(
        name: 'NLP Specialization (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/specializations/natural-language-processing',
        difficulty: 'advanced',
        estimatedHours: 60,
      ),
    ],

    // ===== Tools & Technologies =====
    'git': [
      LearningResource(
        name: 'Git & GitHub Crash Course',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=RGOj5yH7evk',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'GitHub Learning Lab',
        type: 'Tutorial',
        url: 'https://skills.github.com/',
        difficulty: 'beginner',
        estimatedHours: 5,
      ),
      LearningResource(
        name: 'Pro Git Book',
        type: 'Book',
        url: 'https://git-scm.com/book/en/v2',
        difficulty: 'intermediate',
        estimatedHours: 10,
      ),
    ],
    'docker': [
      LearningResource(
        name: 'Docker Tutorial - TechWorld with Nana',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=3c-iBn73dDE',
        difficulty: 'intermediate',
        estimatedHours: 3,
      ),
      LearningResource(
        name: 'Docker & Kubernetes Complete (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/docker-kubernetes-the-practical-guide/',
        difficulty: 'intermediate',
        estimatedHours: 24,
      ),
    ],
    'linux': [
      LearningResource(
        name: 'Linux Command Line Basics',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=ZtqBQ68cfJc',
        difficulty: 'beginner',
        estimatedHours: 4,
      ),
      LearningResource(
        name: 'Linux Administration Course (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/linux-administration-bootcamp/',
        difficulty: 'intermediate',
        estimatedHours: 25,
      ),
    ],
    'aws': [
      LearningResource(
        name: 'AWS Cloud Practitioner - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=SOTamWNgDKc',
        difficulty: 'beginner',
        estimatedHours: 13,
      ),
      LearningResource(
        name: 'AWS Solutions Architect (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/aws-certified-solutions-architect-associate/',
        difficulty: 'intermediate',
        estimatedHours: 40,
      ),
    ],
    'networking': [
      LearningResource(
        name: 'Computer Networking - freeCodeCamp',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=qiQR5rTSshw',
        difficulty: 'beginner',
        estimatedHours: 9,
      ),
      LearningResource(
        name: 'Networking Fundamentals (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/computer-networking',
        difficulty: 'intermediate',
        estimatedHours: 30,
      ),
    ],
    'security': [
      LearningResource(
        name: 'Cybersecurity Fundamentals',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=hXSFdwIOfnE',
        difficulty: 'beginner',
        estimatedHours: 8,
      ),
      LearningResource(
        name: 'CompTIA Security+ (Udemy)',
        type: 'Course',
        url: 'https://www.udemy.com/course/securityplus/',
        difficulty: 'intermediate',
        estimatedHours: 20,
      ),
    ],

    // ===== Soft Skills & Core CS =====
    'communication': [
      LearningResource(
        name: 'Communication Skills - TED Talks',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=eIho2S0ZahI',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'Business Communication (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/wharton-communication-skills',
        difficulty: 'intermediate',
        estimatedHours: 12,
      ),
    ],
    'problem_solving': [
      LearningResource(
        name: 'Problem Solving Techniques',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=UFc-RPbq8kg',
        difficulty: 'beginner',
        estimatedHours: 2,
      ),
      LearningResource(
        name: 'Critical Thinking (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/critical-thinking-skills',
        difficulty: 'intermediate',
        estimatedHours: 15,
      ),
    ],
    'teamwork': [
      LearningResource(
        name: 'Teamwork Skills',
        type: 'Video',
        url: 'https://www.youtube.com/watch?v=_uMi4hxQeaw',
        difficulty: 'beginner',
        estimatedHours: 1,
      ),
      LearningResource(
        name: 'Teamwork Skills Course (Coursera)',
        type: 'Course',
        url: 'https://www.coursera.org/learn/teamwork-skills',
        difficulty: 'intermediate',
        estimatedHours: 10,
      ),
    ],
    'dsa': [
      LearningResource(
        name: 'DSA Course - Abdul Bari',
        type: 'Video',
        url: 'https://www.youtube.com/playlist?list=PLDN4rrl48XKpZkf03iYFl-O29szjTrs_O',
        difficulty: 'intermediate',
        estimatedHours: 50,
      ),
      LearningResource(
        name: 'LeetCode Practice',
        type: 'Practice',
        url: 'https://leetcode.com/',
        difficulty: 'intermediate',
        estimatedHours: 100,
      ),
      LearningResource(
        name: 'Striver\\'s SDE Sheet',
        type: 'Tutorial',
        url: 'https://takeuforward.org/interviews/strivers-sde-sheet-top-coding-interview-problems/',
        difficulty: 'intermediate',
        estimatedHours: 80,
      ),
      LearningResource(
        name: 'NeetCode Roadmap',
        type: 'Tutorial',
        url: 'https://neetcode.io/roadmap',
        difficulty: 'intermediate',
        estimatedHours: 60,
      ),
    ],
  };
}
