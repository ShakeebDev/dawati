import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dawati/core/services/local_database_service.dart';
import 'package:dawati/core/services/offline_sync_service.dart';

/// معرف المهمة الخلفية
const String syncTaskName = "com.dawati.app.syncPendingCheckins";

/// دالة نقطة الإدخال للمهام الخلفية (يجب أن تكون Top-level)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == syncTaskName) {
        // تهيئة المكونات اللازمة لأنها بيئة معزولة
        // ملاحظة: يجب التأكد من تهيئة Supabase بنفس الإعدادات الأساسية
        // TODO: Ensure Supabase.initialize is called with correct URL & Anon Key 
        // if it's not already initialized by the OS in this isolate.
        
        final localDb = LocalDatabaseService();
        await localDb.init(); // التأكد من جاهزية قاعدة البيانات

        final syncService = OfflineSyncService(
          localDb: localDb,
          supabase: Supabase.instance.client,
        );

        final result = await syncService.syncPendingCheckins();
        
        debugPrint('Background Sync Result: ${result.message}');
        return Future.value(true);
      }
    } catch (e) {
      debugPrint('Background Sync Error: $e');
      return Future.value(false); // سيقوم النظام بإعادة المحاولة بناءً على Backoff Policy
    }
    return Future.value(true);
  });
}

/// خدمة لإدارة جدولة المهام الخلفية
class BackgroundSyncService {
  /// تهيئة Workmanager
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  /// تسجيل مهمة المزامنة الدورية (كل 15 دقيقة كحد أدنى على Android)
  static void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      "1", // Unique Name
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected, // يتطلب اتصال بالإنترنت
        requiresBatteryNotLow: true, // الحفاظ على البطارية (Thermal/Battery Protection)
      ),
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  /// إيقاف المزامنة
  static void cancelAllTasks() {
    Workmanager().cancelAll();
  }
}
