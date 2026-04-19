import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterproject/models/api_coffee_model.dart';

class CoffeeService {
  static const String hotUrl = 'https://api.sampleapis.com/coffee/hot';
  static const String icedUrl = 'https://api.sampleapis.com/coffee/iced';

  Future<List<ApiCoffee>> fetchAllCoffee() async {
    final hotResponse = await http.get(Uri.parse(hotUrl));
    final icedResponse = await http.get(Uri.parse(icedUrl));

    if (hotResponse.statusCode == 200 && icedResponse.statusCode == 200) {
      final List hotData = jsonDecode(hotResponse.body);
      final List icedData = jsonDecode(icedResponse.body);

      final hotList = hotData
          .map((item) => ApiCoffee.fromJson(item, isHot: true))
          .toList();

      final icedList = icedData
          .map((item) => ApiCoffee.fromJson(item, isHot: false))
          .toList();

      return [...hotList, ...icedList];
    } else {
      throw Exception('Kahve verileri alınamadı');
    }
  }
}