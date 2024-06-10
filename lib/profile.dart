import 'package:flutter/material.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/themes.dart';

class profile extends StatefulWidget {
  const profile({super.key, required this.dbHelper});
  final DbHelper dbHelper;

  @override
  State<profile> createState() => profileState();
}

class profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColorLight,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 40),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorDark,
              radius: 60,
              backgroundImage: const NetworkImage(
                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 75, top: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Themes.headlineMedium(
                  'Welcome,',
                  context,
                ),
                Text('${widget.dbHelper.getUser()!.username!}!',
                  style: Theme.of(context).textTheme.headlineMedium,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
