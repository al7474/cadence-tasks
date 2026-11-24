import 'package:cadence_tasks/core/domain/local_date.dart';
import 'package:cadence_tasks/core/domain/local_time.dart';
import 'package:cadence_tasks/features/routines/domain/routine_template.dart';
import 'package:cadence_tasks/features/tasks/presentation/widgets/task_editor_sheet.dart';
// Keep compatibility with the declared Flutter 3.38.1 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class RoutineEditorSheet extends StatelessWidget {
  const RoutineEditorSheet({
    this.routine,
    this.initialDate,
    this.initialTime,
    super.key,
  });

  final RoutineTemplate? routine;
  final LocalDate? initialDate;
  final LocalTime? initialTime;

  @override
  Widget build(BuildContext context) {
    return TaskEditorSheet(
      routine: routine,
      initialDate: initialDate,
      initialTime: initialTime,
      startAsRoutine: routine == null,
    );
  }
}
