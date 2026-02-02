/// Profile setup screen for student information
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import 'skill_assessment_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String? _selectedDegree;
  String? _selectedBranch;
  String? _selectedSemester;
  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  final List<String> _degrees = [
    'B.Tech',
    'B.E',
    'BCA',
    'MCA',
    'M.Tech',
    'BSc Computer Science',
    'MSc Computer Science',
  ];

  final List<String> _branches = [
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
    'Electrical',
    'Data Science',
    'AI & ML',
  ];

  final List<String> _semesters = [
    '1st Semester',
    '2nd Semester',
    '3rd Semester',
    '4th Semester',
    '5th Semester',
    '6th Semester',
    '7th Semester',
    '8th Semester',
    'Graduated',
  ];

  final List<String> _interests = [
    'Frontend Development',
    'Backend Development',
    'Full Stack Development',
    'Mobile Development',
    'Data Science',
    'Machine Learning',
    'Artificial Intelligence',
    'Cloud Computing',
    'Cybersecurity',
    'DevOps',
    'Blockchain',
    'Game Development',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    
    if (authService.currentUser != null) {
      final user = await firestoreService.getUser(authService.currentUser!.uid);
      if (user != null && mounted) {
        setState(() {
          _nameController.text = user.name;
          _selectedDegree = user.degree.isNotEmpty ? user.degree : null;
          _selectedBranch = user.branch.isNotEmpty ? user.branch : null;
          _selectedSemester = user.semester.isNotEmpty ? user.semester : null;
          _selectedInterests.addAll(user.interests);
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDegree == null || _selectedBranch == null || _selectedSemester == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        await firestoreService.updateUserFields(
          authService.currentUser!.uid,
          {
            'name': _nameController.text.trim(),
            'degree': _selectedDegree,
            'branch': _selectedBranch,
            'semester': _selectedSemester,
            'interests': _selectedInterests,
          },
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SkillAssessmentScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProgressIndicator(),
                        const SizedBox(height: 24),
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 16),
                        _buildAcademicInfoCard(),
                        const SizedBox(height: 16),
                        _buildInterestsCard(),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: 'Continue to Skills',
                          icon: Icons.arrow_forward,
                          isLoading: _isLoading,
                          onPressed: _saveProfile,
                          width: double.infinity,
                        ),
                      ],
                    ),
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
          const Spacer(),
          TextButton(
            onPressed: () {
              context.read<AuthService>().signOut();
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index == 0;
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
          'Complete Your Profile',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about yourself so we can personalize your experience',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoCard() {
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
              Icon(Icons.person_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoCard() {
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
              Icon(Icons.school_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Academic Information',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDegree,
            decoration: const InputDecoration(
              labelText: 'Degree *',
            ),
            items: _degrees.map((degree) => DropdownMenuItem(
              value: degree,
              child: Text(degree),
            )).toList(),
            onChanged: (value) => setState(() => _selectedDegree = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedBranch,
            decoration: const InputDecoration(
              labelText: 'Branch / Specialization *',
            ),
            items: _branches.map((branch) => DropdownMenuItem(
              value: branch,
              child: Text(branch),
            )).toList(),
            onChanged: (value) => setState(() => _selectedBranch = value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedSemester,
            decoration: const InputDecoration(
              labelText: 'Current Semester *',
            ),
            items: _semesters.map((sem) => DropdownMenuItem(
              value: sem,
              child: Text(sem),
            )).toList(),
            onChanged: (value) => setState(() => _selectedSemester = value),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsCard() {
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
              Icon(Icons.interests_outlined, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Areas of Interest',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply (optional)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedInterests.add(interest);
                    } else {
                      _selectedInterests.remove(interest);
                    }
                  });
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
