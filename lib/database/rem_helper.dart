import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class RemHelper {
  ParseResponse? apiResponse;
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Reminder'));

  static final RemHelper _remHelper = RemHelper._();
  RemHelper._();
  factory RemHelper() {
    return _remHelper;
  }

  List<DateTime> endDate = [];
  List<String> titles = [];
  Map<String, String> initList = {};

  Future<void> loadReminders(ParseUser user) async {
    clearReminders();
    final List<dynamic>? temp = await getReminders(user);
    if (temp != null) {
      for (var i in temp) {
        endDate.add(i['endDate']);
        titles.add(i['title']);
        initList.addAll({i['title']: i['description']});
      }
    }
  }

  List<DateTime> getEndDate() => endDate;
  List<String> getTitles() => titles;
  Map<String, String> getData() => initList;

  Future<void> reloadReminders(ParseUser user) async {
    parseQuery.whereEqualTo('User', user);
    apiResponse = await parseQuery.query();
  }

  Future<List<dynamic>?> getReminders(ParseUser user) async {
    if (apiResponse == null) {
      await reloadReminders(user);
    }
    if (apiResponse != null && apiResponse!.success) {
      return apiResponse!.results;
    } else {
      print('Error fetching reminders: ${apiResponse?.error?.message}');
      return null;
    }
  }

  Future<void> addReminders(String title, String description, DateTime endDate,
      ParseUser user) async {
    var profile = ParseObject('Reminder');
    profile.set('title', title);
    profile.set('description', description);
    profile.set('endDate', endDate);
    profile.set('User', user);
    await profile.save();
    await loadReminders(user);
  }

  void clearReminders() {
    endDate.clear();
    titles.clear();
    initList.clear();
    apiResponse = null;
  }
}
