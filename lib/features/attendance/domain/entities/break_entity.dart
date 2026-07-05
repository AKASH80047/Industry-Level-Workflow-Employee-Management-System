import 'package:flutter/foundation.dart';

@immutable
class BreakEntity {
  final String breakType; // 'lunch' | 'tea' | 'custom'
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;

  const BreakEntity({
    required this.breakType,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
  });

  BreakEntity copyWith({
    String? breakType,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
  }) {
    return BreakEntity(
      breakType: breakType ?? this.breakType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
