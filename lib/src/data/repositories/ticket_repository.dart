import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/update_ticket_model.dart';
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
      getMyTicketPurchases(TicketPurchaseQuery query) async {
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

  Future<Either<DioException, List<TicketPurchaseModel>>>
      getTicketPurchasesByEvent(
    String eventId,
    TicketPurchaseQuery query,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.getTicketPurchasesByEvent(
          eventId,
          query,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketPurchasesByTicketModel>>
      getTicketPurchasesByTicket(
    String ticketId,
    TicketPurchaseQuery query,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.getTicketPurchasesByTicket(
          ticketId,
          query,
        );
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

  Future<Either<DioException, TicketPurchaseModel>> acceptTicketRefund(
    String uid,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.acceptTicketRefund(uid);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketPurchaseModel>> rejectTicketRefund(
    String uid,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.rejectTicketRefund(uid);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketModel>> addNewTicket(
    String eventId,
    NewTicketModel newTicket,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.addNewTicket(
          eventId,
          name: newTicket.name,
          price: newTicket.price,
          stock: newTicket.stock,
          salesOpenDate: newTicket.salesOpenDate.toIso8601String(),
          purchaseDeadline: newTicket.purchaseDeadline?.toIso8601String(),
          ticketImageFile: newTicket.imageFile,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketModel>> updateTicket(
    String ticketId,
    UpdateTicketModel ticket,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.updateTicket(
          ticketId,
          name: ticket.name,
          price: ticket.price,
          additionalStock: ticket.additionalStock,
          salesOpenDate: ticket.salesOpenDate?.toIso8601String(),
          purchaseDeadline: ticket.purchaseDeadline?.toIso8601String(),
          deleteImage: ticket.deleteImage,
          ticketImageFile: ticket.newImageFile,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, TicketModel>> deleteTicket(
    String ticketId,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _ticketService.deleteTicket(ticketId);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
