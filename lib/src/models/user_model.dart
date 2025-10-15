class UserModel {
  final String id;
  final String userName;
  final String password;
  final String name;
  final String role;
  final String address;
  final String phoneNumber;
  final String createTime;
  final String updateTime;
  final bool isActive;


  UserModel({
    required this.id,
    required this.userName,
    required this.password,
    required this.name,
    required this.role,
    required this.address,
    required this.phoneNumber,
    required this.createTime, 
    required this.updateTime,
    required this.isActive
  });

  factory UserModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return UserModel(
      id: id,
      userName: json['UserName'] ?? '',
      password: json['Password'] ?? '',
      name: json['Name'] ?? '',
      role: json['Role'] ?? '',
      address: json['Address'] ?? '',
      phoneNumber: json['Phone'] ?? '',
      createTime: json['CreateTime'] ?? '',
      updateTime: json['UpdateTime'] ?? '',
      isActive: json['IsActive'] ?? true,
    );
  }
}