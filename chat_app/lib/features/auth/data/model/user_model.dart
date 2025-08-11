// lib/data/models/user_model.dart
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String name,
    required String email,
  }) : super(id: id, name: name, email: email);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dynamicId = json['_id'] ?? json['id'];
    return UserModel(
      id: dynamicId?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}