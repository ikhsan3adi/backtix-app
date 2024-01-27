import 'package:backtix_app/src/data/models/event/event_image_model.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const factory EventModel({
    required String id,
    required String name,
    required DateTime date,
    DateTime? endDate,
    required String location,
    double? latitude,
    double? longitude,
    required String description,
    @Default(EventStatus.draft) EventStatus status,
    @Default(false) bool ticketAvailable,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    required List<EventImageModel> images,
    List<TicketModel>? tickets,
  }) = _EventModel;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}
