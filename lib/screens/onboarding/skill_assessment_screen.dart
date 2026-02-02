/// Skill assessment screen for selecting skills and levels
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/skill_model.dart';
import '../../data/skills_data.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/skill_chip.dart';
import 'job_role_selection_screen.dart';

class SkillAssessmentScreen extends StatefulWidget {
  const SkillAssessmentScreen({super.key});

  @override
  State<SkillAssessmentScreen> createState() => _SkillAssessmentScreenState();
}

class _SkillAssessmentScreenState extends State<SkillAssessmentScreen> {
  final Map<String, SkillLevel> _selectedSkills = {};
  SkillCategory _currentCategory = SkillCategory.programming;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSkills();
  }

  Future<void> _loadExistingSkills() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    
    if (authService.currentUser != null) {
      final user = await firestoreService.getUser(authService.currentUser!.uid);
      if (user != null && user.skills.isNotEmpty && mounted) {
        setState(() {
          for (final entry in user.skills.entries) {
            _selectedSkills[entry.key] = SkillLevel.fromString(entry.value);
          }
        });
      }
    }
  }

  Future<void> _saveSkills() async {
    if (_selectedSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one skill'),
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
        final skillsMap = _selectedSkills.map(
          (key, value) => MapEntry(key, value.name),
        );
        
        await firestoreService.saveUserSkills(
          authService.currentUser!.uid,
          skillsMap,
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const JobRoleSelectionScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving skills: $e'),
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
                      _buildCategoryTabs(),
                      const SizedBox(height: 16),
                      _buildSkillsList(),
                      const SizedBox(height: 16),
                      _buildSelectedSkillsSummary(),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Continue to Job Roles',
                        icon: Icons.arrow_forward,
                        isLoading: _isLoading,
                        onPressed: _saveSkills,
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
          Text(
            '${_selectedSkills.length} skills selected',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= 1;
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
          'Select Your Skills',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Choose skills you have and rate your proficiency level',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SkillCategory.values.map((category) {
          final isSelected = category == _currentCategory;
          final skillCount = SkillsData.getSkillsByCategory(category).length;
          final selectedCount = _selectedSkills.keys.where((id) {
            final skill = SkillsData.getSkillById(id);
            return skill?.category == category;
          }).length;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(category.displayName),
                  if (selectedCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$selectedCount/$skillCount',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (_) => setState(() => _currentCategory = category),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillsList() {
    final skills = SkillsData.getSkillsByCategory(_currentCategory);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: skills.map((skill) {
          return SkillSelectionCard(
            skill: skill,
            selectedLevel: _selectedSkills[skill.id],
            onLevelChanged: (level) {
              setState(() {
                if (level == null) {
                  _selectedSkills.remove(skill.id);
                } else {
                  _selectedSkills[skill.id] = level;
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedSkillsSummary() {
    if (_selectedSkills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Selected Skills',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedSkills.entries.map((entry) {
              final skill = SkillsData.getSkillById(entry.key);
              if (skill == null) return const SizedBox.shrink();
              return SkillChip(
                skill: skill,
                level: entry.value,
                isSelected: true,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
