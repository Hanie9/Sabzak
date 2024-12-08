// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:plant_app/const/constants.dart';
// import 'package:plant_app/models/login.dart';
// import 'package:plant_app/models/plant.dart';
// import 'package:plant_app/models/sign_up.dart';


// class APIService {

//   Future<bool> createCustomer(CustomerModel model) async {
//     bool returnResponse = false;

//     try {
//       Response response = await Dio().post(
//         Serverinfo.baseURL + Serverinfo.createuserURL,
//         data: model.tojson(),
//         options: Options(
//           headers: {
//             HttpHeaders.contentTypeHeader: 'application/json',
//           }
//         )
//       );
//       if (response.statusCode == 201){
//         returnResponse = true;
//       }
//     } on DioException catch (e) {
//       if (e.response!.statusCode == 404) {
//         returnResponse = false;
//       } else {
//         returnResponse = false;
//       }
//     }
//     return returnResponse;
//   }



//   Future<LoginResponseModel> logincustomer(
//     String username,
//     String password,
//   ) async {
//     try {
//       Response response = await Dio().post(
//         Serverinfo.baseURL + Serverinfo.loginuserURL,
//         data: {
//           'username' : username,
//           'password' : password,
//         },
//         options: Options(
//           headers: {
//             HttpHeaders.contentTypeHeader : 'application/json',
//           }
//         )
//       );
//       if(response.statusCode == 200){
//         return LoginResponseModel.fromJson(response.data);
//       } else {
//         return LoginResponseModel(message: response.toString());
//       }
//     } catch (e) {
//       if(e is DioException){
//         if(e.response?.data == null){
//         return LoginResponseModel(message: 'هیچ داده ای دریافت نشد');
//       }
//       return LoginResponseModel.fromJson(e.response?.data);
//       } else {
//         return LoginResponseModel(message: e.toString());
//       }
//     }
//   }

  

//   Future<List<Plant>> getPlants() async {
//     final String plantURL = "${Serverinfo.baseURL}${Serverinfo.plantURL}";
//     List<Plant> plantList = <Plant>[];

//     try {
//       Response response = await Dio().get(
//         plantURL,
//         options: Options(
//           headers: {
//             HttpHeaders.contentTypeHeader: 'application/json',
//           }
//         )
//       );
//       if(response.statusCode == 200){
//         plantList = (response.data as List).map((i) => Plant.fromJson(i),).toList();
//       }
//     } on DioException catch (e) {
//       throw 'Error $e';
//     }
//     return plantList;
//   }

// }

import 'package:dio/dio.dart';
import 'package:plant_app/models/plant.dart';

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

}