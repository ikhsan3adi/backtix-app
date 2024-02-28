import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

enum EventStatus {
  @JsonValue('DRAFT')
  draft,
  @JsonValue('PUBLISHED')
  published,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('REJECTED')
  rejected;

  @override
  String toString() => name
      .split('')
      .mapWithIndex((e, index) => index == 0 ? e.toUpperCase() : e)
      .join();
}
