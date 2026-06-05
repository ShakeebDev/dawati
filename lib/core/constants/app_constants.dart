/// ثوابت التطبيق العامة
class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl = 'https://eplyxirloqkixdnrtwgx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVwbHl4aXJsb3FraXhkbnJ0d2d4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4ODI0MTMsImV4cCI6MjA4NzQ1ODQxM30.N3VPj_FcDajlKr8DwV_6GA46k-SFukxm7G8OK5cbCns';

  // App Info
  static const String appName = 'دعوتي';
  static const String appTagline = 'دعوتك بأناقة… دخول ذكي وآمن';
  static const String appVersion = '1.0.0';

  // Tables
  static const String eventsTable = 'events';
  static const String guestsTable = 'guests';
  static const String checkinsTable = 'checkins';
  static const String profilesTable = 'profiles';

  // Storage Buckets
  static const String invitationsBucket = 'invitations';
  static const String backgroundsBucket = 'backgrounds';

  // RPC Functions
  static const String processCheckinRpc = 'process_checkin';
  static const String getEventStatsRpc = 'get_event_stats';
  static const String createEventRpc = 'create_event_secure';
  static const String createGuestRpc = 'create_guest_secure';
  static const String assignStaffRpc = 'assign_staff_to_event';
  static const String removeStaffRpc = 'remove_staff_from_event';

  // Pagination
  static const int pageSize = 20;
  static const int maxGuestsPerPage = 50;

  // QR Token
  static const int tokenLength = 32;

  // Entry Types
  static const String entrySingle = 'single';
  static const String entryMulti = 'multi';

  // Guest Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCheckedIn = 'checked_in';

  // Roles
  static const String roleOrganizer = 'organizer';
  static const String roleStaff = 'staff';

  // Local Storage Keys
  static const String userRoleKey = 'user_role';
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_done';
}
