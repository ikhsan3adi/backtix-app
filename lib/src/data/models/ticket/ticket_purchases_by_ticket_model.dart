import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchases_by_ticket_model.freezed.dart';
part 'ticket_purchases_by_ticket_model.g.dart';

@freezed
class TicketPurchasesByTicketModel with _$TicketPurchasesByTicketModel {
  const TicketPurchasesByTicketModel._();

  const factory TicketPurchasesByTicketModel({
    required TicketModel ticket,
    @Default([]) List<TicketPurchaseModel> purchases,
  }) = _TicketPurchasesByTicket;

  factory TicketPurchasesByTicketModel.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchasesByTicketModelFromJson(json);
}
