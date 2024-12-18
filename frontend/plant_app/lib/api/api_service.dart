import 'package:dio/dio.dart';
import 'package:plant_app/models/cart_model.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/models/users_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://45.156.23.34:8000'));

  Future<List<String>> fetchImages() async {
    try {
      final response = await _dio.get('/images');
      if (response.statusCode == 200) {
        final List<dynamic> imageList = response.data['images'];
        return imageList.map((image) => image.toString()).toList();
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      throw Exception('Error fetching images: $e');
    }
  }

  Future<String> fetchPlantImage(int plantId) async {
    try {
      final response = await _dio.get('/images/$plantId.png');
      if (response.statusCode == 200) {
        return response.requestOptions.uri.toString();
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      throw Exception('Error fetching plant image: $e');
    }
  }

  Future<List<Plant>> fetchPlants() async {
    try {
      final response = await _dio.get('/plants');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        return responseData.map((data) => Plant.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load plants');
      }
    } catch (e) {
      throw Exception('Error fetching plants: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String username, String email, String password, String firstName, String lastName) async {
    try {
      final response = await _dio.post('/sign_up', data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        print('Signup error: ${e.response?.data}');
        if (e.response?.data == null) {
          return {'error': 'No data received'};
        }
        return e.response?.data as Map<String, dynamic>;
      } else {
        print('Unexpected error: $e');
        return {'error': e.toString()};
      }
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is DioException) {
        print('Login error: ${e.response?.data}');
        if (e.response?.data == null) {
          return {'error': 'No data received'};
        }
        return e.response?.data as Map<String, dynamic>;
      } else {
        print('Unexpected error: $e');
        return {'error': e.toString()};
      }
    }
  }

  Future<List<Users>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      final response = await _dio.get(
        '/users',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
      return (response.data as List).map((user) => Users.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<bool> isAdmin(String sessionId) async {
    try {
      final response = await _dio.get('/is_admin/$sessionId');
      if (response.statusCode == 200) {
        return response.data as bool;
      } else {
        throw Exception('Failed to check admin status');
      }
    } catch (e) {
      throw Exception('Error checking admin status: $e');
    }
  }

  Future<void> saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
  }

  Future<String?> getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }

  Future<void> addToCart(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.post(
        '/cart/add/$plantId',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
    } catch (e) {
      throw Exception('Error adding to cart: $e');
    }
  }

  Future<void> deleteCartItem(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.delete(
        '/cart/delete/$plantId',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
    } catch (e) {
      throw Exception('Error deleting cart item: $e');
    }
  }

  Future<List<CartItem>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      final response = await _dio.get(
        '/cart',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
      return (response.data as List).map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Error fetching cart items: $e');
    }
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.delete(
        '/cart/clear',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
    } catch (e) {
      throw Exception('Error clearing cart: $e');
    }
  }

  Future<void> increaseQuantity(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.post(
        '/cart/increase_quantity?plant_id=$plantId',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
    } catch (e) {
      throw Exception('Error increasing quantity: $e');
    }
  }

  Future<void> decreaseQuantity(int plantId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.post(
        '/cart/decrease_quantity?plant_id=$plantId',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
    } catch (e) {
      throw Exception('Error decreasing quantity: $e');
    }
  }

}