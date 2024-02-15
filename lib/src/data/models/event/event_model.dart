import 'package:backtix_app/src/data/models/event/event_image_model.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_model.freezed.dart';
part 'event_model.g.dart';

@freezed
class EventModel with _$EventModel {
  const EventModel._();

  const factory EventModel({
    required String id,
    required String name,
    required String description,
    required DateTime date,
    DateTime? endDate,
    required String location,
    double? latitude,
    double? longitude,
    @Default(EventStatus.draft) EventStatus status,
    @Default(false) bool ticketAvailable,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    @Default([]) List<EventImageModel> images,
    List<TicketModel>? tickets,
    UserModel? user,
  }) = _EventModel;

  bool get isOnGoing {
    return isEnded ? false : date.toLocal().isBefore(DateTime.now().toLocal());
  }

  bool get isEnded {
    return endDate?.toLocal().isBefore(DateTime.now().toLocal()) ?? false;
  }

  bool get isLatLongSet => latitude != null && longitude != null;

  factory EventModel.fromJson(Map<String, dynamic> json) =>
      _$EventModelFromJson(json);
}
