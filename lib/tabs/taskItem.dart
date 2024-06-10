import 'package:flutter/material.dart';
import 'package:moti_me/themes.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('MM/dd/yyyy');
final DateFormat timeFormatter = DateFormat('h:mm a');

Widget taskItem(BuildContext context, String title, String description,
    DateTime remindDate, Widget checkJournal) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Themes.titleLarge(title, context),
                    Column(
                      children: [
                        Themes.titleMedium(
                            'Alarm Date: ${formatter.format(remindDate)}', context),
                        Themes.titleMedium(
                            'Alarm Time: ${timeFormatter.format(remindDate)}', context),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Themes.titleMedium(description, context),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 200),
                  child: checkJournal,
                )
              ],
            ),
          ),
        ),
      ),
    );

}
