import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String role;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'Guest',
      role: json['role'] ?? 'free',
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
        'role': role,
      };
}

class AuthService extends StateNotifier<UserProfile?> {
  AuthService() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_profile');
    if (userStr != null) {
      state = UserProfile.fromJson(jsonDecode(userStr));
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    // Simulate login response
    final role = email.contains('pro') ? 'pro' : 'free';
    final name = email.split('@')[0];
    final formattedName = name[0].toUpperCase() + name.substring(1);
    
    final user = UserProfile(
      uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: formattedName,
      role: role,
    );

    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', jsonEncode(user.toJson()));
  }

  Future<void> signOut() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
  }

  String get token => state != null ? 'mock-token-${state!.role}-${state!.uid}' : '';
  bool get isAuthenticated => state != null;
}

final authServiceProvider = StateNotifierProvider<AuthService, UserProfile?>((ref) {
  return AuthService();
});
