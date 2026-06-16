import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

class ApiService {
  static const String url = 'https://jsonplaceholder.typicode.com/users';

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 200 OK means the server responded successfully
        List<dynamic> body = jsonDecode(response.body);
        List<User> users = body.map((dynamic item) => User.fromJson(item)).toList();
        return users;
      } else {
        // Handle server errors (e.g., 404, 500)
        throw Exception('Server Error: Status Code ${response.statusCode}');
      }
    } catch (e) {
      // Handle network timeouts or lack of internet connection
      throw Exception('Failed to load users. Check your internet connection.');
    }
  }
}