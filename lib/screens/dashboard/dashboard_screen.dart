/// Main dashboard screen with progress overview
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/job_role_model.dart';
import '../../data/job_roles_data.dart';
import '../../widgets/progress_card.dart';
import '../analysis/skill_gap_screen.dart';
import '../roadmap/roadmap_screen.dart';
import '../onboarding/skill_assessment_screen.dart';
import '../onboarding/job_role_selection_screen.dart';
import '../profile/profile_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
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
        
        SkillGapAnalysis? analysis;
        if (user != null && user.selectedJobRole != null && user.skills.isNotEmpty) {
          analysis = firestoreService.analyzeSkillGap(
            user.skills,
            user.selectedJobRole!,
          );
        }
        
        if (mounted) {
          setState(() {
            _user = user;
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
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        if (_analysis != null) ...[
                          _buildProgressCard(),
                          const SizedBox(height: 16),
                          _buildStatsRow(),
                          const SizedBox(height: 24),
                        ],
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildSkillsOverview(),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, ${_user?.name.split(' ').first ?? 'Student'}! 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Track your progress and grow your skills',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Text(
              (_user?.name.isNotEmpty ?? false) 
                  ? _user!.name[0].toUpperCase() 
                  : 'S',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onSelected: (value) async {
            if (value == 'signout') {
              await context.read<AuthService>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            } else if (value == 'profile') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => _loadData());
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text('My Profile'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'signout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('Sign Out', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final role = JobRolesData.getRoleById(_user?.selectedJobRole ?? '');
    
    return ProgressCard(
      title: role?.name ?? 'Target Role',
      subtitle: 'Skill match for your target role',
      percentage: _analysis?.matchPercentage ?? 0,
      icon: Icons.trending_up,
      color: _getProgressColor(_analysis?.matchPercentage ?? 0),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SkillGapScreen()),
      ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage >= 70) return AppTheme.accentColor;
    if (percentage >= 40) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${_user?.skills.length ?? 0}',
            label: 'Skills',
            icon: Icons.code,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '${_analysis?.proficientSkills.length ?? 0}',
            label: 'Proficient',
            icon: Icons.check_circle_outline,
            color: AppTheme.accentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '${_analysis?.missingSkills.length ?? 0}',
            label: 'To Learn',
            icon: Icons.add_circle_outline,
            color: AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          title: 'View Roadmap',
          description: 'See your personalized learning path',
          icon: Icons.map_outlined,
          color: AppTheme.primaryColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoadmapScreen()),
          ),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Update Skills',
          description: 'Add new skills or update levels',
          icon: Icons.edit_outlined,
          color: AppTheme.accentColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SkillAssessmentScreen()),
          ),
        ),
        const SizedBox(height: 12),
        QuickActionCard(
          title: 'Change Target Role',
          description: 'Explore different career paths',
          icon: Icons.swap_horiz,
          color: AppTheme.warningColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobRoleSelectionScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsOverview() {
    if (_analysis == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills Overview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              _buildSkillCategory(
                'Strong Skills',
                _analysis!.strongSkills,
                AppTheme.accentColor,
                Icons.check_circle,
              ),
              if (_analysis!.skillsToImprove.isNotEmpty) ...[
                const Divider(height: 24),
                _buildSkillCategory(
                  'Needs Improvement',
                  _analysis!.skillsToImprove.map((g) => g.skillName).toList(),
                  AppTheme.warningColor,
                  Icons.trending_up,
                ),
              ],
              if (_analysis!.missingSkills.isNotEmpty) ...[
                const Divider(height: 24),
                _buildSkillCategory(
                  'To Learn',
                  _analysis!.missingSkills.map((g) => g.skillName).toList(),
                  AppTheme.errorColor,
                  Icons.add_circle,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCategory(
    String title,
    List<String> skills,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Text(
              '${skills.length}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (skills.isEmpty)
          Text(
            'None yet',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
      ],
    );
  }
}
