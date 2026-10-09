import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get backendBaseUrl =>
      dotenv.env['BACKEND_BASE_URL'] ?? '';

  static String get razorpayKeyId =>
      dotenv.env['RAZORPAY_KEY_ID'] ?? '';

  static String get googleMapsApiKey =>
      dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}