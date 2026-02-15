import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../providers/auth_provider.dart';
import '../providers/reminder_provider.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reminder = context.watch<ReminderProvider>();

    final user = auth.user;
    if (user == null) {
      return const SafeArea(child: Center(child: Text('Please login to manage reminders.')));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Add
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recycling Reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddReminderDialog(context, user.uid),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 2,
              child: SwitchListTile(
                value: reminder.notificationsEnabled,
                onChanged: (val) => context.read<ReminderProvider>().setNotificationsEnabled(val),
                title: const Text('Notifications'),
                subtitle: const Text('Enable/disable reminder notifications (state managed by Provider)'),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: reminder.loading
                  ? const Center(child: CircularProgressIndicator())
                  : reminder.reminders.isEmpty
                      ? const Center(
                          child: Text(
                            'No reminders yet.\nTap Add to create one.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.separated(
                          itemCount: reminder.reminders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final r = reminder.reminders[index];

                            return Card(
                              elevation: 2,
                              child: ListTile(
                                leading: const Icon(Icons.alarm, color: Colors.green),
                                title: Text('${r.dayOfWeek} • ${r.time}'),
                                subtitle: r.note.isEmpty ? const Text('No note') : Text(r.note),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    try {
                                      await context.read<ReminderProvider>().deleteReminder(
                                            uid: user.uid,
                                            reminderId: r.id,
                                          );
                                      Fluttertoast.showToast(msg: 'Reminder deleted');
                                    } catch (_) {
                                      Fluttertoast.showToast(msg: 'Failed to delete reminder');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReminderDialog(BuildContext context, String uid) async {
    const dayOptions = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    String selectedDay = 'Monday';
    TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);
    final noteController = TextEditingController();
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: !saving,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return AlertDialog(
              title: const Text('Add Reminder'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDay,
                      decoration: const InputDecoration(
                        labelText: 'Day of week',
                        border: OutlineInputBorder(),
                      ),
                      items: dayOptions.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: saving ? null : (val) => setLocalState(() => selectedDay = val ?? 'Monday'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: saving
                          ? null
                          : () async {
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime: selectedTime,
                              );
                              if (picked != null) {
                                setLocalState(() => selectedTime = picked);
                              }
                            },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(selectedTime.format(ctx)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      enabled: !saving,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Blue bin downstairs',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setLocalState(() => saving = true);
                          try {
                            await context.read<ReminderProvider>().addReminder(
                                  uid: uid,
                                  dayOfWeek: selectedDay,
                                  time: _timeOfDayToString(selectedTime),
                                  note: noteController.text.trim(),
                                );
                            Fluttertoast.showToast(msg: 'Reminder added');
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (_) {
                            Fluttertoast.showToast(msg: 'Failed to add reminder');
                            setLocalState(() => saving = false);
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    noteController.dispose();
  }

  String _timeOfDayToString(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
