import 'package:backtix_app/src/data/models/notification/notification_entity_type_enum.dart';
import 'package:backtix_app/src/data/models/notification/notification_type_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required int id,
    String? userId,
    required String message,
    required NotificationType type,
    NotificationEntityType? entityType,
    String? entityId,
    @Default([]) List<NotificationRead> reads,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationModel;

  bool get isRead => reads.isNotEmpty ? reads[0].isRead : false;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}

@freezed
class NotificationRead with _$NotificationRead {
  const factory NotificationRead({
    required int id,
    required String userId,
    required int notificationId,
    @Default(false) bool isRead,
  }) = _NotificationRead;

  factory NotificationRead.fromJson(Map<String, dynamic> json) =>
      _$NotificationReadFromJson(json);
}
