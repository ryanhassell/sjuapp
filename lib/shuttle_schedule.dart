// shuttle_schedule.dart
import 'package:flutter/material.dart';


class ShuttleSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shuttle Schedules'),
      ),
      body: ListView.builder(
        itemCount: exampleSchedules.length,
        itemBuilder: (context, index) {
          final schedule = exampleSchedules[index];
          return ExpansionTile(
            title: Text(schedule.destination),
            children: schedule.schedule
                .map((daySchedule) => ListTile(
              title: Text(daySchedule.day),
              subtitle: Text(daySchedule.timings.join(', ')),
            ))
                .toList(),
          );
        },
      ),
    );
  }
}

class ShuttleSchedule {
  final String destination;
  final List<DaySchedule> schedule;

  ShuttleSchedule(this.destination, this.schedule);
}

class DaySchedule {
  final String day;
  final List<String> timings;

  DaySchedule(this.day, this.timings);
}

// Example schedule data
List<ShuttleSchedule> exampleSchedules = [
  ShuttleSchedule(
    'Target',
    [
      DaySchedule('Monday', ['2:00 PM']),
      DaySchedule('Wednesday', ['2:00 PM']),
    ],
  ),
  ShuttleSchedule(
    'Acme',
    [
      DaySchedule('Tuesday', ['11:00 AM']),
      DaySchedule('Thursday', ['11:00 AM']),
    ],
  ),
];
