import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/rental.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rentals.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rentals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenantName TEXT NOT NULL,
        dailyRate REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER NOT NULL,
        notes TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRental(Rental rental) async {
    final db = await database;
    return await db.insert('rentals', rental.toMap());
  }

  Future<List<Rental>> getAllRentals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rentals');
    return List.generate(maps.length, (i) => Rental.fromMap(maps[i]));
  }

  Future<List<Rental>> getActiveRentals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rentals',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'startDate DESC',
    );
    return List.generate(maps.length, (i) => Rental.fromMap(maps[i]));
  }

  Future<List<Rental>> getInactiveRentals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rentals',
      where: 'isActive = ?',
      whereArgs: [0],
      orderBy: 'endDate DESC',
    );
    return List.generate(maps.length, (i) => Rental.fromMap(maps[i]));
  }

  Future<int> updateRental(Rental rental) async {
    final db = await database;
    return await db.update(
      'rentals',
      rental.toMap(),
      where: 'id = ?',
      whereArgs: [rental.id],
    );
  }

  Future<int> deleteRental(int id) async {
    final db = await database;
    return await db.delete(
      'rentals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalEarnings() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(dailyRate * (julianday(endDate) - julianday(startDate) + 1)) as total
      FROM rentals
      WHERE isActive = 0
    ''');
    return result.first['total'] ?? 0.0;
  }

  Future<double> getExpectedIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(dailyRate * (julianday(endDate) - julianday(startDate) + 1)) as total
      FROM rentals
      WHERE isActive = 1
    ''');
    return result.first['total'] ?? 0.0;
  }

  Future<double> getOverduePayments() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(dailyRate * (julianday(endDate) - julianday(startDate) + 1)) as total
      FROM rentals
      WHERE isActive = 1 AND endDate < ?
    ''', [now]);
    return result.first['total'] ?? 0.0;
  }
} 