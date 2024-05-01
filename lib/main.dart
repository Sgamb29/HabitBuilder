import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/pages/home.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Database database = await openDb();
  runApp(ProviderScope(
      child: MyApp(
    database: database,
  )));
}

Future<Database> openDb() async {
  final path = join(await getDatabasesPath(), "journal.db");
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE habits(id INTEGER PRIMARY KEY, name TEXT, goal INTEGER, status INTEGER, completed INTEGER, daysBetweenLast INTEGER, longestStreak INTEGER, description TEXT, dateStarted TEXT, totalTimesDone INTEGER)');
    },
  );
}

// Future<List<Habit>> getFromDatabase() async {
//   final database = await openDb();
//   final List<Map<String, dynamic>> habitEntries =
//       await database.query("habits");

//   List<Habit> dbHabits = [];
//   for (final entry in habitEntries) {
//     dbHabits.add(Habit(
//       habitId: entry['id'],
//       name: entry['name'],
//       goal: entry['goal'],
//       status: entry['status'],
//       completed: entry['completed'] as int,
//       description: entry["description"],
//       dateStarted: entry["dateStarted"],
//       longestStreak: entry["longestStreak"],
//       daysBetweenLast: entry["daysBetweenLast"],
//       totalTimesDone: entry["totalTimesDone"],
//     ));
//   }

//   return dbHabits;
// }

class MyApp extends ConsumerWidget {
  final Database database;
  const MyApp({super.key, required this.database});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: HomePageWidget(
        database: database,
      ),
    );
  }
}
