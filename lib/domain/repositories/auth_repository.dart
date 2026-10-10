import '../models/token_data.dart';
import '../models/user.dart';

abstract class AuthRepository {
  Future<void> login({required String email});
  Future<void> signUp(User user);
  Future<TokenData> verifyOtp({required String email, required String otp});
  Future<void> resendOtp({required String email});
}
