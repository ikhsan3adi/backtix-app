import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'ticket_service.g.dart';

@RestApi()
abstract class TicketService {
  factory TicketService(Dio dio, {String? baseUrl}) = _TicketService;

  @POST('purchase/ticket')
  Future<HttpResponse<TicketOrderModel>> createTicketOrder(
    @Body() CreateTicketOrderModel order,
  );

  @GET('purchase/ticket/my')
  Future<HttpResponse<List<TicketPurchasesByEventModel>>> getMyTicketPurchases(
    @Queries() TicketPurchaseQuery? query,
  );

  @GET('purchase/ticket/my/{uid}')
  Future<HttpResponse<TicketPurchaseModel>> getMyTicketPurchase(
    @Path('uid') String uid,
  );

  @POST('purchase/{uid}/refund')
  Future<HttpResponse<TicketPurchaseModel>> refundTicketPurchase(
    @Path('uid') String uid,
  );
}
