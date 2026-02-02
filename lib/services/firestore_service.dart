/// Firestore service for user data operations
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/skill_model.dart';
import '../models/job_role_model.dart';
import '../data/skills_data.dart';
import '../data/job_roles_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  /// Create a new user profile
  Future<void> createUser(UserModel user) async {
    await _usersCollection.doc(user.uid).set({
      ...user.toMap(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get user profile
  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
    }
    return null;
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  /// Update user profile
  Future<void> updateUser(UserModel user) async {
    await _usersCollection.doc(user.uid).update(user.toMap());
  }

  /// Update specific user fields
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    fields['updatedAt'] = DateTime.now().toIso8601String();
    await _usersCollection.doc(uid).update(fields);
  }

  /// Save user skills
  Future<void> saveUserSkills(String uid, Map<String, String> skills) async {
    await _usersCollection.doc(uid).update({
      'skills': skills,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Save selected job role
  Future<void> saveSelectedJobRole(String uid, String jobRoleId) async {
    await _usersCollection.doc(uid).update({
      'selectedJobRole': jobRoleId,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Mark profile as complete
  Future<void> markProfileComplete(String uid) async {
    await _usersCollection.doc(uid).update({
      'isProfileComplete': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream user data for real-time updates
  Stream<UserModel?> streamUser(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    });
  }

  /// Perform skill gap analysis
  SkillGapAnalysis analyzeSkillGap(
    Map<String, String> userSkills, 
    String jobRoleId,
  ) {
    final jobRole = JobRolesData.getRoleById(jobRoleId);
    if (jobRole == null) {
      throw Exception('Job role not found');
    }

    final gaps = <SkillGap>[];
    final strongSkills = <String>[];
    int matchedSkillPoints = 0;
    int totalRequiredPoints = 0;

    for (final entry in jobRole.requiredSkills.entries) {
      final skillId = entry.key;
      final requiredLevel = entry.value;
      final skill = SkillsData.getSkillById(skillId);
      
      if (skill == null) continue;

      totalRequiredPoints += requiredLevel.value;

      if (userSkills.containsKey(skillId)) {
        final userLevel = SkillLevel.fromString(userSkills[skillId]!);
        final gap = requiredLevel.value - userLevel.value;
        
        if (gap <= 0) {
          strongSkills.add(skill.name);
          matchedSkillPoints += requiredLevel.value;
        } else {
          matchedSkillPoints += userLevel.value;
        }

        gaps.add(SkillGap(
          skillId: skillId,
          skillName: skill.name,
          currentLevel: userLevel,
          requiredLevel: requiredLevel,
          isMissing: false,
        ));
      } else {
        gaps.add(SkillGap(
          skillId: skillId,
          skillName: skill.name,
          currentLevel: null,
          requiredLevel: requiredLevel,
          isMissing: true,
        ));
      }
    }

    final matchPercentage = totalRequiredPoints > 0 
        ? ((matchedSkillPoints / totalRequiredPoints) * 100).round()
        : 0;

    return SkillGapAnalysis(
      targetRole: jobRole,
      gaps: gaps,
      matchPercentage: matchPercentage,
      strongSkills: strongSkills,
    );
  }
}
