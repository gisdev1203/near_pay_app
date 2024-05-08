import 'package:http/http.dart' as http;
import 'package:near_pay_app/presantation/utils/ninja/ninja_node.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';
import 'package:near_pay_app/service_locator.dart';

import 'dart:convert';





class NinjaAPI {
  // ignore: constant_identifier_names
  static const String API_URL = 'apiurl';

  static Future<String?> getAndCacheAPIResponse() async {
    String url = '$API_URL/accounts/verified';
    http.Response response = await http.get(Uri.parse(url), headers: {});
    if (response.statusCode != 200) {
      return null;
    }
    await sl.get<SharedPrefsUtil>().setNinjaAPICache(response.body);
    return response.body;
  }

  /// Get verified nodes, return null if an error occured
  static Future<List<NinjaNode>> getVerifiedNodes() async {
    String? httpResponseBody = await getAndCacheAPIResponse();
    List<NinjaNode> ninjaNodes = (json.decode(httpResponseBody!) as List)
        .map((e) => NinjaNode.fromJson(e))
        .toList();
    return ninjaNodes;
  }

  static Future<List<NinjaNode>> getCachedVerifiedNodes() async {
    String rawJson = await sl.get<SharedPrefsUtil>().getNinjaAPICache();
    List<NinjaNode> ninjaNodes = (json.decode(rawJson) as List)
        .map((e) => NinjaNode.fromJson(e))
        .toList();
    return ninjaNodes;
  }
}
