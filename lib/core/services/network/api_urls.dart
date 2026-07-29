import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../constants/app_keys.dart';

/// Contains all API endpoint URLs and base configuration.
class ApiUrl {

  /// BASE URL
  static String baseUrl =
      dotenv.env[AppKeys.prodBaseUrl] ?? "";
}
