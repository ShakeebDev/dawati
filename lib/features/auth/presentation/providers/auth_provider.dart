import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/features/auth/data/models/user_model.dart';
import 'package:dawati/features/auth/data/repositories/auth_repository.dart';
import 'dart:async';

/// حالة المصادقة
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final AppFailure? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    AppFailure? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// مزود حالة المصادقة (Notifier)
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  // SECURITY: Stream للإخطار بتغييرات الـ Auth State (يستخدمه GoRouter)
  final _authStreamController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStream => _authStreamController.stream;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _restoreSession();
  }

  /// استعادة الجلسة عند فتح التطبيق (Session Restore)
  Future<void> _restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getCurrentUser();
    if (result is Success<UserModel?>) {
      final user = result.data;
      // SECURITY: التحقق من حالة الحساب فوراً عند الاستعادة
      if (user != null && !user.isActive) {
        await _repository.logout();
        state = state.copyWith(isLoading: false, clearUser: true);
        _authStreamController.add(null);
        return;
      }
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      _authStreamController.add(user);
    } else {
      state = state.copyWith(isLoading: false, clearUser: true);
      _authStreamController.add(null);
    }
  }

  /// تسجيل الدخول
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.login(email: email, password: password);

    if (result is Success<UserModel>) {
      final user = result.data;
      // SECURITY: التحقق من حالة الحساب مباشرةً بعد تسجيل الدخول
      if (!user.isActive) {
        await _repository.logout();
        state = state.copyWith(
          isLoading: false,
          clearUser: true,
          error: const AuthFailure(message: 'تم إيقاف حسابك. يرجى التواصل مع الدعم.'),
        );
        return false;
      }
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      _authStreamController.add(user);
      return true;
    } else {
      final failure = (result as Failure).failure;
      state = state.copyWith(isLoading: false, error: failure, clearUser: true);
      return false;
    }
  }

  /// تسجيل مستخدم جديد
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );

    if (result is Success<UserModel>) {
      final user = result.data;
      state = state.copyWith(isLoading: false, user: user, clearError: true);
      _authStreamController.add(user);
      return true;
    } else {
      final failure = (result as Failure).failure;
      state = state.copyWith(isLoading: false, error: failure, clearUser: true);
      return false;
    }
  }

  /// تحديث الدور
  Future<bool> updateRole(String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.updateRole(role);

    if (result is Success) {
      await refreshUser();
      return true;
    } else {
      final failure = (result as Failure).failure;
      state = state.copyWith(isLoading: false, error: failure);
      return false;
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _repository.logout();
    state = const AuthState();
    _authStreamController.add(null);
  }

  /// تحديث بيانات المستخدم من السيرفر
  Future<void> refreshUser() async {
    final result = await _repository.getCurrentUser();
    if (result is Success<UserModel?>) {
      final user = result.data;
      if (user != null && !user.isActive) {
        await logout();
        return;
      }
      state = state.copyWith(user: user);
      _authStreamController.add(user);
    }
  }

  @override
  void dispose() {
    _authStreamController.close();
    super.dispose();
  }
}

/// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

/// Stream Provider للـ GoRouter (يستمع لتغييرات Auth)
final authStateStreamProvider = StreamProvider<UserModel?>((ref) {
  return ref.watch(authProvider.notifier).authStream;
});
