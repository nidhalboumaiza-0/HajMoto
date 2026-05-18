import 'package:equatable/equatable.dart';

/// Client Entity - Domain Layer
/// Represents a client who makes a purchase
/// Client info is captured during each sale for invoice generation
class ClientEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String cin; // National ID number
  final DateTime createdAt;

  const ClientEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.cin,
    required this.createdAt,
  });

  /// Full name helper
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, firstName, lastName, mobileNumber, cin, createdAt];
}
