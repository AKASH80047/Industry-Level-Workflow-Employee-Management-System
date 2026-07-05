import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/employee_entity.dart';

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.uid,
    required super.employeeId,
    required super.fullName,
    required super.email,
    required super.phone,
    super.profilePhotoUrl,
    required super.joiningDate,
    required super.departmentId,
    required super.designationId,
    super.managerId,
    required super.shiftId,
    required super.officeId,
    required super.employmentType,
    super.deviceId,
    super.deviceModel,
    super.deviceOS,
    super.deviceBoundAt,
    super.fcmToken,
    required super.basicSalary,
    super.allowance,
    required super.createdAt,
    required super.updatedAt,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map, String uid) {
    return EmployeeModel(
      uid: uid,
      employeeId: map['employeeId'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      joiningDate: (map['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      departmentId: map['departmentId'] as String? ?? '',
      designationId: map['designationId'] as String? ?? '',
      managerId: map['managerId'] as String?,
      shiftId: map['shiftId'] as String? ?? '',
      officeId: map['officeId'] as String? ?? '',
      employmentType: map['employmentType'] as String? ?? 'full_time',
      deviceId: map['deviceId'] as String?,
      deviceModel: map['deviceModel'] as String?,
      deviceOS: map['deviceOS'] as String?,
      deviceBoundAt: (map['deviceBoundAt'] as Timestamp?)?.toDate(),
      fcmToken: map['fcmToken'] as String?,
      basicSalary: (map['basicSalary'] as num?)?.toDouble() ?? 0.0,
      allowance: (map['allowance'] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return EmployeeModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profilePhotoUrl': profilePhotoUrl,
      'joiningDate': Timestamp.fromDate(joiningDate),
      'departmentId': departmentId,
      'designationId': designationId,
      'managerId': managerId,
      'shiftId': shiftId,
      'officeId': officeId,
      'employmentType': employmentType,
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'deviceOS': deviceOS,
      'deviceBoundAt': deviceBoundAt != null ? Timestamp.fromDate(deviceBoundAt!) : null,
      'fcmToken': fcmToken,
      'basicSalary': basicSalary,
      'allowance': allowance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
