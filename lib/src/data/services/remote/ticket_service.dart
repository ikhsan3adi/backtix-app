import 'package:backtix_app/src/data/models/purchase/create_ticket_order_model.dart';
import 'package:backtix_app/src/data/models/purchase/ticket_order_model.dart';
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
}
