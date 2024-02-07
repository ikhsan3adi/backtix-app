import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/payment_method_enum.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_ticket_order_cubit.freezed.dart';
part 'create_ticket_order_state.dart';

class CreateTicketOrderCubit extends Cubit<CreateTicketOrderState> {
  CreateTicketOrderCubit()
      : super(const CreateTicketOrderState(
          paymentMethod: PaymentMethod.direct,
          purchases: [],
        ));

  void selectTicket(TicketModel ticket) {
    final purchases = state.purchases;

    /// remove/unselect if [ticket] already selected
    if (state.hasTicketId(ticket.id)) {
      return emit(state.copyWith(
        purchases: [...purchases]..removeWhere((e) => e.ticket.id == ticket.id),
      ));
    }

    return emit(state.copyWith(
      purchases: [...purchases, (ticket: ticket, quantity: 1)],
    ));
  }

  void updateOrderQuantity(TicketModel ticket, {required int quantity}) {
    final purchases = state.purchases;

    final index = purchases.indexWhere((e) => e.ticket.id == ticket.id);

    if (index == -1) {
      /// if purchase/ticket not found, add new one
      return emit(state.copyWith(
        purchases: [...purchases, (ticket: ticket, quantity: quantity)],
      ));
    } else if (quantity <= 0) {
      /// if quantity is 0, remove the purchase with [ticket]
      return emit(state.copyWith(
        purchases: [...purchases]..removeWhere((e) => e.ticket.id == ticket.id),
      ));
    }

    /// update purchase with new quantity
    return emit(state.copyWith(
      purchases: [...purchases]..replaceRange(
          index,
          index + 1,
          [(quantity: quantity, ticket: ticket)],
        ),
    ));
  }

  void changePaymentMethod(PaymentMethod paymentMethod) {
    emit(state.copyWith(paymentMethod: paymentMethod));
  }
}
