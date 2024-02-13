import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchase_query.freezed.dart';
part 'ticket_purchase_query.g.dart';

@freezed
class TicketPurchaseQuery with _$TicketPurchaseQuery {
  const factory TicketPurchaseQuery({
    @Default(0) int page,
    TicketPurchaseStatus? status,
    TicketPurchaseRefundStatus? refundStatus,
    bool? used,
  }) = _TicketPurchaseQuery;

  factory TicketPurchaseQuery.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchaseQueryFromJson(json);
}
