import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_ticket_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'ticket_service.g.dart';

@RestApi()
abstract class TicketService {
  factory TicketService(Dio dio, {String? baseUrl}) = _TicketService;

  @POST('purchases/ticket')
  Future<HttpResponse<TicketOrderModel>> createTicketOrder(
    @Body() CreateTicketOrderModel order,
  );

  @GET('purchases/ticket/my')
  Future<HttpResponse<List<TicketPurchasesByEventModel>>> getMyTicketPurchases(
    @Queries() TicketPurchaseQuery? query,
  );

  @GET('purchases/ticket/my/{uid}')
  Future<HttpResponse<TicketPurchaseModel>> getMyTicketPurchase(
    @Path('uid') String uid,
  );

  @GET('events/{id}/purchases')
  Future<HttpResponse<List<TicketPurchaseModel>>> getTicketPurchasesByEvent(
    @Path('id') String eventId,
    @Queries() TicketPurchaseQuery query,
  );

  @GET('tickets/{id}/purchases')
  Future<HttpResponse<TicketPurchasesByTicketModel>> getTicketPurchasesByTicket(
    @Path('id') String ticketId,
    @Queries() TicketPurchaseQuery query,
  );

  @POST('purchases/{uid}/refund')
  Future<HttpResponse<TicketPurchaseModel>> refundTicketPurchase(
    @Path('uid') String uid,
  );

  @PATCH('purchases/{uid}/refund')
  Future<HttpResponse<TicketPurchaseModel>> acceptTicketRefund(
    @Path('uid') String uid,
  );

  @DELETE('purchases/{uid}/refund')
  Future<HttpResponse<TicketPurchaseModel>> rejectTicketRefund(
    @Path('uid') String uid,
  );
}
