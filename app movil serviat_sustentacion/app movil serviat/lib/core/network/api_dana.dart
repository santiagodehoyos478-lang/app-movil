class ApiDanaClient {
  ApiDanaClient._();

  static const String baseUrl = 'http://192.168.20.160/api';

  static String endpoint(String path) {
    return '$baseUrl/$path';
  }
}