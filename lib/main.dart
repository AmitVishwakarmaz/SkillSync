/// SkillSync - Skill Gap Analysis Application
/// Main entry point with Firebase initialization and app configuration
library;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'models/user_model.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/profile_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SkillSyncApp());
}

class SkillSyncApp extends StatelessWidget {
  const SkillSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'SkillSync',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles authentication state and navigation
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Authenticated - check if profile is complete
        return const ProfileChecker();
      },
    );
  }
}

/// Widget that checks if user profile is complete and navigates accordingly
class ProfileChecker extends StatefulWidget {
  const ProfileChecker({super.key});

  @override
  State<ProfileChecker> createState() => _ProfileCheckerState();
}

class _ProfileCheckerState extends State<ProfileChecker> {
  bool _isLoading = true;
  bool? _isProfileComplete;

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      
      if (authService.currentUser != null) {
        // Check if user exists in Firestore
        final userExists = await firestoreService.userExists(
          authService.currentUser!.uid,
        );
        
        if (!userExists) {
          // Create new user document for Google Sign-In users
          await firestoreService.createUser(
            UserModel(
              uid: authService.currentUser!.uid,
              email: authService.currentUser!.email ?? '',
              name: authService.currentUser!.displayName ?? '',
              createdAt: DateTime.now(),
            ),
          );
        }
        
        // Get user data
        final user = await firestoreService.getUser(authService.currentUser!.uid);
        
        if (mounted) {
          setState(() {
            _isProfileComplete = user?.isProfileComplete ?? false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProfileComplete = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading your profile...'),
            ],
          ),
        ),
      );
    }

    // Navigate to appropriate screen based on profile status
    if (_isProfileComplete == true) {
      return const DashboardScreen();
    } else {
      return const ProfileSetupScreen();
    }
  }
}
