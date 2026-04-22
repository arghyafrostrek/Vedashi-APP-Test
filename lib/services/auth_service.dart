import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// POST /api/auth/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
      'remember_me': true,
      'source': 'storefront',
    });

    final data = response.data;
    if (data['success'] == true) {
      final tokens = data['data'];
      await _storage.write(key: 'access_token', value: tokens['access_token']);
      await _storage.write(key: 'refresh_token', value: tokens['refresh_token']);
    }
    return data;
  }

  /// POST /api/auth/register
  Future<Map<String, dynamic>> register(String fullName, String email, String password, {String? phone}) async {
    final response = await _api.post(ApiConstants.register, data: {
      'full_name': fullName,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
    });
    return response.data;
  }

  /// GET /api/auth/me
  Future<User?> getMe() async {
    try {
      final response = await _api.get(ApiConstants.getMe);
      if (response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// POST /api/auth/logout
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      await _api.post(ApiConstants.logout, data: {
        if (refreshToken != null) 'refresh_token': refreshToken,
      });
    } catch (_) {}
    await _storage.deleteAll();
  }

  /// POST /api/auth/refresh-token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _api.post(ApiConstants.refreshToken, data: {
        'refresh_token': refreshToken,
      });

      if (response.data['success'] == true) {
        final tokens = response.data['data'];
        await _storage.write(key: 'access_token', value: tokens['access_token']);
        await _storage.write(key: 'refresh_token', value: tokens['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// POST /api/auth/forgot-password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _api.post(ApiConstants.forgotPassword, data: {'email': email});
    return response.data;
  }

  /// POST /api/auth/verify-email
  Future<Map<String, dynamic>> verifyEmail(String otpCode, {String? email}) async {
    final response = await _api.post(ApiConstants.verifyEmail, data: {
      'otp_code': otpCode,
      if (email != null) 'email': email,
    });
    return response.data;
  }

  /// PUT /api/auth/change-password
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    final response = await _api.put(ApiConstants.changePassword, data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
    return response.data;
  }

  /// Check if user has stored token (for auto-login)
  Future<bool> hasToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }
}
