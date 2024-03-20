import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_service.g.dart';

@RestApi()
abstract class NotificationService {
  factory NotificationService(Dio dio, {String? baseUrl}) =
      _NotificationService;

  @GET('notifications')
  Future<HttpResponse<List<NotificationModel>>> getImportantNotifications([
    @Query('page') int? page,
    @Query('skip') int? skip,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
  ]);

  @GET('notifications/info')
  Future<HttpResponse<List<NotificationModel>>> getInfoNotifications([
    @Query('page') int? page,
    @Query('skip') int? skip,
    @Query('from') DateTime? from,
    @Query('to') DateTime? to,
  ]);

  @NoBody()
  @PATCH('notifications/read')
  Future<HttpResponse> readAllNotifications();

  @NoBody()
  @PATCH('notifications/{id}/read')
  Future<HttpResponse<NotificationRead>> readNotification(@Path('id') int id);
}
