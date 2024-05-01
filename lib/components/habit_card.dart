import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/models/habit.dart';
import 'package:habit_builder/pages/edit.dart';
import 'package:habit_builder/providers/habit_providers.dart';
import 'package:sqflite/sqflite.dart';

class HabitCard extends ConsumerStatefulWidget {
  final Database database;
  final Habit habit;
  const HabitCard(
      {super.key, required, required this.habit, required this.database});

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard>
    with SingleTickerProviderStateMixin {
  bool shouldExpand = false;
  bool displayText = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              GestureDetector(
                child: ListTile(
                  leading: Text("${widget.habit.goal} Mins"),
                  title: Text(widget.habit.name),
                  subtitle: Text("Streak: ${widget.habit.status}"),
                  tileColor: widget.habit.completed == 1
                      ? Colors.lightGreen
                      : Colors.white,
                ),
                onTap: () {
                  setState(() {
                    shouldExpand = !shouldExpand;
                    displayText = false;
                  });
                },
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                height: shouldExpand ? 300 : 0,
                onEnd: () {
                  setState(() {
                    displayText = !displayText;
                  });
                },
                child: displayText
                    ? Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text("Date Started: ")),
                              Expanded(child: Text(widget.habit.dateStarted))
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: Text("Total Times Done: ")),
                              Expanded(
                                  child: Text(
                                      widget.habit.totalTimesDone.toString()))
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: Text("Longest Streak: ")),
                              Expanded(
                                  child: Text(
                                      widget.habit.longestStreak.toString()))
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(
                                  child: Text("Days Between Last: ")),
                              Expanded(
                                  child: Text(
                                      widget.habit.daysBetweenLast.toString()))
                            ],
                          ),
                          Row(
                            children: [
                              const Expanded(child: Text("Description: ")),
                              Expanded(child: Text(widget.habit.description))
                            ],
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => EditHabitPage(
                                          currentHabit: widget.habit,
                                          database: widget.database,
                                        )));
                              },
                              child: const Text("Edit Habit"))
                        ],
                      )
                    : Container(),
              ),
              Container(
                color: widget.habit.completed == 1
                    ? Colors.lightGreen
                    : Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: IconButton(
                          onPressed: () {
                            // Delete code goes here
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: const Text("Confirm Delete"),
                              action: SnackBarAction(
                                label: "Confirm",
                                onPressed: () async {
                                  ref.read(todoProvider.notifier).deleteHabit(
                                      widget.database, widget.habit.habitId);
                                },
                              ),
                            ));
                          },
                          icon: const Icon(Icons.delete)),
                    ),
                    Expanded(
                      child: IconButton(
                          onPressed: () async {
                            if (shouldExpand) {
                              return;
                            }
                            ref.read(todoProvider.notifier).completeTodo(
                                widget.habit.habitId, widget.database);
                          },
                          icon: const Icon(Icons.check_circle_outline)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
