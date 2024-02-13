import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchases_by_event_model.freezed.dart';
part 'ticket_purchases_by_event_model.g.dart';

@freezed
class TicketPurchasesByEventModel with _$TicketPurchasesByEventModel {
  const TicketPurchasesByEventModel._();

  const factory TicketPurchasesByEventModel({
    required EventModel event,
    @Default([]) List<TicketPurchaseModel> purchases,
  }) = _TicketPurchasesByEvent;

  factory TicketPurchasesByEventModel.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchasesByEventModelFromJson(json);

  /// Convert [TicketPurchaseModel] list to [TicketPurchasesByEventModel] list,
  @Deprecated('Already changed on the backend')
  static List<TicketPurchasesByEventModel> groupPurchasesByEvent(
    List<TicketPurchaseModel> purchases,
  ) {
    final List<EventModel> events = purchases
        .where((e) => e.ticket?.event != null)
        .map((e) => e.ticket!.event!)
        .toSet()
        .toList();

    return events.map((event) {
      return TicketPurchasesByEventModel(
        event: event,
        purchases: purchases
            .where((e) => e.ticket?.event?.id == event.id)
            .map((e) => e.copyWith(ticket: e.ticket?.copyWith(event: null)))
            .toList(),
      );
    }).toList();
  }
}
