import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../../features/auth/models/auth_models.dart';
import '../../features/auth/models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post('/auth/register', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.data['detail'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Registration failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      // FastAPI OAuth2 expects form data for token endpoint
      final formData = FormData.fromMap({
        'username': request.email,
        'password': request.password,
      });

      final response = await _apiService.post('/auth/token', data: formData);
      
      if (response.statusCode == 200) {
        final tokenData = response.data;
        
        // Get user profile after successful login
        final userResponse = await _apiService.get('/auth/me');
        final user = User.fromJson(userResponse.data);
        
        final authResponse = AuthResponse(
          accessToken: tokenData['access_token'],
          tokenType: tokenData['token_type'] ?? 'bearer',
          user: user,
        );
        
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Login failed: ${response.data['detail'] ?? 'Unknown error'}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['detail'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get('/auth/me');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please login again.');
      }
      throw Exception('Failed to get user profile: ${e.message}');
    }
  }

  // Update user profile
  Future<User> updateProfile({
    String? fullName,
    double? dailyCalorieGoal,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (dailyCalorieGoal != null) data['daily_calorie_goal'] = dailyCalorieGoal;

      final response = await _apiService.put('/auth/profile', data: data);
      final updatedUser = User.fromJson(response.data);
      
      // Update stored user data
      await _storage.write(
        key: AppConstants.userDataKey,
        value: jsonEncode(updatedUser.toJson()),
      );
      
      return updatedUser;
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.response?.data['detail'] ?? e.message}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Clear local storage
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
      
      // Optional: Call logout endpoint to invalidate token on server
      await _apiService.post('/auth/logout');
    } catch (e) {
      // Even if server logout fails, clear local data
      await _storage.delete(key: AppConstants.accessTokenKey);
      await _storage.delete(key: AppConstants.userDataKey);
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userData = await _storage.read(key: AppConstants.userDataKey);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get stored access token
  Future<String?> getStoredToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  // Save authentication data to secure storage
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _storage.write(
      key: AppConstants.accessTokenKey,
      value: authResponse.accessToken,
    );
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(authResponse.user.toJson()),
    );
  }

  // Refresh user data from server
  Future<User> refreshUserData() async {
    final user = await getCurrentUser();
    await _storage.write(
      key: AppConstants.userDataKey,
      value: jsonEncode(user.toJson()),
    );
    return user;
  }
}

// Riverpod provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
