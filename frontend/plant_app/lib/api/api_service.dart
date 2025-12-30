import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plant_app/models/cart_model.dart';
import 'package:plant_app/models/plant.dart';
import 'package:plant_app/models/rating.dart';
import 'package:plant_app/models/users_model.dart';
import 'package:plant_app/screens/zarinpal/zarinpal_request_model.dart';
import 'package:plant_app/screens/zarinpal/zarinpal_verify_model.dart';
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

  Future<List<Plant>> fetchPlants(
      {String query = '', String category = ''}) async {
    try {
      final response = await _dio.get('/plants_new',
          queryParameters: {'query': query, 'category': category});
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

  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final List<dynamic> responseData = response.data;
        return responseData.map((data) => Category.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<void> deletePlant(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      await _dio.delete(
        '/plants/$id',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
      fetchPlants();
    } catch (e) {
      throw Exception('Error deleting plant: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String username, String email,
      String password, String firstName, String lastName) async {
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
      return (response.data as List)
          .map((user) => Users.fromJson(user))
          .toList();
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<Users> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    try {
      final response = await _dio.get(
        '/user',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        return Users.fromJson(responseData);
      } else {
        throw Exception('Failed to load user profile');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  Future<String> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get(
        '/profile',
        options: Options(
          headers: {
            'session_id': sessionId,
          },
        ),
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
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

  Future<void> clearSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(sessionId);
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
      return (response.data as List)
          .map((item) => CartItem.fromJson(item))
          .toList();
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

  Future<ZarinpalRequest?> getAuthority(String amount) async {
    // String amountToRial = '${amount}0';
    ZarinpalRequest? zarinpalRequestModel;

    try {
      String url = '';
      // ${zarinpalInfo.zarinpalRequestURL}?merchant_id=${zarinpalInfo.zarinpalMerchID}&amount=$amountToRial&description=پرداخت از طریق اپلیکیشن فلاتر&callback_url=${zarinpalInfo.zarinpalCallURL}
      Response response = await Dio().post(url,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          }));
      if (response.statusCode == 200) {
        zarinpalRequestModel = ZarinpalRequest.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw 'Error $e';
    }
    return zarinpalRequestModel;
  }

  Future<ZarinpalVerify?> verifyPayment(int? amount, String authority) async {
    // String amountToRial = '${amount}0';
    ZarinpalVerify? zarinpalVerifyModel;

    try {
      String url = '';
      // ${zarinpalInfo.zarinpalVerifyURL}?merchant_id=${zarinpalInfo.zarinpalMerchID}&amount=$amountToRial$authority=$authority
      Response response = await Dio().post(url,
          options: Options(headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          }));
      if (response.statusCode == 200) {
        zarinpalVerifyModel = ZarinpalVerify.fromJson(response.data);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data == null) {
          return ZarinpalVerify(errors: 'هیچ داده ای دریافت نشد');
        }
        return ZarinpalVerify.fromJson(e.response?.data);
      } else {
        return ZarinpalVerify(errors: e.toString());
      }
    }
    return zarinpalVerifyModel;
  }

  Future<void> ratePlant(Rating rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.post(
        '/rate_plant',
        options: Options(headers: {'session_id': sessionId}),
        data: {
          'rating': rating.rating,
          'plant_id': rating.plantId,
          'reaction': rating.reaction,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to submit rating');
      }
    } on DioException catch (e) {
      throw Exception('Failed to submit rating: $e');
    }
  }

  Future<Map<String, dynamic>> getRatings(int plantId) async {
    try {
      final response = await _dio.get('/ratings/$plantId');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load ratings');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load ratings: $e');
    }
  }

  Future<String> getUsersUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get(
        '/users_username',
        options: Options(headers: {'session_id': sessionId}),
      );
      if (response.statusCode == 200) {
        return response.data['username'];
      } else {
        throw Exception('Failed to load username');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load username: $e');
    }
  }

  Future<Map<String, String>?> fetchAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get('/checkout',
          options: Options(headers: {"session_id": sessionId}));
      if (response.statusCode == 200) {
        return response.data.cast<String, String>();
      } else {
        throw Exception('Failed to fetch address');
      }
    } catch (e) {
      throw Exception('Error fetching address: ${e.toString()}');
    }
  }

  Future<void> addNotification(
      String notification, String notificationTitle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      await _dio.post(
        '/notification',
        data: {
          'notification': notification,
          'notification_title': notificationTitle
        },
        options: Options(headers: {'session_id': sessionId}),
      );
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('/get_notifications');
      final List<Map<String, dynamic>> notifications =
          List<Map<String, dynamic>>.from(response.data);
      return notifications;
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      await _dio.delete(
        '/delete_notification',
        options: Options(headers: {'session_id': sessionId}),
        queryParameters: {'notification_id': notificationId},
      );
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  Future<String> backupDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');

      final response = await _dio.post(
        '/database/backup',
        options: Options(
          headers: {'session_id': sessionId},
          responseType: ResponseType.bytes,
        ),
      );

      // Save file to downloads or documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/database_backup_$timestamp.sql';
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      return filePath;
    } catch (e) {
      throw Exception('Failed to backup database: $e');
    }
  }

  Future<void> restoreDatabase(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');

      final fileName = filePath.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      await _dio.post(
        '/database/restore',
        data: formData,
        options: Options(
          headers: {'session_id': sessionId},
        ),
      );
    } catch (e) {
      throw Exception('Failed to restore database: $e');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      await _dio.post(
        '/change_password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'session_id': sessionId},
        ),
      );
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  Future<void> createUserByAdmin({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      await _dio.post(
        '/admin/create_user',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'username': username,
          'email': email,
          'password': password,
          'isAdmin': isAdmin,
        },
        options: Options(
          headers: {'session_id': sessionId},
        ),
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSalesReport(
      {String? startDate, String? endDate}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get(
        '/reports/sales',
        options: Options(
          headers: {'session_id': sessionId},
        ),
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get sales report: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPlantSalesReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get(
        '/reports/plant_sales',
        options: Options(
          headers: {'session_id': sessionId},
        ),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get plant sales report: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserActivityReport() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString('session_id');
      final response = await _dio.get(
        '/reports/user_activity',
        options: Options(
          headers: {'session_id': sessionId},
        ),
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get user activity report: $e');
    }
  }
}
