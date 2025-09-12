import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TempAuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _userKey = 'temp_auth_user';
  static const String _sessionKey = 'temp_auth_session';

  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
      );

      if (response.session != null) {
        await _saveSession(response.session!);
        await _saveUser(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _saveSession(response.session!);
        await _saveUser(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await _clearLocalData();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Get current session
  static Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }

  // Get user from local storage
  static Future<User?> getLocalUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get session from local storage
  static Future<Session?> getLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionMap = json.decode(sessionJson) as Map<String, dynamic>;
        return Session.fromJson(sessionMap);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Initialize session from local storage
  static Future<bool> initializeSession() async {
    try {
      final localSession = await getLocalSession();
      
      if (localSession != null) {
        // Check if session is still valid
        if (localSession.expiresAt != null && 
            DateTime.fromMillisecondsSinceEpoch(localSession.expiresAt! * 1000)
                .isAfter(DateTime.now())) {
          return true;
        } else {
          // Session expired, clear local data
          await _clearLocalData();
          return false;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods
  static Future<void> _saveSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = json.encode(session.toJson());
      await prefs.setString(_sessionKey, sessionJson);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> _saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_sessionKey);
    } catch (e) {
      // Handle error silently
    }
  }

  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  static Future<UserResponse> updateProfile({
    String? email,
    String? password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: data,
        ),
      );

      if (response.user != null) {
        await _saveUser(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
