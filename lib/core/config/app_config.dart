import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Runtime configuration loaded from `.env` via `flutter_dotenv`.
///
/// Setup:
/// 1. `cp .env.example .env`
/// 2. Edit `.env` with your values
/// 3. `flutter run`
class AppConfig {
  AppConfig._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      await dotenv.load(fileName: '.env.example');
    }
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL']?.trim().isNotEmpty == true
          ? dotenv.env['API_BASE_URL']!.trim()
          : 'http://10.0.2.2:3000';

  static String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID']?.trim() ?? '';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY']?.trim() ?? '';

  static const Duration httpTimeout = Duration(seconds: 30);
  static const String apiPrefix = '/api/v1';
}
