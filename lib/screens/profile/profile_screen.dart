/// Profile screen showing user details
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../data/skills_data.dart';
import '../../data/job_roles_data.dart';
import '../../widgets/custom_button.dart';
import '../onboarding/profile_setup_screen.dart';
import '../onboarding/skill_assessment_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        final user = await firestoreService.getUser(authService.currentUser!.uid);
        if (mounted) {
          setState(() {
            _user = user;
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

  Future<void> _signOut() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    // Navigation will be handled automatically by AuthWrapper in main.dart
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
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBar(),
          const SizedBox(height: 24),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildPersonalInfo(),
          const SizedBox(height: 16),
          _buildAcademicInfo(),
          const SizedBox(height: 16),
          if (_user?.interests.isNotEmpty ?? false) ...[
            _buildInterests(),
            const SizedBox(height: 16),
          ],
          _buildSkillsInfo(),
          const SizedBox(height: 16),
          _buildTargetRole(),
          const SizedBox(height: 32),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
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
        Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
            ).then((_) => _loadProfile());
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              _user?.name.isNotEmpty == true 
                  ? _user!.name[0].toUpperCase() 
                  : 'S',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user?.name ?? 'Student',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user?.email ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 16),
          if (_user?.degree.isNotEmpty == true && _user?.branch.isNotEmpty == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_user!.degree} • ${_user!.branch}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return _buildInfoCard(
      title: 'Personal Information',
      icon: Icons.person_outlined,
      children: [
        _buildInfoRow('Full Name', _user?.name ?? 'Not set'),
        _buildInfoRow('Email', _user?.email ?? 'Not set'),
      ],
    );
  }

  Widget _buildAcademicInfo() {
    return _buildInfoCard(
      title: 'Academic Information',
      icon: Icons.school_outlined,
      children: [
        _buildInfoRow('Degree', _user?.degree.isNotEmpty == true ? _user!.degree : 'Not set'),
        _buildInfoRow('Branch', _user?.branch.isNotEmpty == true ? _user!.branch : 'Not set'),
        _buildInfoRow('Semester', _user?.semester.isNotEmpty == true ? _user!.semester : 'Not set'),
      ],
    );
  }

  Widget _buildInterests() {
    return _buildInfoCard(
      title: 'Areas of Interest',
      icon: Icons.interests_outlined,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _user!.interests.map((interest) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              interest,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsInfo() {
    final skillCount = _user?.skills.length ?? 0;
    
    return _buildInfoCard(
      title: 'My Skills',
      icon: Icons.code_outlined,
      trailing: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SkillAssessmentScreen()),
          ).then((_) => _loadProfile());
        },
        icon: const Icon(Icons.edit, size: 16),
        label: const Text('Edit'),
      ),
      children: [
        if (skillCount == 0)
          Text(
            'No skills added yet',
            style: TextStyle(color: AppTheme.textSecondary),
          )
        else ...[
          Text(
            '$skillCount skills added',
            style: TextStyle(
              color: AppTheme.textSecondary,
              marginBottom: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _user!.skills.entries.map((entry) {
              final skill = SkillsData.getSkillById(entry.key);
              if (skill == null) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _getLevelColor(entry.value).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getLevelColor(entry.value).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getLevelColor(entry.value),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getLevelColor(entry.value),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.value[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTargetRole() {
    final role = _user?.selectedJobRole != null 
        ? JobRolesData.getRoleById(_user!.selectedJobRole!)
        : null;

    return _buildInfoCard(
      title: 'Target Career',
      icon: Icons.work_outlined,
      children: [
        if (role == null)
          Text(
            'No target role selected',
            style: TextStyle(color: AppTheme.textSecondary),
          )
        else
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(role.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
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
              Icon(icon, color: AppTheme.primaryColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return CustomButton(
      text: 'Sign Out',
      icon: Icons.logout,
      isOutlined: true,
      onPressed: _signOut,
      width: double.infinity,
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.orange;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
