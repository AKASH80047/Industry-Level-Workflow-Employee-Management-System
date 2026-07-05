class AppConstants {
  static const String appName = 'Workforce Attendance';
  static const String appVersion = '1.0.0';

  // Geofencing Defaults
  static const double defaultGeofenceRadiusMeters = 100.0;
  static const double minLocationAccuracyMeters = 30.0;

  // Mock Location Limits
  static const double maxImpossibleSpeedKmh = 120.0; // Speed threshold to check impossible travel
  static const int minMockDetectionAccuracy = 15; // Strictness threshold

  // Attendance Settings
  static const int gracePeriodMinutes = 15;
  static const int halfDayMinutesThreshold = 240; // 4 hours
  static const int fullDayMinutesThreshold = 480; // 8 hours

  // Storage Limits
  static const int maxSelfieSizeBytes = 2 * 1024 * 1024; // 2MB
  static const int maxAttachmentSizeBytes = 5 * 1024 * 1024; // 5MB

  // Session Settings
  static const Duration sessionTimeoutDuration = Duration(hours: 12);
}

class UserRoles {
  static const String admin = 'admin';
  static const String manager = 'manager';
  static const String employee = 'employee';

  static const List<String> all = [admin, manager, employee];
}

class LeaveTypes {
  static const String casual = 'casual';
  static const String sick = 'sick';
  static const String paid = 'paid';
  static const String unpaid = 'unpaid';
  static const String halfDay = 'half_day';

  static const List<String> all = [casual, sick, paid, unpaid, halfDay];
}

class AttendanceStatuses {
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
  static const String halfDay = 'half_day';
  static const String onLeave = 'on_leave';
  static const String holiday = 'holiday';
  static const String weekOff = 'week_off';
  static const String pendingRegularization = 'pending_regularization';

  static const List<String> all = [
    present,
    absent,
    late,
    halfDay,
    onLeave,
    holiday,
    weekOff,
    pendingRegularization,
  ];
}

class BreakTypes {
  static const String lunch = 'lunch';
  static const String tea = 'tea';
  static const String custom = 'custom';

  static const List<String> all = [lunch, tea, custom];
}

class IssueTypes {
  static const String forgotCheckIn = 'forgot_check_in';
  static const String forgotCheckOut = 'forgot_check_out';
  static const String wrongTime = 'wrong_time';
  static const String gpsFailure = 'gps_failure';
  static const String officialWork = 'official_work';
  static const String other = 'other';

  static const List<String> all = [
    forgotCheckIn,
    forgotCheckOut,
    wrongTime,
    gpsFailure,
    officialWork,
    other,
  ];
}

class EmploymentTypes {
  static const String fullTime = 'full_time';
  static const String partTime = 'part_time';
  static const String intern = 'intern';
  static const String contract = 'contract';

  static const List<String> all = [fullTime, partTime, intern, contract];
}
