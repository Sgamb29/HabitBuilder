import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/models/habit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final todoProvider =
    StateNotifierProvider<HabitListNotifier, List<Habit>>((ref) {
  return HabitListNotifier();
});

class HabitListNotifier extends StateNotifier<List<Habit>> {
  HabitListNotifier() : super([]);

  void addToState() async {
    state = await getFromDatabase();
  }

  void completeTodo(int id, Database database) async {
    state = [
      for (final habit in state)
        if (habit.habitId == id)
          Habit(
              completed: habit.completed == 1 ? 0 : 1,
              habitId: habit.habitId,
              name: habit.name,
              goal: habit.goal,
              status: habit.status,
              description: habit.description,
              totalTimesDone: habit.totalTimesDone,
              longestStreak: habit.longestStreak,
              daysBetweenLast: habit.daysBetweenLast,
              dateStarted: habit.dateStarted)
        else
          habit
    ];
    for (final habit in state) {
      if (habit.habitId == id) {
        int isCompleted = habit.completed == 1 ? 1 : 0;
        await database.rawUpdate(
            'UPDATE habits SET completed = ? WHERE id = ?', [isCompleted, id]);
      }
    }
  }

  void addToDb(Database database, Habit habit) {
    database.insert('habits', habit.toMap());
  }

  void editHabit(Database database, Habit habit) async {
    await database.rawUpdate(
        'UPDATE habits SET name = ?, goal = ?, description = ? WHERE id = ?',
        [habit.name, habit.goal, habit.description, habit.habitId]);
  }

  Future<List<Habit>> getFromDatabase() async {
    final database = await openDb();
    final List<Map<String, dynamic>> habitEntries =
        await database.query("habits");

    List<Habit> dbHabits = [];
    for (final entry in habitEntries) {
      dbHabits.add(Habit(
        habitId: entry['id'],
        name: entry['name'],
        goal: entry['goal'],
        status: entry['status'],
        completed: entry['completed'] as int,
        description: entry["description"],
        dateStarted: entry["dateStarted"],
        longestStreak: entry["longestStreak"],
        daysBetweenLast: entry["daysBetweenLast"],
        totalTimesDone: entry["totalTimesDone"],
      ));
    }

    return dbHabits;
  }

  int getListLen() {
    return state.length;
  }

  void startNewDay(Database database) async {
    List notCompletedIds = [
      for (final habit in state)
        if (habit.completed == 0) habit.habitId
    ];

    List completedIds = [
      for (final habit in state)
        if (habit.completed == 1) habit.habitId
    ];

    for (final idNum in notCompletedIds) {
      await database.rawUpdate(
          'UPDATE habits SET status = ?, completed = ?, daysBetweenLast = daysBetweenLast + 1 WHERE id = ?',
          [0, 0, idNum]);
    }

    for (final idNum in completedIds) {
      await database.rawUpdate(
          'UPDATE habits SET status = status + 1, completed = ?, totalTimesDone = totalTimesDone + 1, daysBetweenLast = 0  WHERE id = ?',
          [0, idNum]);
    }

    await database.rawUpdate(
        'UPDATE habits SET longestStreak = longestStreak + 1 WHERE status > longestStreak');
  }

  void deleteHabit(Database database, int index) async {
    await database.rawDelete('DELETE FROM habits WHERE id = ?', [index]);
    state = state.where((habit) => habit.habitId != index).toList();
  }
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

// final databaseProvider = StateProvider<Future<Database>>((ref) {
//   return openDb();
// });
