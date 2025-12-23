import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import '../constant/api_constant.dart';

class UserService {
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> fetchUser() async {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('No token found');

    final response = await ApiService.get(ApiConstants.users, token: token);
    return response;
  }
}
