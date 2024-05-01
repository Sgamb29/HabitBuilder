import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/models/habit.dart';
import 'package:habit_builder/providers/habit_providers.dart';
import 'package:sqflite/sqflite.dart';

class EditHabitPage extends ConsumerStatefulWidget {
  final Database database;
  final Habit currentHabit;
  const EditHabitPage(
      {super.key,
      required,
      required this.currentHabit,
      required this.database});

  @override
  ConsumerState<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends ConsumerState<EditHabitPage> {
  double _currentSliderValue = 10;
  late TextEditingController habitController;
  late TextEditingController descriptionController;
  String tipText =
      "Tip: To increase the likelihood of sticking with a habit choose something you can do in 10 minutes or less!";

  @override
  void initState() {
    super.initState();
    habitController = TextEditingController();
    descriptionController = TextEditingController();
    habitController.text = widget.currentHabit.name;
    descriptionController.text = widget.currentHabit.description;
    _currentSliderValue = widget.currentHabit.goal.toDouble();
  }

  @override
  void dispose() {
    habitController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Edit a Habit")),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(tipText),
                ),
                const Text("Set daily time for habit:"),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Slider(
                    value: _currentSliderValue,
                    max: 60,
                    min: 2,
                    divisions: 58,
                    label: _currentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentSliderValue = value;
                        if (_currentSliderValue > 50) {
                          tipText = "Over 50 minutes, real go-getter!";
                        } else if (_currentSliderValue <= 20 &&
                            _currentSliderValue >= 15) {
                          tipText =
                              "Tip: Did you know you can learn a language in just 15-20 minutes a day?";
                        } else {
                          tipText =
                              "Tip: A good rule of thumb for setting new habits is to set something you can do in 2-10 minutes!";
                        }
                      });
                    },
                  ),
                ),
                TextField(
                  controller: habitController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: "Habit Name"),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    maxLength: 200,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Habit Description"),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      if (habitController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Name Field is Blank"),
                          action: SnackBarAction(
                            label: "Dismiss",
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ));
                        return;
                      } else if (descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Description Field is Blank"),
                          action: SnackBarAction(
                            label: "Dismiss",
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            },
                          ),
                        ));
                        return;
                      }

                      ref.read(todoProvider.notifier).editHabit(
                          widget.database,
                          Habit(
                              completed: widget.currentHabit.completed,
                              habitId: widget.currentHabit.habitId,
                              name: habitController.text,
                              goal: _currentSliderValue.toInt(),
                              status: widget.currentHabit.status,
                              description: descriptionController.text,
                              totalTimesDone:
                                  widget.currentHabit.totalTimesDone,
                              longestStreak: widget.currentHabit.longestStreak,
                              daysBetweenLast:
                                  widget.currentHabit.daysBetweenLast,
                              dateStarted: widget.currentHabit.dateStarted));
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Finish Editing Habit")),
              ],
            ),
          ),
        ));
  }
}
