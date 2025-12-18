import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_services.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherServices _weatherServices = WeatherServices();

  Weather? _weather;
  String? _cityName;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Get current city from device location
      final city = await _weatherServices.getCurrentCity();
      final weather = await _weatherServices.getWeather(city);

      setState(() {
        _cityName = city;
        _weather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/Weather-windy.json';

    switch (mainCondition.toLowerCase()) {
      case 'clear':
        return 'assets/Weather-sunny.json';
      case 'clouds':
      case 'smoke':
      case 'mist':
      case 'haze':
      case 'fog':
      case 'dust':
        return 'assets/Weather-windy.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/Rainy.json';
      case 'thunderstorm':
        return 'assets/Weather-storm.json';
      default:
        return 'assets/Weather-sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_cityName ?? 'Weather')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weather?.cityName ?? 'Loading city...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Lottie.asset(
              _getWeatherAnimation(_weather?.mainCondition),
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              '${_weather?.temperature.round() ?? 0} °C',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _weather?.mainCondition ?? 'Loading condition...',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
