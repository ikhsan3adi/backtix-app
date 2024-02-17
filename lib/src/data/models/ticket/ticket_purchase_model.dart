import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_purchase_model.freezed.dart';
part 'ticket_purchase_model.g.dart';

@freezed
class TicketPurchaseModel with _$TicketPurchaseModel {
  const TicketPurchaseModel._();

  const factory TicketPurchaseModel({
    required String uid,
    required String ticketId,
    required String userId,
    required String orderId,
    required num price,
    required TicketPurchaseStatus status,
    TicketPurchaseRefundStatus? refundStatus,
    @Default(false) bool used,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    @Default(1) int quantity,
    TicketModel? ticket,
    UserModel? user,
  }) = _TicketPurchase;

  factory TicketPurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$TicketPurchaseModelFromJson(json);
}
