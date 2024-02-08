import 'package:backtix_app/src/data/models/purchase/transaction_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_order_model.freezed.dart';
part 'ticket_order_model.g.dart';

@freezed
class TicketOrderModel with _$TicketOrderModel {
  const factory TicketOrderModel({
    required List<TicketModel> tickets,
    required TransactionModel transaction,
  }) = _TicketOrderModel;

  factory TicketOrderModel.fromJson(Map<String, dynamic> json) =>
      _$TicketOrderModelFromJson(json);
}
