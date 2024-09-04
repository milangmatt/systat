import 'package:systat/models/stat.dart';
import 'package:http/http.dart' as http;
import 'package:systat/views/fetcherror.dart';

class RemoteService {
  Future<Stat?> getStats(String url) async {
    var client = http.Client();
    try {
      var uri = Uri.parse(url);

      var response = await client.get(uri);
      if (response.statusCode == 200) {
        var jsonData = response.body;
        var stats = statFromJson(jsonData);
        return stats;
      } else {
        return null;
      }
    } catch (e) {
      errPage();
    }
    return null;
  }
}
