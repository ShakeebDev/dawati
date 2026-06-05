
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:dawati/core/services/background_sync_service.dart';
import 'package:dawati/core/services/local_database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة اللغة العربية للتواريخ
  await initializeDateFormatting('ar', null);

  // تهيئة Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // تهيئة قاعدة البيانات المحلية
  await localDatabaseService.init();

  // تهيئة وجدولة المزامنة الخلفية
  await BackgroundSyncService.initialize();
  BackgroundSyncService.registerPeriodicSync();

  runApp(
    const ProviderScope(
      child: DawatiApp(),
    ),
  );
}

class DawatiApp extends ConsumerWidget {
  const DawatiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // دعم اللغة العربية (RTL)
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],

      // ثيم التطبيق
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // نظام التنقل
      routerConfig: router,
    );
  }
}
