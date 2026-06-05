import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// مزود Supabase العام
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// خدمة Supabase الأساسية
class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  SupabaseClient get client => _client;

  /// المستخدم الحالي
  User? get currentUser => _client.auth.currentUser;

  /// جلسة المصادقة الحالية
  Session? get currentSession => _client.auth.currentSession;

  /// الاستماع لتغييرات المصادقة
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// تسجيل حساب جديد
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  /// تسجيل الدخول
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(ref.read(supabaseProvider));
});
