import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class JournalHelper {
  final DateFormat formatter = DateFormat('MM/dd/yyyy');

  ParseResponse? apiResponse;
  final QueryBuilder<ParseObject> parseQuery =
      QueryBuilder<ParseObject>(ParseObject('Journal'));

  static final JournalHelper _journalHelper = JournalHelper._();
  JournalHelper._();
  factory JournalHelper() {
    return _journalHelper;
  }

  Future<List<dynamic>> loadJournal(ParseObject task) async {
    List<String> temp = [];
    final QueryBuilder<ParseObject> journalQuery =
        QueryBuilder<ParseObject>(ParseObject('Journal'))
          ..whereEqualTo('Task', task);

    final ParseResponse journal = await journalQuery.query();

    if (journal.success && journal.result != null) {
      for (var i in journal.result as List<ParseObject>) {
        temp.add(i['title']);
        temp.add(i['content']);
        temp.add(i['createdAt'].toString());
      }
    } else if (journal.result == null) {
      return temp;
    } else {
      print('Error: ${journal.error}');
    }
    return temp;
  }

  Future<void> addJournal(
      String title, String content, ParseObject task) async {
    var profile = ParseObject('Journal');
    profile.set('title', title);
    profile.set('content', content);
    profile.set('Task', task);
    await profile.save();
  }
}
