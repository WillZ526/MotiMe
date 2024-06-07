import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class RefHelper {
  ParseResponse? apiResponse;
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Reflection'));

  static final RefHelper _refHelper = RefHelper._();
  RefHelper._();
  factory RefHelper() {
    return _refHelper;
  }

  List<DateTime> createDate = [];
  List<String> titles = [];
  Map<String, String> initList = {};

  Future<void> loadReflections(ParseUser user) async {
    clearReflection();
    final List<dynamic>? temp = await getReflections(user);
    if (temp != null) {
      for (var i in temp) {
        createDate.add(i['createdAt']);
        titles.add(i['title']);
        initList.addAll({i['title']: i['description']});
      }
    }
  }

  List<DateTime> getCreateDate() => createDate;
  List<String> getTitles() => titles;
  Map<String, String> getData() => initList;

  Future<void> reloadReflection(ParseUser user) async {
    parseQuery.whereEqualTo('User', user);
    apiResponse = await parseQuery.query();
  }

  Future<List<dynamic>?> getReflections(ParseUser user) async {
    if (apiResponse == null) {
      await reloadReflection(user);
    }
    if (apiResponse != null && apiResponse!.success) {
      return apiResponse!.results;
    } else {
      print('Error fetching reflections: ${apiResponse?.error?.message}');
      return null;
    }
  }

  Future<void> addReflection(
      String title, String description, ParseUser user) async {
    var profile = ParseObject('Reflection');
    profile.set('title', title);
    profile.set('description', description);
    profile.set('User', user);
    await profile.save();
    await loadReflections(user);
  }

  void clearReflection() {
    createDate.clear();
    titles.clear();
    initList.clear();
    apiResponse = null;
  }
}
