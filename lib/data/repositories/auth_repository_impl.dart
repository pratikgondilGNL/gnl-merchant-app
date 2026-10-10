import '../../domain/models/token_data.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<void> login({required String email}) async {
    final response = await _apiClient.post(ApiEndpoints.login, data: {
      'email': email,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['status'] != true) {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> signUp(User user) async {
    final response = await _apiClient.post(ApiEndpoints.signUp, data: {
      'mobile': user.phone,
      'full_name': user.fullName,
      'email': user.email,
      'city': user.city,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['status'] != true) {
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  @override
  Future<TokenData> verifyOtp(
      {required String email, required String otp}) async {
    final response = await _apiClient.post(ApiEndpoints.verifyOtp, data: {
      'email': email,
      'otp': otp,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['status'] != true) {
      throw Exception(data['message'] ?? 'OTP verification failed');
    }
    final result = data['result'] as Map<String, dynamic>? ?? {};
    final tokens = result['tokens'] as Map<String, dynamic>?;
    return TokenData.fromJson(tokens ?? (result.isEmpty ? data : result));
  }

  @override
  Future<void> resendOtp({required String email}) async {
    final response = await _apiClient.post(ApiEndpoints.resendOtp, data: {
      'email': email,
    });
    final data = response.data as Map<String, dynamic>;
    if (data['status'] != true) {
      throw Exception(data['message'] ?? 'Resend failed');
    }
  }
}
