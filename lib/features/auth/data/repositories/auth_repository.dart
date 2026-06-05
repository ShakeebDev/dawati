import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/core/constants/app_constants.dart';
import 'package:dawati/core/errors/failures.dart';
import 'package:dawati/features/auth/data/models/user_model.dart';
import 'package:dawati/shared/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مستودع المصادقة وإدارة المستخدمين
class AuthRepository {
  final SupabaseService _supabaseService;

  AuthRepository(this._supabaseService);

  /// تسجيل مستخدم جديد
  Future<Result<UserModel>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone, 'role': role},
      );

      if (response.user == null) {
        return Failure(AuthFailure.unknown());
      }

      // إنشاء سجل المستخدم في قاعدة البيانات
      await _supabaseService.client.from(AppConstants.profilesTable).upsert({
        'id': response.user!.id,
        'email': email,
        'name': name,
        'phone': phone,
        'role': role,
      });

      // جلب البيانات المحدثة من السيرفر للتأكد
      final userProfile = await _supabaseService.client
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', response.user!.id)
          .single();

      final user = UserModel.fromJson(userProfile);

      // SECURITY: حفظ الـ Role محلياً للـ UI فقط (وليس للتحقق الأمني)
      // الـ Router يعتمد على السيرفر دائماً
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userRoleKey, user.role);

      return Success(user);
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return Failure(AuthFailure.emailAlreadyInUse());
      }
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(AuthFailure.fromException(e));
    }
  }

  /// تسجيل الدخول مع التحقق الفوري من حالة الحساب
  Future<Result<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return Failure(AuthFailure.invalidCredentials());
      }

      // جلب بيانات المستخدم من السيرفر (يشمل status و role)
      final userProfile = await _supabaseService.client
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      UserModel user;
      if (userProfile == null) {
        // RLS أو خطأ في إنشاء البروفايل، نعتمد على الميتا داتا
        final meta = response.user!.userMetadata ?? {};
        user = UserModel(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: meta['name'] ?? 'مستخدم',
          phone: meta['phone'] ?? '',
          role: meta['role'] ?? 'staff',
          status: 'active',
          createdAt: DateTime.now(),
        );
      } else {
        user = UserModel.fromJson(userProfile);
      }

      // SECURITY: التحقق من حالة الحساب مباشرةً من السيرفر
      if (!user.isActive) {
        // تسجيل الخروج فوراً إذا كان الحساب موقوفاً
        await _supabaseService.signOut();
        return Failure(const AuthFailure(
          message: 'تم إيقاف حسابك. يرجى التواصل مع الدعم الفني.',
          code: 'account_suspended',
        ));
      }

      // SECURITY: حفظ الـ Role للـ UI فقط — الـ Guards تعتمد على السيرفر
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userRoleKey, user.role);

      return Success(user);
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        return Failure(AuthFailure.invalidCredentials());
      }
      return Failure(AuthFailure(message: e.message));
    } catch (e) {
      return Failure(AuthFailure.fromException(e));
    }
  }

  /// تسجيل الخروج وحذف البيانات المحلية
  Future<Result<void>> logout() async {
    try {
      await _supabaseService.signOut();
      // SECURITY: حذف بيانات الـ Role المحلية عند الخروج
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userRoleKey);
      return const Success(null);
    } catch (e) {
      return Failure(AuthFailure.fromException(e));
    }
  }

  /// الحصول على المستخدم الحالي من السيرفر (Session Restore)
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return const Success(null);

      // SECURITY: دائماً نجلب البيانات من السيرفر عند استعادة الجلسة
      // لأن الـ role أو الـ status قد تكون قد تغيرت منذ آخر تسجيل دخول
      final userProfile = await _supabaseService.client
          .from(AppConstants.profilesTable)
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (userProfile == null) {
        final meta = user.userMetadata ?? {};
        return Success(UserModel(
          id: user.id,
          email: user.email ?? '',
          name: meta['name'] ?? 'مستخدم',
          phone: meta['phone'] ?? '',
          role: meta['role'] ?? 'staff',
          status: 'active',
          createdAt: DateTime.now(),
        ));
      }

      return Success(UserModel.fromJson(userProfile));
    } on PostgrestException {
      // الجلسة موجودة لكن بيانات المستخدم غير متاحة (حُذف الحساب مثلاً)
      await _supabaseService.signOut();
      return const Success(null);
    } catch (e) {
      return Failure(AuthFailure.fromException(e));
    }
  }

  /// تحديث الدور — محمي: لا يمكن ترقية الـ Role ذاتياً
  /// هذا للاستخدام في مرحلة الـ Onboarding (role-selection) فقط للـ staff/organizer
  Future<Result<void>> updateRole(String role) async {
    try {
      // SECURITY: التحقق من أن الـ role المطلوب ليس admin
      if (role == 'admin') {
        return Failure(const AuthFailure(
          message: 'غير مسموح بتعيين هذا الدور.',
          code: 'forbidden_role',
        ));
      }

      final userId = _supabaseService.currentUser?.id;
      if (userId == null) return Failure(AuthFailure.unknown());

      await _supabaseService.client
          .from(AppConstants.profilesTable)
          .update({'role': role}).eq('id', userId);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userRoleKey, role);

      return const Success(null);
    } catch (e) {
      return Failure(AuthFailure(message: e.toString()));
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(supabaseServiceProvider));
});
