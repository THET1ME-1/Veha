import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/tasks/tasks_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Задачи списком', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: TasksScreen())),
      seed: (repo) async {
        await repo.upsertTask(VTask(
          id: 't1',
          calendarId: 'c-study',
          title: 'Сдать эссе по грамматике',
          due: testNow.add(const Duration(days: 1)),
          hasTime: true,
          notes: 'Две страницы, тема свободная',
        ));
        await repo.upsertTask(VTask(
          id: 't2',
          calendarId: 'c-home',
          title: 'Записаться к врачу',
          due: testNow.subtract(const Duration(days: 2)),
        ));
        await repo.upsertTask(VTask(
          id: 't3',
          calendarId: 'c-work',
          title: 'Придумать название разделу',
        ));
        await repo.upsertTask(VTask(
          id: 't4',
          calendarId: 'c-sport',
          title: 'Купить абонемент',
          completedAt: testNow.subtract(const Duration(hours: 3)),
        ));
      },
    );
    await shoot(tester, 'tasks');
  });

  // Просроченная задача отмечается словом и цветом ошибки: срок, ушедший в
  // прошлое, должен читаться без сравнения дат в уме.
  testWidgets('Пустой список задач', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: TasksScreen())),
    );
    await shoot(tester, 'tasks_empty');
  });
}
