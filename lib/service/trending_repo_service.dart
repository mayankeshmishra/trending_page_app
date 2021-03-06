import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trending_page_app/state/models/trendingRepoModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<TrendingRepo>>? fetchTrendingRepo(
    Function? errorCallback, bool? forceFetch) async {
  String url = "https://gh-trending-api.herokuapp.com/repositories";
  try {
    if (!forceFetch!) {
      dynamic res = await fetchFromLocalStorage();
      if (res != null && res.length > 0) {
        return res;
      } else {
        final response = await http.get(Uri.parse(url));
        storeToLocalStorage(response.body);
        print('Fetched From API');
        return decodeTrendingRepo(response.body);
      }
    } else {
      final response = await http.get(Uri.parse(url));
      storeToLocalStorage(response.body);
      print('Fetched From API');
      return decodeTrendingRepo(response.body);
    }
  } catch (e) {
    errorCallback!();
  }
  return [];
}

Future<List<TrendingRepo>> fetchFromLocalStorage() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? trendingRepoString = prefs.getString('trendingRepo');
  if (trendingRepoString != null) {
    print('Fetched From Local Storage');
    return decodeTrendingRepo(jsonDecode(trendingRepoString));
  }
  return [];
}

Future<void> storeToLocalStorage(response) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool result = await prefs.setString('trendingRepo', jsonEncode(response));
  print(result);
  print('Stored to Local Storage');
}

List<TrendingRepo> decodeTrendingRepo(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed
      .map<TrendingRepo>((json) => TrendingRepo.fromJson(json))
      .toList();
}

List<TrendingRepo> sortTrendingList(List<TrendingRepo> trendingRepo) {
  print(trendingRepo);
  trendingRepo.sort((TrendingRepo r1, TrendingRepo r2) {
    if(r1.language!=null && r2.language!=null){
      return (r1.language!).compareTo(r2.language!);
    }
    else if(r1.language == null)
      return 1;
    return -1;
  });

  return trendingRepo;
}
