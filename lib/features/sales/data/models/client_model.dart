import 'package:gestion_stock/features/sales/domain/entities/client_entity.dart';

/// Client Model - Data Layer
class ClientModel extends ClientEntity {
  const ClientModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.mobileNumber,
    required super.cin,
    required super.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      mobileNumber: json['mobile_number'] as String,
      cin: json['cin'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'mobile_number': mobileNumber,
      'cin': cin,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      mobileNumber: entity.mobileNumber,
      cin: entity.cin,
      createdAt: entity.createdAt,
    );
  }
}
