import 'package:flutter/material.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/database/journal_helper.dart';
import 'package:moti_me/tabs/Item.dart';
import 'package:moti_me/tabs/Tasks.dart';
import 'package:moti_me/themes.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Journal extends StatefulWidget {
  const Journal({
    super.key,
    required this.dbHelper,
    required this.journalHelper,
    required this.title,
    required this.task,
  });
  final DbHelper dbHelper;
  final JournalHelper journalHelper;
  final String title;
  final ParseObject task;

  @override
  State<Journal> createState() => _JournalState();
}

class _JournalState extends State<Journal> {
  late OverlayEntry overlayEntry;
  late OverlayState overlayState;
  final layerLink = LayerLink();
  final PageController _pageController = PageController(initialPage: 0);

  List<Widget> curJournal = [];

  Widget journalWidgets() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: curJournal.length,
              itemBuilder: (context, index) {
                return curJournal[index];
              },
            ),
          ),
          Themes.titleMedium('Swipe to Add Journal', context),
        ],
      ),
    );
  }

  Future<void> getJournal(BuildContext context) async {
    curJournal = [];
    List<dynamic> temp;
    List<String> title = [];
    List<String> content = [];
    List<String> dates = [];
    temp = await widget.journalHelper.loadJournal(widget.task);
    for (int i in List<int>.generate(temp.length, (x) => x)) {
      if (i % 3 == 0) {
        title.add(temp[i]);
      } else if (i % 3 == 1) {
        content.add(temp[i]);
      } else {
        dates.add(temp[i]);
      }
    }
    for (int i in List<int>.generate(title.length, (x) => x)) {
      if (context.mounted) {
        curJournal.add(item(context, title[i], content[i],
            DateTime.parse(dates[i]), 'Written On: '));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    overlayEntry = buildOverlay();
    final overlayState = Overlay.of(context);

    return CompositedTransformTarget(
      link: layerLink,
      child: ElevatedButton(
        onPressed: () async {
          await getJournal(context);
          overlayState.insert(overlayEntry);
        },
        child: const Text('Journal'),
      ),
    );
  }

  OverlayEntry buildOverlay() => OverlayEntry(
        builder: (_) {
          return Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                width: 375,
                height: 800,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18.0),
                          topRight: Radius.circular(18.0),
                        ),
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: overlayEntry.remove,
                              ),
                            ],
                          ),
                          Themes.titleLarge('Journal Entry', context),
                          const SizedBox(height: 5.0),
                          Themes.titleLarge(
                              'Task Title: ${widget.title}', context),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          journalWidgets(),
                          JournalForm(
                              task: widget.task,
                              onSubmit: (String title, String content) async {
                                await widget.journalHelper
                                    .addJournal(title, content, widget.task);
                                setState(() {
                                  getJournal(context);
                                });
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class JournalForm extends StatefulWidget {
  const JournalForm({super.key, required this.task, required this.onSubmit});
  final Function(
    String,
    String,
  ) onSubmit;
  final ParseObject task;
  @override
  State<JournalForm> createState() => _JournalFormState();
}

class _JournalFormState extends State<JournalForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
            ),
            Material(
              child: TextFormField(
                controller: _descController,
                maxLines: null,
                decoration:
                    const InputDecoration(labelText: 'Enter Journal Entry'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter something for your Journal Entry';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await widget.onSubmit(
                    _titleController.text,
                    _descController.text,
                  );
                  _titleController.clear();
                  _descController.clear();
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
