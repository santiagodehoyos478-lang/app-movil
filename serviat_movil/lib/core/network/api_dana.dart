class ApiDanaClient {
  ApiDanaClient._();

  static const String baseUrl = 'http://10.0.2.2:3001/api';

  static String endpoint(String path) {
    return '$baseUrl/$path';
  }
}