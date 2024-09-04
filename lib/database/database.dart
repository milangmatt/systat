import 'package:hive/hive.dart';

class sysstatdb {
  String url = '';

  final _database = Hive.box('staturi');

  void create_init_uri() {
    url = 'https://flysoft.dev:9500/intern-project/get-system-metrics';
  }

  void load_uri() {
    url = _database.get("url");
  }

  void update_uri() {
    _database.put("url", url);
  }
}
