// import 'package:flutter/material.dart';

/// Mock data for attendance records and daily reports
class AttendanceData {
  /// Attendance record: Date -> Attended (true/false)
  static final Map<DateTime, bool> attendanceRecord = {
    for (int i = 0; i < 365; i++)
      DateTime(2023).add(Duration(days: i)): i % 2 == 0, // Alternating attendance
  };

  /// Daily reports: Date -> Report String
  static final Map<DateTime, String> dailyReports = {
    for (int i = 0; i < 365; i++)
      DateTime(2023).add(Duration(days: i)): "Report for ${DateTime(2023).add(Duration(days: i)).toLocal()}:\n"
          "${i % 2 == 0 ? 'Excellent performance!' : 'Absent for the day.'}",
  };
}
