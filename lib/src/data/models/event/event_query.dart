import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_query.freezed.dart';
part 'event_query.g.dart';

@freezed
class EventQuery with _$EventQuery {
  const factory EventQuery({
    EventStatus? status,
    @Default(0) int page,
    @Default(true) bool byStartDate,
    DateTime? from,
    DateTime? to,
    String? search,
    String? location,
    @Default([]) List<String> categories,
    @Default(false) bool endedOnly,
    @Default(true) bool ongoingOnly,
  }) = _EventQuery;

  factory EventQuery.fromJson(Map<String, dynamic> json) =>
      _$EventQueryFromJson(json);
}
