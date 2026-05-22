import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ExploreScreen extends StatefulWidget {
  final String city;
  final String tripId; // add this so you can save to itinerary

  const ExploreScreen({super.key, required this.city, required this.tripId});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  LatLng? _location;
  String? _placeName;
  List<Map<String, dynamic>> _attractions = [];
  bool _loading = true;
  String? _error;

  static const String _foursquareApiKey = 'fsq3IiQqVHpJhwZeL+M1vmHSgUgyQJvcdvcxz4RNAzgxrbM=';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndAttractions();
  }

  Future<void> _fetchLocationAndAttractions() async {
    try {
      final query = Uri.encodeComponent(widget.city.replaceAll('_', ' '));
        final url = Uri.parse(
        'https://places-api.foursquare.com/places/search?query=$query&limit=1',
      );

        final res = await http.get(
        url,
        headers: {
          'Authorization': _foursquareApiKey,
          'Accept': 'application/json',
          'X-Places-Api-Version': '2025-06-17',
        },
      );

      if (res.statusCode!= 200) {
        throw Exception('Foursquare API error: ${res.statusCode} ${res.body}');
      }

      final data = jsonDecode(res.body);
      final results = data['results'] as List;

      if (results.isEmpty) {
        setState(() {
          _error = 'Location not found for "$query"';
          _loading = false;
        });
        return;
      }

      final place = results[0];
      final lat = (place['geocodes']['main']['latitude'] as num).toDouble();
      final lng = (place['geocodes']['main']['longitude'] as num).toDouble();
      final name = place['name'] as String;

      setState(() {
        _location = LatLng(lat, lng);
        _placeName = name;
      });

      // Now fetch attractions near this location
      await _fetchAttractions(lat, lng);

    } catch (e) {
      setState(() {
        _error = 'Failed to load location: $e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchAttractions(double lat, double lon) async {
    final url = Uri.parse(
      'https://places-api.foursquare.com/places/search?ll=$lat,$lon&radius=5000&categories=13000,16000,10000&limit=20',
    );

    final res = await http.get(
      url,
      headers: {
        'Authorization': _foursquareApiKey,
        'Accept': 'application/json',
        'X-Places-Api-Version': '2025-06-17',
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final results = data['results'] as List;

      setState(() {
        _attractions = results.map((e) => {
          'fsq_id': e['fsq_id'],
          'name': e['name'],
          'category': e['categories'].isNotEmpty? e['categories'][0]['name'] : 'Place',
          'address': e['location']['formatted_address']?? '',
          'lat': e['geocodes']['main']['latitude'],
          'lon': e['geocodes']['main']['longitude'],
          'rating': e['rating']?? 0,
        }).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore ${widget.city.replaceAll('_',' ')}'),
        backgroundColor: const Color(0xFF151B2D),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
      );
    }

    if (_error!= null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        // Map on top
        SizedBox(
          height: 250,
          child: FlutterMap(
            options: MapOptions(
              initialCenter: _location!,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourapp.name',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _location!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Attractions list below
        Expanded(
          child: ListView.builder(
            itemCount: _attractions.length,
            itemBuilder: (_, i) {
              final a = _attractions[i];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.place, color: Colors.white),
                ),
                title: Text(
                  a['name'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['category'], style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                    Text(a['address'], style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Color(0xFF6C5CE7), size: 28),
                  onPressed: () => _addToItinerary(a),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addToItinerary(Map<String, dynamic> place) {
    // Call your TripService here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${place['name']} added to itinerary')),
    );
  }
}