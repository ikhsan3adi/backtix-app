import 'package:dotenv/dotenv.dart';

class Constant {
  static String apiBaseUrl = DotEnv().getOrElse(
    'API_BASE_URL',
    () => 'http://localhost:3000/api/',
  );
}
