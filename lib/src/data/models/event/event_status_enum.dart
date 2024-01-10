import 'package:freezed_annotation/freezed_annotation.dart';

enum EventStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REJECTED')
  rejected
}
