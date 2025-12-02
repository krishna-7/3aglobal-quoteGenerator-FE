import 'package:json_annotation/json_annotation.dart';
import 'user_type.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  
  @JsonKey(name: 'user_type_id')
  final int userTypeId;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  
  @JsonKey(name: 'user_type')
  final UserType? userType;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.userTypeId,
    this.createdAt,
    this.updatedAt,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

