import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather_model.dart';

class WeatherServices {
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  final String apiKey;

  WeatherServices() : apiKey = dotenv.env['API_KEY']!;

  /// Fetch weather by city name
  Future<Weather> getWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('$baseUrl?q=$cityName&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  /// Get the current city name using device GPS
  Future<String> getCurrentCity() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    return placemarks.first.locality ?? 'Unknown';
  }
}
