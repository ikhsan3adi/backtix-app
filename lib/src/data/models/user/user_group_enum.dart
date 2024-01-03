import 'package:freezed_annotation/freezed_annotation.dart';

enum UserGroup {
  @JsonValue('USER')
  user,
  @JsonValue('ADMIN')
  admin,
  @JsonValue('SUPERADMIN')
  superadmin,
}
