import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
import 'package:backtix_app/src/data/services/remote/ticket_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class TicketRepository {
  final TicketService _ticketService;

  TicketRepository(this._ticketService);

  Future<Either<DioException, TicketOrderModel>> createTicketOrder(
    CreateTicketOrderModel order,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.createTicketOrder(order);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
