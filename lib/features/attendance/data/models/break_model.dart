import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/break_entity.dart';

class BreakModel extends BreakEntity {
  const BreakModel({
    required super.breakType,
    required super.startTime,
    super.endTime,
    super.durationMinutes,
  });

  factory BreakModel.fromMap(Map<String, dynamic> map) {
    return BreakModel(
      breakType: map['breakType'] as String? ?? 'lunch',
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp?)?.toDate(),
      durationMinutes: map['durationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'breakType': breakType,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationMinutes': durationMinutes,
    };
  }
}
