import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../providers/providers.dart';

/// UI state for auth screens.
class AuthState {
  const AuthState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthViewModel extends StateNotifier<AuthState> {
  AuthViewModel(this._auth) : super(const AuthState());

  final AuthRepository _auth;

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
      return response.user != null;
    } catch (e) {
      final message = _authErrorMessage(e, isSignUp: false);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  Future<bool> signUp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null,
      );
      state = state.copyWith(isLoading: false);
      return response.user != null;
    } catch (e) {
      final message = _authErrorMessage(e, isSignUp: true);
      state = state.copyWith(isLoading: false, errorMessage: message);
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  static String _authErrorMessage(Object e, {required bool isSignUp}) {
    final prefix = isSignUp ? 'Failed to create account. ' : 'Failed to sign in. ';
    final s = e.toString();
    if (s.contains('Operation not permitted') || s.contains('SocketConnection failed')) {
      return '$prefix Network permission denied. Please check your network settings and try again.';
    }
    if (s.contains('Invalid login credentials')) {
      return '$prefix Invalid email or password.';
    }
    if (isSignUp && s.contains('User already registered')) {
      return '$prefix An account with this email already exists.';
    }
    return prefix + s.replaceAll('Exception: ', '').replaceAll('AuthRetryableFetchException: ', '');
  }
}

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(ref.watch(authRepositoryProvider));
});