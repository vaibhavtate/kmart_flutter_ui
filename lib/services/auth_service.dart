import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';

class AuthService {
  AuthService({required this._repository});

  final AuthRepository _repository;

  User? get currentUser => _repository.currentUser;

  Session? get currentSession => _repository.currentSession;

  Stream<AuthState> get authStateChanges => _repository.authStateChanges;

  Future<void> sendOtp({required String phone}) async {
    await _repository.sendOtp(phone: phone);
  }

  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return _repository.verifyOtp(phone: phone, token: token);
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  String normalizeIndianPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      return '+91$digits';
    }

    if (digits.length == 12 && digits.startsWith('91')) {
      return '+$digits';
    }

    if (phone.startsWith('+91') && digits.length == 12) {
      return '+$digits';
    }

    throw const FormatException('Enter a valid 10-digit Indian mobile number.');
  }

  bool isValidIndianPhone(String phone) {
    try {
      normalizeIndianPhone(phone);
      return true;
    } catch (_) {
      return false;
    }
  }
}
