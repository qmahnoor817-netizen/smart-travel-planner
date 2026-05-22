import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  static const String fsqKey = 'fsq3wFJehl8ADRfFPn+JovKaFbd36oNgMTCzb6lg5SW+jZ0=';
  static const String weatherKey = 'fe22a49d3bf41def0c819211a114aa50';

  Map<String, String> get _fsqHeaders => {
    'Authorization': fsqKey,
    'Accept': 'application/json',
  };

  // Search cities - keep using OpenWeather for this, Foursquare doesn't do it well
  Future<List<String>> searchCities(String query) async {
    final url = 'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$weatherKey';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode!= 200) return [];
    final List data = json.decode(res.body);
    return data.map((e) => '${e['name']}, ${e['country']}').toList();
  }

  // 1. Get attractions for city using Foursquare
  Future<List<Map<String, dynamic>>> getAttractions(String city) async {
    // First get lat/lon from city name
    final geoUrl = 'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$weatherKey';
    final geoRes = await http.get(Uri.parse(geoUrl));
    if (geoRes.statusCode!= 200) return [];
    final geo = json.decode(geoRes.body)[0];
    final lat = geo['lat'];
    final lon = geo['lon'];

    // Foursquare Places Search
    final url = 'https://api.foursquare.com/v3/places/search'
        '?ll=$lat,$lon'
        '&radius=5000'
        '&categories=13000,16000,10000' // arts, outdoors, food
        '&limit=20'
        '&sort=POPULARITY';

    final res = await http.get(Uri.parse(url), headers: _fsqHeaders);
    if (res.statusCode!= 200) return [];

    final List results = json.decode(res.body)['results'];
    return results.map((e) => {
      'fsq_id': e['fsq_id'],
      'name': e['name'],
      'category': e['categories'].isNotEmpty? e['categories'][0]['name'] : 'Place',
      'address': e['location']['formatted_address']?? '',
      'lat': e['geocodes']['main']['latitude'],
      'lon': e['geocodes']['main']['longitude'],
      'rating': e['rating']?? 0,
    }).toList();
  }

  // 2. Get nearby places
  Future<List<Map<String, dynamic>>> getNearby(double lat, double lon) async {
    final url = 'https://api.foursquare.com/v3/places/nearby'
        '?ll=$lat,$lon'
        '&radius=2000'
        '&limit=15';

    final res = await http.get(Uri.parse(url), headers: _fsqHeaders);
    if (res.statusCode!= 200) return [];

    final List results = json.decode(res.body)['results'];
    return results.map((e) => {
      'fsq_id': e['fsq_id'],
      'name': e['name'],
      'category': e['categories'].isNotEmpty? e['categories'][0]['name'] : 'Place',
      'address': e['location']['formatted_address']?? '',
    }).toList();
  }

  // 3. Get place details + photo
  Future<Map<String, dynamic>> getPlaceDetails(String fsqId) async {
    final url = 'https://api.foursquare.com/v3/places/$fsqId?fields=name,rating,location,photos,hours,description';
    final res = await http.get(Uri.parse(url), headers: _fsqHeaders);
    if (res.statusCode!= 200) return {};

    final data = json.decode(res.body);
    String photoUrl = '';
    if (data['photos']!= null && data['photos'].isNotEmpty) {
      final p = data['photos'][0];
      photoUrl = '${p['prefix']}300x300${p['suffix']}';
    }

    return {
      'name': data['name'],
      'rating': data['rating'],
      'address': data['location']['formatted_address'],
      'photo': photoUrl,
      'hours': data['hours']?['display'],
      'description': data['description'],
    };
  }

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$weatherKey&units=metric');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body);
    return {};
  }

  Future<int?> getTempForDate(String city, DateTime date) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$weatherKey&units=metric');
    final res = await http.get(url);
    if (res.statusCode!= 200) return null;

    final data = jsonDecode(res.body);
    final targetDate = DateFormat('yyyy-MM-dd').format(date);

    for (var item in data['list']) {
      if (item['dt_txt'].startsWith(targetDate)) {
        return (item['main']['temp'] as num).round();
      }
    }
    return null;
  }
}