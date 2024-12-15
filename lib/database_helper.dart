import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('companies.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        website TEXT,
        address TEXT,
        email TEXT,
        linkedIn TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vacancies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        companyId INTEGER NOT NULL,
        position TEXT NOT NULL,
        skills TEXT NOT NULL,
        FOREIGN KEY (companyId) REFERENCES companies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
    CREATE TABLE skills_with_timestamp (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      skill TEXT NOT NULL,
      timestamp TEXT NOT NULL
    )
  ''');
  }

  Future<int> addCompany(Map<String, dynamic> company) async {
    final db = await instance.database;
    return await db.insert('companies', company);
  }

  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final db = await instance.database;
    return await db.query('companies', orderBy: 'id ASC');
  }

  Future<int> updateCompany(int id, Map<String, dynamic> company) async {
    final db = await instance.database;
    return await db.update(
      'companies',
      company,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCompany(int id) async {
    final db = await instance.database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addVacancy(Map<String, dynamic> vacancy) async {
    final db = await instance.database;
    log("addVacancy - Inserting: $vacancy");
    final id = await db.insert('vacancies', vacancy);
    log("addVacancy - Inserted with ID: $id");
    return id;
  }

  Future<List<Map<String, dynamic>>> fetchVacancies(int companyId) async {
    final db = await instance.database;
    return await db.query(
      'vacancies',
      where: 'companyId = ?',
      whereArgs: [companyId],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> fetchAllVacancies() async {
    final db = await instance.database;
    return await db.query(
      'vacancies',
      orderBy: 'id ASC',
    );
  }

  Future<List<String>> getMostWantedSkills(int thresholdPercentage) async {
    final db = await instance.database;
    log('fetchAndProcessSkills - Getting database connection');

    // Step 1: Extracting all skills
    log('fetchAndProcessSkills - Executing query to get skills');
    final skillsQuery = await db.rawQuery('''
    SELECT skills
    FROM vacancies
    WHERE skills IS NOT NULL AND skills != ''
  ''');
    log('fetchAndProcessSkills - Query executed, found ${skillsQuery.length} records');

    // Step 2: Splitting skills and gathering all skills in one list
    List<String> allSkills = [];
    for (var row in skillsQuery) {
      final skills = row['skills'] as String;
      final skillsList = skills.split(',').map((skill) => skill.trim().toLowerCase()).toList(); // Converting to lowercase
      allSkills.addAll(skillsList);
    }
    log('fetchAndProcessSkills - Processed ${allSkills.length} skills');

    // Step 3: Counting the frequency of each skill
    final Map<String, int> skillCount = {};
    for (var skill in allSkills) {
      if (skill.isNotEmpty) {
        skillCount[skill] = (skillCount[skill] ?? 0) + 1;
      }
    }
    log('fetchAndProcessSkills - Counted ${skillCount.length} unique skills');

    // Logging the frequency of each skill
    skillCount.forEach((skill, count) {
      log('fetchAndProcessSkills - Skill "$skill" appears $count times');
    });

    // Step 4: Applying threshold as a percentage of the total number of vacancies
    final totalVacancies = skillsQuery.length;
    final thresholdCount = (totalVacancies * thresholdPercentage / 100).ceil(); // Number of vacancies that should contain the skill

    log('fetchAndProcessSkills - Threshold: at least $thresholdCount vacancies');

    // Step 5: Filtering skills by threshold
    final filteredSkills = skillCount.entries
        .where((entry) => entry.value >= thresholdCount) // Comparing with the calculated threshold
        .map((entry) => entry.key)
        .toList();

    log('fetchAndProcessSkills - After filtering, ${filteredSkills.length} skills remain that exceed the threshold of $thresholdPercentage%');

    // Step 6: Returning the result (list of skills)
    log('fetchAndProcessSkills - Returning ${filteredSkills.length} filtered skills');
    return filteredSkills;
  }

  Future<Map<String, dynamic>?> getCompanyById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return null;
    }
  }

  Future<void> saveSkillsWithTimestamp(List<String> skills) async {
    final db = await instance.database;
    final timestamp = DateTime.now().toIso8601String();

    for (String skill in skills) {
      await db.insert('skills_with_timestamp', {
        'skill': skill,
        'timestamp': timestamp,
      });
    }

    final result = await db.query('skills_with_timestamp');
    if (result.isNotEmpty) {
      log('Skills with timestamp inserted successfully. Total records: ${result.length}');
    } else {
      log('No skills with timestamp were inserted.');
    }
  }
}

// Future<void> clearDatabase() async {
//   final db = await instance.database;
//   await db.delete('skills_with_timestamp');
//   await db.delete('vacancies');
//   await db.delete('companies');
//   log('Database cleared.');
// }
