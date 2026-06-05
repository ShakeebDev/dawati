import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// موفر قائمة المنظمين مع اشتراكاتهم وخططهم
final adminOrganizersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  // جلب كافة الحسابات مع الاشتراكات والخطط
  final response = await supabase
      .from('profiles')
      .select('*, subscriptions(*, plans(*))')
      .order('name');
      
  return List<Map<String, dynamic>>.from(response as List);
});

/// موفر سجلات الرقابة والنظام
final adminAuditLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabase = Supabase.instance.client;
  
  final response = await supabase
      .from('audit_logs')
      .select('*, profiles(name)')
      .order('created_at', ascending: false)
      .limit(50);
      
  return List<Map<String, dynamic>>.from(response as List);
});
