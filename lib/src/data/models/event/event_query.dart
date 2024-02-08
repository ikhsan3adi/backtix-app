import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_query.freezed.dart';
part 'event_query.g.dart';

@freezed
class EventQuery with _$EventQuery {
  const factory EventQuery({
    @Default(0) int? page,
    @Default(true) bool? byStartDate,
    DateTime? from,
    DateTime? to,
    String? search,
    String? location,
    List<String>? categories,
    @Default(false) bool? endedOnly,
    @Default(true) bool? ongoingOnly,
  }) = _EventQuery;

  factory EventQuery.fromJson(Map<String, dynamic> json) =>
      _$EventQueryFromJson(json);
}
