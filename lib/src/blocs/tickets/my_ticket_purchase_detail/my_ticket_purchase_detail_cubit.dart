import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/repositories/ticket_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_ticket_purchase_detail_cubit.freezed.dart';
part 'my_ticket_purchase_detail_state.dart';

class MyTicketPurchaseDetailCubit extends Cubit<MyTicketPurchaseDetailState> {
  final TicketRepository _ticketRepository;

  MyTicketPurchaseDetailCubit(this._ticketRepository)
      : super(const MyTicketPurchaseDetailState.loading());

  Future<void> getTicketPurchaseDetail(String uid) async {
    emit(const MyTicketPurchaseDetailState.loading());

    final result = await _ticketRepository.getMyTicketPurchase(uid);

    return result.fold(
      (err) => emit(MyTicketPurchaseDetailState.error(err)),
      (ticketPurchase) => emit(MyTicketPurchaseDetailState.loaded(
        ticketPurchase,
      )),
    );
  }
}
