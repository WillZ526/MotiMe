import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moti_me/database/journal_helper.dart';
import 'package:moti_me/database/task_helper.dart';
import 'package:moti_me/main.dart';
import 'package:moti_me/tabs/taskItem.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/themes.dart';
import 'package:moti_me/tabs/Journal.dart';

DateTime selectedRepeatDate = DateTime.now();
String taskType = 'Daily';
final DateFormat formatter = DateFormat('MM/dd/yyyy');
final DateFormat timeFormatter = DateFormat('h:mm a');
JournalHelper journalHelper = JournalHelper();

class Task extends StatefulWidget {
  const Task({super.key, required this.taskHelper, required this.dbHelper});
  final TaskHelper taskHelper;
  final DbHelper dbHelper;

  @override
  State<Task> createState() => TaskState();
}

class TaskState extends State<Task> {
  List<Widget> curTask = [];

  void getList(BuildContext context) {
    curTask = [];
    final List<DateTime> dates = widget.taskHelper.getRepeatDate();
    final List<String> titles = widget.taskHelper.getTitles();
    final Map<String, String> data = widget.taskHelper.getData();
    for (int i in List<int>.generate(titles.length, (x) => x)) {
      curTask.add(taskItem(
        context,
        titles[i],
        data[titles[i]] ?? 'No Descriptions',
        dates[i],
        Journal(
          dbHelper: dbHelper,
          journalHelper: journalHelper,
          task: taskHelper.getTaskList()[i],
          title: titles[i],
        ),
      ));
    }
  }

  Future<void> addTask() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: TaskForm(onSubmit: (String title, String description,
                String taskType, DateTime repeatDate) async {
              await widget.taskHelper.addTasks(title, description,
                  selectedRepeatDate, taskType, widget.dbHelper.user!);
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
          Themes.headlineMedium('Tasks', context),
          Expanded(
            child: ListView.builder(
              itemCount: curTask.length,
              itemBuilder: (context, index) {
                return curTask[index];
              },
            ),
          ),
          ElevatedButton(
            onPressed: addTask,
            child: Themes.titleLarge('New Task', context),
          ),
        ],
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  TaskForm({super.key, required this.onSubmit});
  final Function(String, String, String, DateTime) onSubmit;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  State<TaskForm> createState() => TaskFormState();
}

class TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  _selectTime(BuildContext context) async {
    TimeOfDay initTime = TimeOfDay.fromDateTime(selectedRepeatDate);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initTime,
    );
    if (picked != null &&
        picked != TimeOfDay.fromDateTime(selectedRepeatDate)) {
      setState(() {
        selectedRepeatDate = DateTime(
            selectedRepeatDate.year,
            selectedRepeatDate.month,
            selectedRepeatDate.day,
            picked.hour,
            picked.minute);
      });
    }
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedRepeatDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2034),
    );
    if (picked != null && picked != selectedRepeatDate) {
      setState(() {
        selectedRepeatDate = DateTime(picked.year, picked.month, picked.day,
            selectedRepeatDate.hour, selectedRepeatDate.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: widget._titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: widget._descController,
              maxLines: null,
              decoration:
                  const InputDecoration(labelText: 'Enter Task Descriptions'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TaskSelectionWidget(
              onTaskTypeSelected: (String selectedTaskType) {
                taskType = selectedTaskType;
              },
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
                    'Select Task Repeat Date: ${formatter.format(selectedRepeatDate)}',
                    context),
              ),
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
                onPressed: () => _selectTime(context),
                child: Themes.bodyLarge(
                    'Select Task Repeat Time: ${timeFormatter.format(selectedRepeatDate)}',
                    context),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await widget.onSubmit(
                    widget._titleController.text,
                    widget._descController.text,
                    taskType,
                    selectedRepeatDate,
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskSelectionWidget extends StatefulWidget {
  const TaskSelectionWidget({super.key, required this.onTaskTypeSelected});
  final Function(String) onTaskTypeSelected;

  @override
  State<TaskSelectionWidget> createState() => _TaskSelectionWidgetState();
}

class _TaskSelectionWidgetState extends State<TaskSelectionWidget> {
  late FixedExtentScrollController scrollController;
  late OverlayEntry overlayEntry;
  final layerLink = LayerLink();
  final tasks = ['Daily', 'Weekly', 'Bi-Weekly', 'Monthly', 'Annually'];

  int findTask(String t) {
    int x = 0;
    for (String i in tasks) {
      if (i == t) break;
      x++;
    }
    return x;
  }

  @override
  void initState() {
    scrollController =
        FixedExtentScrollController(initialItem: findTask(taskType));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget selectTask() {
    return Material(
      borderRadius: BorderRadius.circular(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Themes.headlineMedium('Task Type', context),
          SizedBox(
            height: 250,
            child: CupertinoPicker(
              scrollController: scrollController,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              itemExtent: 60,
              onSelectedItemChanged: (index) {
                widget.onTaskTypeSelected(tasks[index]);
              },
              children: tasks
                  .map((task) =>
                      Center(child: Themes.headlineMedium(task, context)))
                  .toList(),
            ),
          ),
          ElevatedButton(
            child: Themes.headlineMedium('Select', context),
            onPressed: () {
              setState(() {});
              overlayEntry.remove();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    overlayEntry = buildOverlay(selectTask());
    final overlayState = Overlay.of(context);

    return CompositedTransformTarget(
      link: layerLink,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 300,
          child: TextButton(
            style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.black),
            ))),
            onPressed: () => overlayState.insert(overlayEntry),
            child: Themes.bodyLarge('Select Task Type: $taskType', context),
          ),
        ),
      ),
    );
  }

  OverlayEntry buildOverlay(Widget selectTask) => OverlayEntry(builder: (_) {
        return Container(
          color: Colors.black54,
          child: Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.0),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: CompositedTransformFollower(
                link: layerLink,
                targetAnchor: Alignment.topCenter,
                followerAnchor: Alignment.bottomCenter,
                child: selectTask,
              ),
            ),
          ),
        );
      });
}
