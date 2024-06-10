import 'package:flutter/material.dart';
import 'package:moti_me/themes.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('MM/dd/yyyy');

Widget item(BuildContext context, String title, String description,
    DateTime createDate, String type) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Themes.titleLarge(title, context),
              Themes.titleMedium('$type ${formatter.format(createDate)}', context),
              const SizedBox(height: 10),
              Themes.titleMedium(description, context),
            ],
          ),
        ),
      ),
    ),
  );
}
