class ClientModel {
  final String id;
  final String name;
  final String code;
  final String address;
  final String phoneNumber;
  final String taxCode;
  final bool isActive;


  ClientModel({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.phoneNumber,
    required this.taxCode,
    required this.isActive
  });

  factory ClientModel.fromJson(String id, Map<dynamic, dynamic> json) {
    return ClientModel(
      id: id,
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
      address: json['Address'] ?? '',
      phoneNumber: json['Phone'] ?? '',
      taxCode: json['TaxCode'] ?? '',
      isActive: json['IsActive'] ?? true,
    );
  }
}