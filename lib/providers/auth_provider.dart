import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authServiceProvider =
    Provider<AuthService>((ref) {
  return AuthService(
    repository: ref.watch(
      authRepositoryProvider,
    ),
  );
});

final authStateProvider =
    StreamProvider<AuthState>((ref) {
  return ref
      .watch(authServiceProvider)
      .authStateChanges;
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthControllerState>(
  AuthController.new,
);

class AuthControllerState {
  const AuthControllerState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.phone,
    this.error,
  });

  final bool isLoading;
  final bool isAuthenticated;
  final String? phone;
  final String? error;

  AuthControllerState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? phone,
    String? error,
    bool clearError = false,
  }) {
    return AuthControllerState(
      isLoading:
          isLoading ?? this.isLoading,
      isAuthenticated:
          isAuthenticated ?? this.isAuthenticated,
      phone: phone ?? this.phone,
      error: clearError
          ? null
          : error ?? this.error,
    );
  }
}

class AuthController
    extends Notifier<AuthControllerState> {
  late final AuthService _authService;

  @override
  AuthControllerState build() {
    _authService =
        ref.read(authServiceProvider);

    final authenticated =
        _authService.currentUser != null;

    return AuthControllerState(
      isAuthenticated: authenticated,
    );
  }

  Future<bool> sendOtp(
    String phone,
  ) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final normalized =
          _authService.normalizeIndianPhone(
        phone,
      );

      await _authService.sendOtp(
        phone: normalized,
      );

      state = state.copyWith(
        isLoading: false,
        phone: normalized,
        clearError: true,
      );

      return true;
    } on FormatException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );

      return false;
    } on AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );

      return false;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );

      return false;
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String token,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final normalized =
          _authService.normalizeIndianPhone(
        phone,
      );

      await _authService.verifyOtp(
        phone: normalized,
        token: token,
      );

      final authenticated =
          _authService.currentUser != null;

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: authenticated,
        phone: normalized,
        clearError: true,
      );

      return authenticated;
    } on AuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.message,
      );

      return false;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );

      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      await _authService.signOut();

      state = const AuthControllerState();
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}