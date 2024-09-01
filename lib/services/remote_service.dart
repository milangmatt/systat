import 'package:systat/models/stat.dart';
import 'package:http/http.dart' as http;

class RemoteService {
  Future<Stat?> getStats() async {
    try {
      var client = http.Client();
      var uri = Uri.parse(
          'https://flysoft.dev:9500/intern-project/get-system-metrics');

      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var jsonData = response.body;
        var stats = statFromJson(jsonData);
        return stats;
      }
    } on Exception catch (_) {
      rethrow;
    }
  }
}
