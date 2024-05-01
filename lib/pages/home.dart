import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_builder/components/habit_card.dart';
import 'package:habit_builder/models/habit.dart';
import 'package:habit_builder/pages/add.dart';
import 'package:habit_builder/providers/habit_providers.dart';
import 'package:sqflite/sqflite.dart';

class HomePageWidget extends ConsumerStatefulWidget {
  final Database database;
  const HomePageWidget({super.key, required, required this.database});

  @override
  ConsumerState<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends ConsumerState<HomePageWidget> {
  @override
  Widget build(BuildContext context) {
    ref.read(todoProvider.notifier).addToState();
    List<Habit> habits = ref.watch(todoProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddHabitPage(
                    database: widget.database,
                  )));
        },
        elevation: 8,
        child: const Icon(
          Icons.add,
          size: 24,
        ),
      ),
      appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () async {
                  ref.read(todoProvider.notifier).startNewDay(widget.database);
                },
                child: const Text("New Day"))
          ],
          automaticallyImplyLeading: false,
          title: const Text(
            'Habit Builder',
            textAlign: TextAlign.center,
          )),
      body: ListView.builder(
          itemCount: habits.length + 1,
          itemBuilder: (context, index) {
            if (habits.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(top: 300.0),
                child:
                    Center(child: Text("Add a habit using the button below.")),
              );
            } else {
              if (index == habits.length) {
                return Container();
              } else {
                return HabitCard(
                    habit: habits[index], database: widget.database);
              }
            }
          }),
    );
  }
}
