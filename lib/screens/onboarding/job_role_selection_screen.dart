/// Job role selection screen
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../data/job_roles_data.dart';
import '../../widgets/custom_button.dart';
import '../analysis/skill_gap_screen.dart';

class JobRoleSelectionScreen extends StatefulWidget {
  const JobRoleSelectionScreen({super.key});

  @override
  State<JobRoleSelectionScreen> createState() => _JobRoleSelectionScreenState();
}

class _JobRoleSelectionScreenState extends State<JobRoleSelectionScreen> {
  String? _selectedRoleId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingRole();
  }

  Future<void> _loadExistingRole() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    
    if (authService.currentUser != null) {
      final user = await firestoreService.getUser(authService.currentUser!.uid);
      if (user != null && user.selectedJobRole != null && mounted) {
        setState(() {
          _selectedRoleId = user.selectedJobRole;
        });
      }
    }
  }

  Future<void> _saveAndAnalyze() async {
    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a job role'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        await firestoreService.saveSelectedJobRole(
          authService.currentUser!.uid,
          _selectedRoleId!,
        );
        
        await firestoreService.markProfileComplete(authService.currentUser!.uid);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SkillGapScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
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
          child: Column(
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
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildRolesList(),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Analyze My Skills',
                        icon: Icons.analytics_outlined,
                        isLoading: _isLoading,
                        onPressed: _saveAndAnalyze,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        final isActive = index <= 2;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppTheme.primaryColor 
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Target Role',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Select the job role you want to pursue. We\'ll analyze your skills against the requirements.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRolesList() {
    return Column(
      children: JobRolesData.allRoles.map((role) {
        final isSelected = role.id == _selectedRoleId;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedRoleId = role.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected 
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      role.icon,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${role.requiredSkills.length} skills required',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: role.id,
                  groupValue: _selectedRoleId,
                  onChanged: (value) => setState(() => _selectedRoleId = value),
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
