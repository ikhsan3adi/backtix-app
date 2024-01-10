import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

@freezed
class TicketModel with _$TicketModel {
  const factory TicketModel({
    required String id,
    required String name,
    required num price,
    required int stock,
    String? image,
    required DateTime salesOpenDate,
    required DateTime purchaseDeadline,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TicketModel;

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);
}
