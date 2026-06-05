import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:dawati/core/storage/secure_storage_service.dart';

/// خدمة قاعدة البيانات المحلية المشفرة (SQLCipher)
/// تتولى تخزين قوائم الضيوف وقائمة انتظار المزامنة بأمان تام
class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  /// تهيئة قاعدة البيانات مسبقاً
  Future<void> init() async {
    await database;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    // تغيير اسم الملف لتجنب التعارض مع النسخة القديمة غير المشفرة
    final path = join(dbPath, 'dawati_offline_secure_v1.db');

    // SECURITY: جلب مفتاح التشفير من الـ Secure Storage (Keystore/Keychain)
    final secureStorage = SecureStorageService();
    final encryptionKey = await secureStorage.getOrCreateDbEncryptionKey();

    return await openDatabase(
      path,
      password: encryptionKey, // تشفير كامل للقاعدة
      version: 3, // ترقية الإصدار إلى 3 لدعم النزاهة والعمليات والبوابات
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1- جدول ذاكرة التخزين المؤقت للضيوف
    await db.execute('''
      CREATE TABLE guests_cache (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        allowed_entries INTEGER NOT NULL DEFAULT 1,
        current_entries INTEGER NOT NULL DEFAULT 0,
        qr_token TEXT NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        table_number TEXT,
        seat_number TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        cached_at TEXT NOT NULL
      )
    ''');

    // 2- جدول انتظار المزامنة (الدخولات المسجلة أثناء الانقطاع) مع دعم HMAC و JWT ID (jti) والبوابات
    await db.execute('''
      CREATE TABLE pending_checkins (
        id TEXT PRIMARY KEY,
        guest_id TEXT NOT NULL,
        qr_token TEXT NOT NULL,
        scanned_at TEXT NOT NULL,
        synced INTEGER NOT NULL DEFAULT 0,
        retry_count INTEGER NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'pending', -- pending, success, failed
        conflict_reason TEXT, -- duplicate_scan, expired_qr, revoked_invitation, entries_exceeded
        jti TEXT UNIQUE, -- معرّف الرمز الفريد للـ Replay Cache
        integrity_hash TEXT NOT NULL, -- بصمة HMAC-SHA256 لحماية النزاهة
        gate_name TEXT -- اسم البوابة التي تمت منها العملية
      )
    ''');

    // 3- جدول سجل التدقيق الأمني والتشغيلي (Secure Audit Trail)
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        device_id TEXT NOT NULL,
        staff_id TEXT NOT NULL,
        action TEXT NOT NULL, -- sync_started, sync_completed, sync_failed, integrity_violation, replay_detected
        details TEXT,
        timestamp TEXT NOT NULL,
        network_state TEXT NOT NULL,
        sync_batch_id TEXT
      )
    ''');

    // فهارس لتسريع البحث
    await db.execute('CREATE INDEX idx_guests_event ON guests_cache(event_id)');
    await db.execute('CREATE INDEX idx_guests_qr ON guests_cache(qr_token)');
    await db.execute('CREATE INDEX idx_pending_status ON pending_checkins(sync_status)');
    await db.execute('CREATE UNIQUE INDEX idx_pending_jti ON pending_checkins(jti)');
    await db.execute('CREATE INDEX idx_audit_action ON audit_logs(action)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // تعديل جدول الـ pending_checkins لإضافة أعمدة jti و integrity_hash
      try {
        await db.execute('ALTER TABLE pending_checkins ADD COLUMN jti TEXT');
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE pending_checkins ADD COLUMN integrity_hash TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      
      try {
        await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS idx_pending_jti ON pending_checkins(jti)');
      } catch (_) {}

      // إنشاء جدول سجل التدقيق الأمني (Audit Logs)
      await db.execute('''
        CREATE TABLE IF NOT EXISTS audit_logs (
          id TEXT PRIMARY KEY,
          event_id TEXT NOT NULL,
          device_id TEXT NOT NULL,
          staff_id TEXT NOT NULL,
          action TEXT NOT NULL,
          details TEXT,
          timestamp TEXT NOT NULL,
          network_state TEXT NOT NULL,
          sync_batch_id TEXT
        )
      ''');
      try {
        await db.execute('CREATE INDEX IF NOT EXISTS idx_audit_action ON audit_logs(action)');
      } catch (_) {}
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE pending_checkins ADD COLUMN gate_name TEXT');
      } catch (_) {}
    }
  }

  // ─────────────── Security ───────────────

  /// مسح كافة البيانات المؤقتة (مهم عند تسجيل الخروج أو إيقاف الحساب)
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('guests_cache');
    // لا نحذف pending_checkins هنا إلا إذا كان تم مزامنتها
    // أو إذا كان المستخدم يريد الحذف القسري
  }

  // ─────────────── ضيوف ───────────────

  /// حفظ قائمة الضيوف لمناسبة في قاعدة البيانات المحلية المشفرة
  Future<void> cacheGuests(String eventId, List<Map<String, dynamic>> guests) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().toIso8601String();

    // حذف القديم أولاً لهذه المناسبة
    batch.delete('guests_cache', where: 'event_id = ?', whereArgs: [eventId]);

    for (final guest in guests) {
      batch.insert(
        'guests_cache',
        {
          'id': guest['id'],
          'event_id': guest['event_id'],
          'name': guest['name'],
          'phone': guest['phone'] ?? '',
          'allowed_entries': guest['allowed_entries'] ?? 1,
          'current_entries': guest['current_entries'] ?? 0,
          'qr_token': guest['qr_token'],
          'status': guest['status'] ?? 'pending',
          'table_number': guest['table_number'],
          'seat_number': guest['seat_number'],
          'notes': guest['notes'],
          'created_at': guest['created_at'] ?? now,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// البحث عن ضيف بواسطة رمز QR
  Future<Map<String, dynamic>?> findGuestByQrToken(String qrToken) async {
    final db = await database;
    final results = await db.query(
      'guests_cache',
      where: 'qr_token = ?',
      whereArgs: [qrToken],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  /// جلب قائمة الضيوف من التخزين المحلي
  Future<List<Map<String, dynamic>>> getCachedGuests(String eventId) async {
    final db = await database;
    return db.query(
      'guests_cache',
      where: 'event_id = ?',
      whereArgs: [eventId],
      orderBy: 'name',
    );
  }

  /// تحديث حالة وعدد دخولات ضيف في التخزين المحلي
  Future<void> updateGuestCheckin(String guestId, int newCurrentEntries, String newStatus) async {
    final db = await database;
    await db.update(
      'guests_cache',
      {'current_entries': newCurrentEntries, 'status': newStatus},
      where: 'id = ?',
      whereArgs: [guestId],
    );
  }

  // ─────────────── انتظار المزامنة & Conflict Resolution ───────────────

  /// حساب بصمة HMAC-SHA256 لحماية نزاهة السجلات المحلية من التلاعب
  Future<String> calculateCheckinHmac({
    required String id,
    required String guestId,
    required String qrToken,
    required String scannedAt,
    required String jti,
    String? gateName,
  }) async {
    final secureStorage = SecureStorageService();
    // سر مرتبط بالجهاز ومحمي بـ Keystore/Keychain لقفل البيانات التشويهية
    final hmacKey = await secureStorage.getOrCreateDbEncryptionKey();
    
    final payload = '$id|$guestId|$qrToken|$scannedAt|$jti|${gateName ?? ""}';
    final keyBytes = utf8.encode(hmacKey);
    final dataBytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, keyBytes);
    return hmacSha256.convert(dataBytes).toString();
  }

  /// هل تم مسح هذا الرمز وتأكيده محلياً بانتظار المزامنة؟ (Replay Cache)
  Future<bool> isTokenPendingSync(String jti) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM pending_checkins WHERE jti = ? AND synced = 0',
        [jti],
      ),
    );
    return (count ?? 0) > 0;
  }

  /// إضافة عملية دخول إلى قائمة انتظار المزامنة (Offline Queue) مع دعم HMAC و jti والبوابة
  Future<void> addPendingCheckin({
    required String id,
    required String guestId,
    required String qrToken,
    required DateTime scannedAt,
    required String jti,
    String? gateName,
  }) async {
    final db = await database;
    
    // حساب بصمة النزاهة التشفيرية باستخدام HMAC-SHA256 والسر المرتبط بالجهاز
    final hmacVal = await calculateCheckinHmac(
      id: id,
      guestId: guestId,
      qrToken: qrToken,
      scannedAt: scannedAt.toIso8601String(),
      jti: jti,
      gateName: gateName,
    );

    await db.insert(
      'pending_checkins',
      {
        'id': id,
        'guest_id': guestId,
        'qr_token': qrToken,
        'scanned_at': scannedAt.toIso8601String(),
        'synced': 0,
        'retry_count': 0,
        'sync_status': 'pending',
        'jti': jti,
        'integrity_hash': hmacVal,
        'gate_name': gateName,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// تسجيل أحداث تدقيق أمنية وتشغيلية محلياً (Local Audit Trail)
  Future<void> writeAuditLog({
    required String eventId,
    required String deviceId,
    required String staffId,
    required String action,
    String? details,
    required String networkState,
    String? syncBatchId,
  }) async {
    final db = await database;
    await db.insert(
      'audit_logs',
      {
        'id': const Uuid().v4(),
        'event_id': eventId,
        'device_id': deviceId,
        'staff_id': staffId,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
        'network_state': networkState,
        'sync_batch_id': syncBatchId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// مسح وحذف مشفر كامل لقاعدة البيانات وكافة ملفاتها المرافقة (db-wal, db-shm) وأي مفاتيح
  Future<void> secureWipeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dawati_offline_secure_v1.db');
    
    // الملفات المرافقة لـ SQLite
    final dbFile = File(path);
    final walFile = File('$path-wal');
    final shmFile = File('$path-shm');

    for (final file in [dbFile, walFile, shmFile]) {
      if (await file.exists()) {
        try {
          // مسح آمن بالكتابة الفوقية العشوائية قبل الحذف
          final length = await file.length();
          final random = Random.secure();
          final bytes = List<int>.generate(length, (_) => random.nextInt(256));
          final sink = await file.open(mode: FileMode.write);
          await sink.writeFrom(bytes);
          await sink.close();
          await file.delete();
        } catch (_) {
          // نكتفي بالحذف العادي كإخفاق آمن لضمان سرية البيانات
          try {
            await file.delete();
          } catch (_) {}
        }
      }
    }

    // حذف مفتاح التشفير من Secure Storage أيضاً لضمان قفل الجلسة
    final secureStorage = SecureStorageService();
    await secureStorage.deleteToken('db_encryption_key');
  }

  /// جلب جميع عمليات الدخول غير المتزامنة (Pending Sync)
  Future<List<Map<String, dynamic>>> getPendingCheckins() async {
    final db = await database;
    return db.query(
      'pending_checkins',
      where: 'synced = 0 AND sync_status = ? AND retry_count < 5',
      whereArgs: ['pending'],
      orderBy: 'scanned_at',
    );
  }

  /// تحديث حالة المزامنة للعملية (نجاح أو فشل/تعارض)
  Future<void> updatePendingCheckinStatus(String id, String status, {String? conflictReason}) async {
    final db = await database;
    await db.update(
      'pending_checkins',
      {
        'synced': status == 'success' ? 1 : 0,
        'sync_status': status,
        'conflict_reason': conflictReason,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// زيادة عداد المحاولات الفاشلة لعملية دخول (Exponential Backoff Tracking)
  Future<void> incrementRetryCount(String id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE pending_checkins SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  /// هل يوجد ضيوف مخزنون محلياً لهذه المناسبة؟ (Offline Restrictions)
  Future<bool> hasGuestsCached(String eventId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM guests_cache WHERE event_id = ?',
        [eventId],
      ),
    );
    return (count ?? 0) > 0;
  }

  /// عدد عمليات الانتظار (لعرضها للمستخدم في الـ Badge)
  Future<int> getPendingCheckinsCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pending_checkins WHERE synced = 0'),
    );
    return count ?? 0;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

final localDatabaseService = LocalDatabaseService();

