import 'package:flutter/material.dart';
import 'Item.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/database/ref_helper.dart';
import 'package:moti_me/themes.dart';

class Reflection extends StatefulWidget {
  const Reflection(
      {super.key, required this.refHelper, required this.dbHelper});
  final RefHelper refHelper;
  final DbHelper dbHelper;

  @override
  State<Reflection> createState() => ReflectionState();
}

class ReflectionState extends State<Reflection> {
  List<Widget> curRef = [];

  void clearReflections() {
    setState(() {
      curRef = [];
    });
  }

  void getList(BuildContext context) {
    curRef = [];
    final List<DateTime> dates = widget.refHelper.getCreateDate();
    final List<String> titles = widget.refHelper.getTitles();
    final Map<String, String> data = widget.refHelper.getData();
    for (int i in List<int>.generate(titles.length, (x) => x)) {
      curRef.add(item(
          context, titles[i], data[titles[i]] ?? 'No Descriptions', dates[i], 'Created On: '));
    }
  }

  Future<void> addReflection() async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ReflectionForm(
                onSubmit: (String title, String description) async {
              await widget.refHelper
                  .addReflection(title, description, widget.dbHelper.user!);
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
          Themes.headlineMedium('Reflection', context),
          Expanded(
            child: ListView.builder(
              itemCount: curRef.length,
              itemBuilder: (context, index) {
                return curRef[index];
              },
            ),
          ),
          ElevatedButton(
            onPressed: addReflection,
            child: Themes.bodyMedium('New Refection', context),
          ),
        ],
      ),
    );
  }
}

class ReflectionForm extends StatelessWidget {
  final Function(String, String) onSubmit;
  ReflectionForm({super.key, required this.onSubmit});

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _descController,
            maxLines: null,
            decoration: const InputDecoration(labelText: 'Enter Reflection'),
          ),
          ElevatedButton(
            onPressed: () async {
              await onSubmit(_titleController.text, _descController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
