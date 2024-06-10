import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskHelper {
  ParseResponse? apiResponse;
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Task'));

  static final TaskHelper _taskHelper = TaskHelper._();
  TaskHelper._();
  factory TaskHelper() {
    return _taskHelper;
  }
  List<String> taskType = [];
  List<int> streak = [];
  List<DateTime> repeatDate = [];
  List<String> titles = [];
  Map<String, String> initList = {};
  List<ParseObject> tasks = [];

  Future<void> loadTasks(ParseUser user) async {
    clearTasks();
    final List<dynamic>? temp = await getTasks(user);
    if (temp != null) {
      for (var i in temp) {
        streak.add(i['streak']);
        repeatDate.add(i['repeatDate']);
        titles.add(i['title']);
        initList.addAll({i['title']: i['description']});
        taskType.add(i['TaskType']);
      }
    }
    final QueryBuilder<ParseObject> taskQuery =
        QueryBuilder<ParseObject>(ParseObject('Task'))
          ..whereEqualTo('User', user);

    final ParseResponse publisherResponse = await taskQuery.query();
    if (!publisherResponse.success || publisherResponse.result==null) {
      return;
    }
    tasks = publisherResponse.results as List<ParseObject>;
  }

  List<DateTime> getRepeatDate() => repeatDate;
  List<String> getTitles() => titles;
  Map<String, String> getData() => initList;
  List<ParseObject> getTaskList() => tasks;

  Future<void> reloadTasks(ParseUser user) async {
    parseQuery.whereEqualTo('User', user);
    apiResponse = await parseQuery.query();
  }

  Future<List<dynamic>?> getTasks(ParseUser user) async {
    if (apiResponse == null) {
      await reloadTasks(user);
    }
    if (apiResponse != null && apiResponse!.success) {
      return apiResponse!.results;
    } else {
      print('Error fetching tasks: ${apiResponse?.error?.message}');
      return null;
    }
  }

  Future<void> addTasks(String title, String description, DateTime repeatDate,
      String taskType, ParseUser user) async {
    var profile = ParseObject('Task');
    profile.set('title', title);
    profile.set('description', description);
    profile.set('repeatDate', repeatDate);
    profile.set('streak', 1);
    profile.set('User', user);
    profile.set('TaskType', taskType);
    await profile.save();
    await loadTasks(user);
  }

  void clearTasks() {
    streak.clear();
    repeatDate.clear();
    titles.clear();
    initList.clear();
    apiResponse = null;
  }
}
