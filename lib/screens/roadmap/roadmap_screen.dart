/// Personalized roadmap screen showing learning path
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/job_role_model.dart';
import '../../models/skill_model.dart';
import '../../data/skills_data.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  SkillGapAnalysis? _analysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        final user = await firestoreService.getUser(authService.currentUser!.uid);
        if (user != null && user.selectedJobRole != null && mounted) {
          final analysis = firestoreService.analyzeSkillGap(
            user.skills,
            user.selectedJobRole!,
          );
          setState(() {
            _analysis = analysis;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
              : _analysis == null
                  ? _buildEmptyState()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No roadmap available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile to get a personalized learning path',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final allSkillsToLearn = [
      ..._analysis!.missingSkills,
      ..._analysis!.skillsToImprove,
    ];

    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildRoadmapOverview(allSkillsToLearn.length),
                const SizedBox(height: 24),
                _buildLearningTimeline(allSkillsToLearn),
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Learning Roadmap',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _analysis!.targetRole.icon,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your path to becoming a',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _analysis!.targetRole.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapOverview(int totalSkills) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          _buildOverviewItem(
            '${_analysis!.missingSkills.length}',
            'New Skills',
            AppTheme.errorColor,
            Icons.add_circle,
          ),
          _buildDivider(),
          _buildOverviewItem(
            '${_analysis!.skillsToImprove.length}',
            'To Improve',
            AppTheme.warningColor,
            Icons.trending_up,
          ),
          _buildDivider(),
          _buildOverviewItem(
            '${_analysis!.proficientSkills.length}',
            'Complete',
            AppTheme.accentColor,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildLearningTimeline(List<SkillGap> skills) {
    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          children: [
            Icon(
              Icons.celebration,
              size: 64,
              color: AppTheme.accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have all the skills needed for this role!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    // Sort by priority: missing skills first, then by required level
    final sortedSkills = List<SkillGap>.from(skills);
    sortedSkills.sort((a, b) {
      if (a.isMissing != b.isMissing) {
        return a.isMissing ? -1 : 1;
      }
      return b.requiredLevel.value.compareTo(a.requiredLevel.value);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learning Path',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Follow this roadmap to reach your goal',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        ...sortedSkills.asMap().entries.map((entry) {
          final index = entry.key;
          final gap = entry.value;
          final isLast = index == sortedSkills.length - 1;
          
          return _buildTimelineItem(gap, index + 1, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineItem(SkillGap gap, int step, bool isLast) {
    final skill = SkillsData.getSkillById(gap.skillId);
    final color = gap.isMissing ? AppTheme.errorColor : AppTheme.warningColor;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        gap.skillName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        gap.isMissing ? 'New' : 'Upgrade',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (skill?.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    skill!.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      'Target: ${gap.requiredLevel.displayName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (!gap.isMissing) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.arrow_upward, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(
                        'From ${gap.currentLevel?.displayName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
