import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Item.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/database/rem_helper.dart';
import 'package:moti_me/themes.dart';

DateTime selectedEndDate = DateTime.now();
final DateFormat formatter = DateFormat('yyyy/MM/dd');

class Reminder extends StatefulWidget {
  const Reminder({super.key, required this.remHelper, required this.dbHelper});
  final RemHelper remHelper;
  final DbHelper dbHelper;

  @override
  State<Reminder> createState() => ReminderState();
}

class ReminderState extends State<Reminder> {
  List<Widget> curRem = [];

  void clearReminders() {
    setState(() {
      curRem = [];
    });
  }

  void getList(BuildContext context) {
    curRem = [];
    final List<DateTime> dates = widget.remHelper.getEndDate();
    final List<String> titles = widget.remHelper.getTitles();
    final Map<String, String> data = widget.remHelper.getData();
    for (int i in List<int>.generate(titles.length, (x) => x)) {
      curRem.add(item(
          context, titles[i], data[titles[i]] ?? 'No Descriptions', dates[i], 'Ends On: '));
    }
  }

  Future<void> addReminder() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ReminderForm(onSubmit:
                (String title, String description, DateTime endDate) async {
              await widget.remHelper.addReminders(
                  title, description, endDate, widget.dbHelper.user!);
              setState(() {
                if (context.mounted) Navigator.pop(context);
              });
            }),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    getList(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Themes.headlineMedium('Reminder', context),
          Expanded(
            child: ListView.builder(
              itemCount: curRem.length,
              itemBuilder: (context, index) {
                return curRem[index];
              },
            ),
          ),
          ElevatedButton(
            onPressed: addReminder,
            child: Themes.bodyMedium('New Reminder', context),
          ),
        ],
      ),
    );
  }
}

class ReminderForm extends StatefulWidget {
  ReminderForm({super.key, required this.onSubmit});
  final Function(String, String, DateTime) onSubmit;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  State<ReminderForm> createState() => ReminderFormState();
}

class ReminderFormState extends State<ReminderForm> {
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedEndDate) {
      setState(() {
        selectedEndDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget._titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: widget._descController,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Enter Reminder'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              style: ButtonStyle(
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: const BorderSide(color: Colors.black),
              ))),
              onPressed: () => _selectDate(context),
              child: Themes.bodyLarge(
                  'Select Reminder Date: ${formatter.format(selectedEndDate)}',
                  context),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await widget.onSubmit(
                  widget._titleController.text, widget._descController.text, selectedEndDate);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
