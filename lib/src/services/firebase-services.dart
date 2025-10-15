import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:ica_app/src/cores/constants/constants.dart';
import 'package:ica_app/src/models/client_model.dart';
import 'package:ica_app/src/models/user_model.dart';
import 'package:ica_app/src/services/api_services.dart';

// Firebase Realtime Database Service
class FirebaseService {
  final Dio _dio = Dio();
 
  FirebaseService() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // Fetch all data from collection
  Future<List<ClientModel>> loadAllClient() async {
    try {
      const String url = '$firebaseUrl/.json?auth=$firebaseSecret';
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final Map<dynamic, dynamic> data = response.data ?? {};
        
        if (data.isEmpty) {
          return [];
        }

        List<ClientModel> clients = [];
        data.forEach((id, value) {
          if (value is Map<dynamic, dynamic>) {
            value.forEach((key,val) {
              clients.add(ClientModel.fromJson(key, val));
            });
          }
        });
        
        return clients;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Fetch single item by ID
  Future<bool> login(String userName, String password ) async {
    bool isLogin = false;
    try {
      const String url = '$firebaseUrl/.json?auth=$firebaseSecret';
      final response = await _dio.get(url);

      if (response.statusCode != 200 && response.data == null) {
        return isLogin;
      }
      response.data.forEach((id, value) {
        if (id == 'User') {
            if (value is Map<String, dynamic>) {
            value.forEach((key,val) {
              UserModel usr = UserModel.fromJson(key, val);
              if (userName == usr.userName && password == usr.password) {
                isLogin = true;
              }
            });
          }
        }
      });
      return isLogin;
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Add new data to collection
  Future<String> addData(Map<String, dynamic> data) async {
    try {
      const String url = '$firebaseUrl/.json?auth=$firebaseSecret';

      final response = await _dio.post(
        url,
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data['name']; // Firebase returns the new key
      } else {
        throw Exception('Failed to add data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding data: $e');
    }
  }

  // Update data by ID
  Future<void> updateData(String id, Map<String, dynamic> data) async {
    try {
      const String url = '$firebaseUrl/.json?auth=$firebaseSecret';

      final response = await _dio.patch(url, data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating data: $e');
    }
  }

  // Method 1: Add data with POST (auto-generated ID)
  Future<Map<String, dynamic>?> addUser(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$firebaseUrl/$collection.json?auth=$firebaseSecret');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Data added successfully');
        return jsonDecode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  // Delete data by ID
  Future<void> deleteData(String id) async {
    try {
      const String url = '$firebaseUrl/.json?auth=$firebaseSecret';

      final response = await _dio.delete(url);

      if (response.statusCode != 200) {
        throw Exception('Failed to delete data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting data: $e');
    }
  }
}
