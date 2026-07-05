class PayrollCalculationResult {
  final double basicSalary;
  final double overtimePay;
  final double bonus;
  final double lateDeduction;
  final double unpaidLeaveDeduction;
  final double grossSalary;
  final double netSalary;

  PayrollCalculationResult({
    required this.basicSalary,
    required this.overtimePay,
    required this.bonus,
    required this.lateDeduction,
    required this.unpaidLeaveDeduction,
    required this.grossSalary,
    required this.netSalary,
  });
}

class PayrollCalculator {
  /// Processes salary payouts based on attendance metrics
  static PayrollCalculationResult calculate({
    required double basicSalary,
    required double allowance,
    required int workingDaysInMonth,
    required int presentDays,
    required double paidLeavesUsed,
    required double unpaidLeavesUsed,
    required int overtimeMinutes,
    required int totalLateArrivals,
    double overtimeHourlyRate = 150.0,
    double lateArrivalDeductionAmount = 100.0, // Fixed cost per late arrival
  }) {
    // 1. Calculate Overtime pay
    final double overtimeHours = overtimeMinutes / 60.0;
    final double overtimePay = double.parse((overtimeHours * overtimeHourlyRate).toStringAsFixed(2));

    // 2. Calculate Leave Deductions
    final double dailyRate = basicSalary / workingDaysInMonth;
    final double unpaidLeaveDeduction = double.parse((unpaidLeavesUsed * dailyRate).toStringAsFixed(2));

    // 3. Late Arrival Deductions
    final double lateDeduction = totalLateArrivals * lateArrivalDeductionAmount;

    // 4. Gross salary
    final double grossSalary = double.parse(
      (basicSalary + allowance + overtimePay).toStringAsFixed(2),
    );

    // 5. Net salary
    final double netSalary = double.parse(
      (grossSalary - unpaidLeaveDeduction - lateDeduction).toStringAsFixed(2),
    );

    return PayrollCalculationResult(
      basicSalary: basicSalary,
      overtimePay: overtimePay,
      bonus: allowance,
      lateDeduction: lateDeduction,
      unpaidLeaveDeduction: unpaidLeaveDeduction,
      grossSalary: grossSalary,
      netSalary: netSalary < 0 ? 0.0 : netSalary,
    );
  }
}
