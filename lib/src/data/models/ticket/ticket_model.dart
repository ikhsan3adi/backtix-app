import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_model.freezed.dart';
part 'ticket_model.g.dart';

enum TicketStatus {
  notOpenedYet,
  available,
  soldOut,
  closed;

  @override
  String toString() => switch (this) {
        TicketStatus.notOpenedYet => 'Coming soon',
        TicketStatus.available => 'Available',
        TicketStatus.soldOut => 'Sold out',
        TicketStatus.closed => 'Closed',
      };
}

@freezed
class TicketModel with _$TicketModel {
  const TicketModel._();

  const factory TicketModel({
    required String id,
    required String name,
    required num price,
    required int stock,
    required int currentStock,
    String? image,
    required DateTime salesOpenDate,
    required DateTime purchaseDeadline,
    required DateTime createdAt,
    DateTime? updatedAt,
    EventModel? event,
  }) = _TicketModel;

  TicketStatus get status {
    if (salesOpenDate.toLocal().isAfter(DateTime.now().toLocal())) {
      return TicketStatus.notOpenedYet;
    } else if (purchaseDeadline.toLocal().isBefore(DateTime.now().toLocal())) {
      return TicketStatus.closed;
    } else if (currentStock <= 0) {
      return TicketStatus.soldOut;
    }
    return TicketStatus.available;
  }

  factory TicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketModelFromJson(json);
}
