// ==================== 3. EXAMPLE USER SERVICE ====================
// lib/services/user_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ica_app/src/services/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();
  
  // Get all users
  Future<ApiResponse<List<User>>> getUsers() async {
    try {
      final response = await _apiClient.get('/users');
      
      final users = (response.data['data'] as List)
          .map((json) => User.fromJson(json))
          .toList();
      
      return ApiResponse.success(data: users);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Get user by ID
  Future<ApiResponse<User>> getUserById(int id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      
      final user = User.fromJson(response.data['data']);
      
      return ApiResponse.success(data: user);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Create user
  Future<ApiResponse<User>> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post(
        '/users',
        data: userData,
      );
      
      final user = User.fromJson(response.data['data']);
      
      return ApiResponse.success(
        data: user,
        message: 'User created successfully',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Update user
  Future<ApiResponse<User>> updateUser(
    int id,
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _apiClient.put(
        '/users/$id',
        data: userData,
      );
      
      final user = User.fromJson(response.data['data']);
      
      return ApiResponse.success(
        data: user,
        message: 'User updated successfully',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Delete user
  Future<ApiResponse<void>> deleteUser(int id) async {
    try {
      await _apiClient.delete('/users/$id');
      
      return ApiResponse.success(message: 'User deleted successfully');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  // Upload avatar
  Future<ApiResponse<String>> uploadAvatar(
    int userId,
    String filePath,
    Function(int, int)? onProgress,
  ) async {
    try {
      final response = await _apiClient.uploadFile(
        '/users/$userId/avatar',
        filePath,
        fieldName: 'avatar',
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
        },
      );
      
      final avatarUrl = response.data['data']['avatar_url'];
      
      return ApiResponse.success(
        data: avatarUrl,
        message: 'Avatar uploaded successfully',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
  
  String _handleError(DioException error) {
    String errorMessage = 'Something went wrong';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = error.response?.data['message'] ?? 'Server error';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'No internet connection';
        break;
      default:
        errorMessage = 'Unexpected error occurred';
    }
    
    return errorMessage;
  }
}

// ==================== 4. USER MODEL ====================
// lib/models/user.dart

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
    };
  }
}


class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);
  
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    
    final response = await _userService.getUsers();
    
    if (response.success && response.data != null) {
      setState(() {
        _users = response.data!;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Error loading users')),
      );
    }
  }
  
  Future<void> _createUser() async {
    final userData = {
      'name': 'John Doe',
      'email': 'john@example.com',
    };
    
    final response = await _userService.createUser(userData);
    
    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'User created')),
      );
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? 'Error creating user')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    child: user.avatar == null
                        ? Text(user.name[0])
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createUser,
        child: Icon(Icons.add),
      ),
    );
  }
}