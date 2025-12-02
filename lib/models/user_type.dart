import 'package:json_annotation/json_annotation.dart';

part 'user_type.g.dart';

@JsonSerializable()
class UserType {
  final int id;
  final String name;
  final String? description;
  
  @JsonKey(name: 'created_at')
  final String? createdAt;
  
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  UserType({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory UserType.fromJson(Map<String, dynamic> json) =>
      _$UserTypeFromJson(json);

  Map<String, dynamic> toJson() => _$UserTypeToJson(this);
}

