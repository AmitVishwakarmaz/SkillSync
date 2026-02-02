/// User model for student profile
library;

class UserModel {
  final String uid;
  final String email;
  String name;
  String degree;
  String branch;
  String semester;
  List<String> interests;
  Map<String, String> skills; // skillId -> level (beginner/intermediate/advanced)
  String? selectedJobRole;
  bool isProfileComplete;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.degree = '',
    this.branch = '',
    this.semester = '',
    this.interests = const [],
    this.skills = const {},
    this.selectedJobRole,
    this.isProfileComplete = false,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      degree: map['degree'] ?? '',
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      skills: Map<String, String>.from(map['skills'] ?? {}),
      selectedJobRole: map['selectedJobRole'],
      isProfileComplete: map['isProfileComplete'] ?? false,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : null,
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'degree': degree,
      'branch': branch,
      'semester': semester,
      'interests': interests,
      'skills': skills,
      'selectedJobRole': selectedJobRole,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? name,
    String? degree,
    String? branch,
    String? semester,
    List<String>? interests,
    Map<String, String>? skills,
    String? selectedJobRole,
    bool? isProfileComplete,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      degree: degree ?? this.degree,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      interests: interests ?? this.interests,
      skills: skills ?? this.skills,
      selectedJobRole: selectedJobRole ?? this.selectedJobRole,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
