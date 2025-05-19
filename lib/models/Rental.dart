import 'package:intl/intl.dart';

class Rental {
  final int? id;
  final String tenantName;
  final double dailyRate;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  Rental({
    this.id,
    required this.tenantName,
    required this.dailyRate,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantName': tenantName,
      'dailyRate': dailyRate,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromMap(Map<String, dynamic> map) {
    return Rental(
      id: map['id'],
      tenantName: map['tenantName'],
      dailyRate: map['dailyRate'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] == 1,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String get formattedStartDate => DateFormat('dd/MM/yyyy').format(startDate);
  String get formattedEndDate => DateFormat('dd/MM/yyyy').format(endDate);
  String get formattedDailyRate => '₺${dailyRate.toStringAsFixed(2)}';
  
  double get totalAmount {
    final days = endDate.difference(startDate).inDays + 1;
    return dailyRate * days;
  }
  
  String get formattedTotalAmount => '₺${totalAmount.toStringAsFixed(2)}';
}