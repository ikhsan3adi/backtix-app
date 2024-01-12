import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constant {
  static String apiBaseUrl = dotenv.env['API_BASE_URL']!;

  static String googleClientId = dotenv.env['GOOGLE_CLIENT_ID']!;
  static String googleServerClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID']!;
}
