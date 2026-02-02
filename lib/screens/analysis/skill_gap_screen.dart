/// Skill gap analysis screen - Uses Flask Backend API
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../dashboard/dashboard_screen.dart';
import '../roadmap/roadmap_screen.dart';

class SkillGapScreen extends StatefulWidget {
  const SkillGapScreen({super.key});

  @override
  State<SkillGapScreen> createState() => _SkillGapScreenState();
}

class _SkillGapScreenState extends State<SkillGapScreen> {
  Map<String, dynamic>? _analysisData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        final user = await firestoreService.getUser(authService.currentUser!.uid);
        
        if (user != null && user.selectedJobRole != null) {
          // Call Flask Backend API for analysis
          final analysis = await ApiService.analyzeGap(
            userSkills: user.skills,
            targetRole: user.selectedJobRole!,
          );
          
          if (mounted) {
            setState(() {
              _analysisData = analysis;
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = 'Please complete your profile first';
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unable to load analysis',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Go to Dashboard',
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final targetRole = _analysisData?['target_role'] ?? {};
    final matchPercentage = _analysisData?['match_percentage'] ?? 0;
    final proficientSkills = _analysisData?['proficient_skills'] ?? [];
    final skillsToImprove = _analysisData?['skills_to_improve'] ?? [];
    final missingSkills = _analysisData?['missing_skills'] ?? [];

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 24),
                _buildHeader(targetRole),
                const SizedBox(height: 24),
                _buildScoreCard(targetRole, matchPercentage),
                const SizedBox(height: 16),
                if (proficientSkills.isNotEmpty) ...[
                  _buildSkillSection(
                    'Proficient Skills',
                    'Skills you already have',
                    Icons.check_circle,
                    AppTheme.accentColor,
                    proficientSkills,
                    isProficient: true,
                  ),
                  const SizedBox(height: 16),
                ],
                if (skillsToImprove.isNotEmpty) ...[
                  _buildSkillSection(
                    'Skills to Improve',
                    'Upgrade your proficiency level',
                    Icons.trending_up,
                    AppTheme.warningColor,
                    skillsToImprove,
                  ),
                  const SizedBox(height: 16),
                ],
                if (missingSkills.isNotEmpty) ...[
                  _buildSkillSection(
                    'Missing Skills',
                    'Skills you need to learn',
                    Icons.add_circle,
                    AppTheme.errorColor,
                    missingSkills,
                    isMissing: true,
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 24),
                CustomButton(
                  text: 'View Learning Roadmap',
                  icon: Icons.map_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoadmapScreen(
                        missingSkills: missingSkills,
                        skillsToImprove: skillsToImprove,
                      ),
                    ),
                  ),
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Go to Dashboard',
                  icon: Icons.dashboard,
                  isOutlined: true,
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  ),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(Map<String, dynamic> role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Gap Analysis',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Your skills vs ${role['name'] ?? 'Job Role'} requirements',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> role, int percentage) {
    final color = percentage >= 70 
        ? AppTheme.accentColor 
        : percentage >= 40 
            ? AppTheme.warningColor 
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                role['icon'] ?? '💼',
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                role['name'] ?? 'Target Role',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Match',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _getMatchMessage(percentage),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _getMatchMessage(int percentage) {
    if (percentage >= 80) {
      return 'Excellent! You\'re well-prepared for this role!';
    } else if (percentage >= 60) {
      return 'Good progress! A few more skills to master.';
    } else if (percentage >= 40) {
      return 'You\'re on your way! Keep learning and practicing.';
    } else {
      return 'Start your learning journey today!';
    }
  }

  Widget _buildSkillSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<dynamic> skills, {
    bool isProficient = false,
    bool isMissing = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${skills.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...skills.map((skill) => _buildSkillItem(skill, color, isProficient, isMissing)),
        ],
      ),
    );
  }

  Widget _buildSkillItem(Map<String, dynamic> skill, Color color, bool isProficient, bool isMissing) {
    final skillName = skill['skill_name'] ?? '';
    final currentLevel = skill['current_level'] ?? '';
    final requiredLevel = skill['required_level'] ?? 'intermediate';
    final category = skill['category'] ?? '';

    String description;
    if (isMissing) {
      description = 'Required: $requiredLevel • Category: $category';
    } else if (isProficient) {
      description = 'Level: $currentLevel • $category';
    } else {
      description = '$currentLevel → $requiredLevel • $category';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skillName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isProficient)
            Icon(Icons.check_circle, color: color, size: 20),
        ],
      ),
    );
  }
}
