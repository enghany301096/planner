import 'dart:developer';

import 'package:masrofy/models/expense.dart';
import 'package:masrofy/models/expense_category.dart';
import 'package:masrofy/models/payment_method.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/project.dart';
import '../../models/project_task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('masrofy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,

      version: 18,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textNullable = 'TEXT';

    await db.execute('''
CREATE TABLE payment_methods (
  id $idType,
  name $textType,
  color $integerType,
  icon $integerType,
  type $textNullable,
  cardNumber $textNullable
)
''');

    await db.execute('''
CREATE TABLE projects (
  id $idType,
  name $textType,
  description $textNullable,
  endDate $textNullable,
  status $textType,
  imagePath $textNullable
)
''');

    await db.execute('''
CREATE TABLE tasks (
  id $idType,
  projectId $textType,
  name $textType,
  details $textNullable,
  attachments $textNullable,
  startDate $textType,
  endDate $textNullable,
  cost $realType,
  currency $textType,
  isCompleted $integerType,
  status $textType,
  type $textType,
  subTasks $textNullable,
  isPaid INTEGER DEFAULT 0,
  paymentMethodId TEXT,
  timeSpentInSeconds INTEGER DEFAULT 0,
  isTimerRunning INTEGER DEFAULT 0,
  lastStartTime TEXT,
  timerStartAt TEXT,
  timerEndAt TEXT,
  estimatedTime REAL DEFAULT 0,
  hourlyRate REAL DEFAULT 0,
  isArchived INTEGER DEFAULT 0,
  FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE,
  FOREIGN KEY (paymentMethodId) REFERENCES payment_methods (id)
)
''');

    await db.execute('''
CREATE TABLE expense_categories (
  id $idType,
  name $textType,
  color $integerType,
  icon $integerType,
  isDefault INTEGER DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE expenses (
  id $idType,
  title $textType,
  amount $realType,
  date $textType,
  categoryId $textType,
  paymentMethodId $textNullable,
  note $textNullable,
  taskId $textNullable,
  currency $textType,
  FOREIGN KEY (categoryId) REFERENCES expense_categories (id),
  FOREIGN KEY (paymentMethodId) REFERENCES payment_methods (id),
  FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE SET NULL
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const textNullable = 'TEXT';

    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE expenses ADD COLUMN paymentMethodId TEXT',
        );
        await db.execute('''
CREATE TABLE payment_methods (
  id $idType,
  name $textType,
  color $integerType,
  icon $integerType
)
''');
      } catch (e) {
        log('Migration Error v2: $e');
      }
    }

    if (oldVersion < 3) {
      try {
        await db.execute('''
CREATE TABLE income_categories (
  id $idType,
  name $textType,
  color $integerType,
  icon $integerType
)
''');

        await db.execute('''
CREATE TABLE incomes (
  id $idType,
  amount $realType,
  date $textType,
  categoryId $textType,
  note $textNullable,
  FOREIGN KEY (categoryId) REFERENCES income_categories (id)
)
''');
      } catch (e) {
        log('Migration Error v3: $e');
      }
    }

    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE payment_methods ADD COLUMN type TEXT');
        await db.execute(
          'ALTER TABLE payment_methods ADD COLUMN cardNumber TEXT',
        );
      } catch (e) {
        log('Migration Error v4: $e');
      }
    }

    if (oldVersion < 5) {
      try {
        await db.execute('''
CREATE TABLE projects (
  id $idType,
  name $textType,
  description $textNullable,
  endDate $textNullable,
  status $textType
)
''');

        await db.execute('''
CREATE TABLE tasks (
  id $idType,
  projectId $textType,
  name $textType,
  details $textNullable,
  attachments $textNullable,
  startDate $textType,
  endDate $textNullable,
  cost $realType,
  currency $textType,
  isCompleted $integerType,
  status $textType,
  FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
)
''');
      } catch (e) {
        log('Migration Error v5: $e');
      }
    }

    if (oldVersion < 12) {
      try {
        // Ensure projects and tasks table exist even if v5 migration was skipped or failed partially
        await db.execute('''
          CREATE TABLE IF NOT EXISTS projects (
            id $idType,
            name $textType,
            description $textNullable,
            endDate $textNullable,
            status $textType
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS tasks (
            id $idType,
            projectId $textType,
            name $textType,
            details $textNullable,
            attachments $textNullable,
            startDate $textType,
            endDate $textNullable,
            cost $realType,
            currency $textType,
            isCompleted $integerType,
            status $textType,
            FOREIGN KEY (projectId) REFERENCES projects (id) ON DELETE CASCADE
          )
        ''');

        // Now add the new columns for v12
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN isPaid INTEGER DEFAULT 0",
        );
        await db.execute("ALTER TABLE tasks ADD COLUMN paymentMethodId TEXT");
      } catch (e) {
        log('Migration Error v12: $e');
      }
    }

    if (oldVersion < 13) {
      try {
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN timeSpentInSeconds INTEGER DEFAULT 0",
        );
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN isTimerRunning INTEGER DEFAULT 0",
        );
        await db.execute("ALTER TABLE tasks ADD COLUMN lastStartTime TEXT");
      } catch (e) {
        log('Migration Error v13: $e');
      }
    }

    if (oldVersion < 14) {
      try {
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN estimatedTime REAL DEFAULT 0",
        );
      } catch (e) {
        log('Migration Error v14: $e');
      }
    }

    if (oldVersion < 15) {
      try {
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN hourlyRate REAL DEFAULT 0",
        );
      } catch (e) {
        log('Migration Error v15: $e');
      }
    }

    if (oldVersion < 16) {
      try {
        await db.execute(
          "ALTER TABLE tasks ADD COLUMN isArchived INTEGER DEFAULT 0",
        );
      } catch (e) {
        log('Migration Error v16: $e');
      }
    }

    if (oldVersion < 17) {
      try {
        await db.execute("ALTER TABLE tasks ADD COLUMN timerStartAt TEXT");
        await db.execute("ALTER TABLE tasks ADD COLUMN timerEndAt TEXT");
      } catch (e) {
        log('Migration Error v17: $e');
      }
    }

    if (oldVersion < 18) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expense_categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            color INTEGER NOT NULL,
            icon INTEGER NOT NULL,
            isDefault INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS expenses (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            categoryId TEXT NOT NULL,
            paymentMethodId TEXT,
            note TEXT,
            taskId TEXT,
            currency TEXT NOT NULL
          )
        ''');
      } catch (e) {
        log('Migration Error v18: $e');
      }
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'masrofy.db');
    await close();
    await deleteDatabase(path);
  }

  // Payment Method CRUD
  Future<int> insertPaymentMethod(PaymentMethod paymentMethod) async {
    final db = await instance.database;
    return await db.insert('payment_methods', paymentMethod.toMap());
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await instance.database;
    final result = await db.query('payment_methods');
    return result.map((json) => PaymentMethod.fromMap(json)).toList();
  }

  Future<int> deletePaymentMethod(String id) async {
    final db = await instance.database;
    return await db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updatePaymentMethod(PaymentMethod paymentMethod) async {
    final db = await instance.database;
    return await db.update(
      'payment_methods',
      paymentMethod.toMap(),
      where: 'id = ?',
      whereArgs: [paymentMethod.id],
    );
  }

  // Projects CRUD
  Future<int> insertProject(Project project) async {
    final db = await instance.database;
    return await db.insert('projects', project.toMap());
  }

  Future<List<Project>> getProjects() async {
    final db = await instance.database;
    final result = await db.query('projects');
    return result.map((json) => Project.fromMap(json)).toList();
  }

  Future<int> deleteProject(String id) async {
    final db = await instance.database;
    // Also delete associated tasks
    await db.delete('tasks', where: 'projectId = ?', whereArgs: [id]);
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateProject(Project project) async {
    final db = await instance.database;
    return await db.update(
      'projects',
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  // Tasks CRUD
  Future<int> insertTask(ProjectTask task) async {
    final db = await instance.database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<ProjectTask>> getTasks(String projectId) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'projectId = ?',
      whereArgs: [projectId],
    );
    return result.map((json) => ProjectTask.fromMap(json)).toList();
  }

  Future<int> deleteTask(String id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateTask(ProjectTask task) async {
    final db = await instance.database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<List<ProjectTask>> getAllTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks');
    return result.map((json) => ProjectTask.fromMap(json)).toList();
  }

  // Expense Categories CRUD
  Future<int> insertExpenseCategory(ExpenseCategory category) async {
    final db = await instance.database;
    return await db.insert('expense_categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<ExpenseCategory>> getExpenseCategories() async {
    final db = await instance.database;
    final result = await db.query('expense_categories', orderBy: 'isDefault DESC, name ASC');
    return result.map((json) => ExpenseCategory.fromMap(json)).toList();
  }

  Future<int> updateExpenseCategory(ExpenseCategory category) async {
    final db = await instance.database;
    return await db.update(
      'expense_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteExpenseCategory(String id) async {
    final db = await instance.database;
    return await db.delete('expense_categories', where: 'id = ?', whereArgs: [id]);
  }

  // Expenses CRUD
  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<Expense>> getExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<Expense?> getExpenseByTaskId(String taskId) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'taskId = ?',
      whereArgs: [taskId],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Expense.fromMap(result.first);
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteExpenseByTaskId(String taskId) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'taskId = ?', whereArgs: [taskId]);
  }
}
