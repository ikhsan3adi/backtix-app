import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:backtix_app/src/data/services/remote/ticket_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class TicketRepository {
  final TicketService _ticketService;

  const TicketRepository(this._ticketService);

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

  Future<Either<DioException, List<TicketPurchasesByEventModel>>>
      getMyTicketPurchases(
    TicketPurchaseQuery query,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.getMyTicketPurchases(query);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketPurchaseModel>> getMyTicketPurchase(
    String uid,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.getMyTicketPurchase(uid);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketPurchaseModel>> refundTicketPurchase(
    String uid,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.refundTicketPurchase(uid);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
