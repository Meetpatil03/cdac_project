import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<List<LatLng>> getRouteCoordinates(LatLng start, LatLng end) async {
  const String apiKey = '5b3ce3597851110001cf6248867ed5d02fc6452f901289c4aef60a13'; // Ensure this is your valid API key
  const String url = 'https://api.openrouteservice.org/v2/directions/driving-car/geojson';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': "apiKey",
      },
      body: jsonEncode({
        'coordinates': [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude]
        ]
      }),
    );

    // Log the status code and response body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data['features'][0]['geometry']['coordinates']);

      // Check if 'routes' is available and extract the coordinates from 'geometry'
      if (data['features'] != null && data['features'][0]['geometry']['coordinates'].isNotEmpty) {
        final List<dynamic> coordinates = data['features'][0]['geometry']['coordinates'];

        // Convert the coordinates to a list of LatLng objects
        return coordinates
            .map<LatLng>((coordinate) =>
                LatLng(coordinate[1], coordinate[0])) // Longitude is first, then Latitude
            .toList();
      } else {
        throw Exception('No routes found in the response.');
      }
    } else {
      print('Failed to fetch route from OpenRouteService: ${response.statusCode}');
      throw Exception('Failed to fetch route from OpenRouteService');
    }
  } catch (e) {
    print('Exception caught: $e');
    throw Exception('Failed to fetch route from OpenRouteService');
  }
}
