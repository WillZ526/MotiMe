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

  void getList(BuildContext context) {
    curRef = [];
    final List<DateTime> dates = widget.refHelper.getCreateDate();
    final List<String> titles = widget.refHelper.getTitles();
    final Map<String, String> data = widget.refHelper.getData();
    for (int i in List<int>.generate(titles.length, (x) => x)) {
      curRef.add(item(context, titles[i], data[titles[i]] ?? 'No Descriptions',
          dates[i], 'Created On: '));
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
            child: Themes.titleLarge('New Reflection', context),
          ),
        ],
      ),
    );
  }
}

class ReflectionForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final Function(String, String) onSubmit;
  ReflectionForm({super.key, required this.onSubmit});
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

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
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descController,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Enter Reflection'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  await onSubmit(_titleController.text, _descController.text);
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
