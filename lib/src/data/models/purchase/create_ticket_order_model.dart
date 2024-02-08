import 'package:backtix_app/src/data/models/purchase/payment_method_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ticket_order_model.freezed.dart';
part 'create_ticket_order_model.g.dart';

@freezed
class CreateTicketOrderModel with _$CreateTicketOrderModel {
  const factory CreateTicketOrderModel({
    required PaymentMethod paymentMethod,
    required List<({String ticketId, int quantity})> purchases,
  }) = _CreateTicketOrderModel;

  factory CreateTicketOrderModel.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketOrderModelFromJson(json);
}
