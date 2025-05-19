import 'package:flutter/foundation.dart';
import '../models/rental.dart';
import '../database/database_helper.dart';

class RentalProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Rental> _activeRentals = [];
  List<Rental> _inactiveRentals = [];
  double _totalEarnings = 0;
  double _expectedIncome = 0;
  double _overduePayments = 0;

  List<Rental> get activeRentals => _activeRentals;
  List<Rental> get inactiveRentals => _inactiveRentals;
  double get totalEarnings => _totalEarnings;
  double get expectedIncome => _expectedIncome;
  double get overduePayments => _overduePayments;

  Future<void> loadData() async {
    try {
      await Future.wait([
        _loadActiveRentals(),
        _loadInactiveRentals(),
        _loadFinancialData(),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  Future<void> _loadActiveRentals() async {
    try {
      _activeRentals = await _dbHelper.getActiveRentals();
    } catch (e) {
      debugPrint('Error loading active rentals: $e');
      _activeRentals = [];
    }
  }

  Future<void> _loadInactiveRentals() async {
    try {
      _inactiveRentals = await _dbHelper.getInactiveRentals();
    } catch (e) {
      debugPrint('Error loading inactive rentals: $e');
      _inactiveRentals = [];
    }
  }

  Future<void> _loadFinancialData() async {
    try {
      _totalEarnings = await _dbHelper.getTotalEarnings();
      _expectedIncome = await _dbHelper.getExpectedIncome();
      _overduePayments = await _dbHelper.getOverduePayments();
    } catch (e) {
      debugPrint('Error loading financial data: $e');
      _totalEarnings = 0;
      _expectedIncome = 0;
      _overduePayments = 0;
    }
  }

  Future<void> addRental(Rental rental) async {
    try {
      await _dbHelper.insertRental(rental);
      await loadData();
    } catch (e) {
      debugPrint('Error adding rental: $e');
    }
  }

  Future<void> updateRental(Rental rental) async {
    try {
      await _dbHelper.updateRental(rental);
      await loadData();
    } catch (e) {
      debugPrint('Error updating rental: $e');
    }
  }

  Future<void> deleteRental(int id) async {
    try {
      await _dbHelper.deleteRental(id);
      await loadData();
    } catch (e) {
      debugPrint('Error deleting rental: $e');
    }
  }

  Future<void> toggleRentalStatus(Rental rental) async {
    try {
      final updatedRental = Rental(
        id: rental.id,
        tenantName: rental.tenantName,
        dailyRate: rental.dailyRate,
        startDate: rental.startDate,
        endDate: rental.endDate,
        isActive: !rental.isActive,
        notes: rental.notes,
        createdAt: rental.createdAt,
      );
      await updateRental(updatedRental);
    } catch (e) {
      debugPrint('Error toggling rental status: $e');
    }
  }
} 