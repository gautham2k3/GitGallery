import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NetworkService {
  final Dio _dio = Dio();
  final String _cacheKey = 'cachedImages';

  Future<List<dynamic>> fetchImages({bool forceRefresh = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && prefs.containsKey(_cacheKey)) {
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }
    }

    try {
      final response = await _dio.get(
        'https://api.unsplash.com/photos/random?client_id=-Ij_nxM7LdSM0klz9YHTnvRfheadUSSJFls2z_OB1U4&count=10'
      );
      if (response.statusCode == 200) {
        prefs.setString(_cacheKey, json.encode(response.data));
      }
      return response.data;
    } catch (e) {
      print('Error fetching images: $e');
      rethrow;
    }
  }

  Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
