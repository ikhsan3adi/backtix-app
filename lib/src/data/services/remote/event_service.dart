import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'event_service.g.dart';

@RestApi()
abstract class EventService {
  factory EventService(Dio dio, {String? baseUrl}) = _EventService;

  @GET('events')
  Future<HttpResponse<List<EventModel>>> getPublishedEvents(
    @Queries() EventQuery? query,
  );

  @GET('events/nearby')
  Future<HttpResponse<List<EventModel>>> getNearbyPublishedEvents([
    @Query('count') int? count,
    @Query('distance') int? distance,
  ]);

  @GET('events/{id}')
  Future<HttpResponse<EventModel>> getPublishedEventDetail(
    @Path('id') String id,
  );
}
