import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/services/remote/notification_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class NotificationRepository {
  final NotificationService _notificationService;

  const NotificationRepository(this._notificationService);

  Future<Either<DioException, List<NotificationModel>>>
      getImportantNotifications({
    int page = 0,
    int? skip,
    DateTime? from,
    DateTime? to,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _notificationService.getImportantNotifications(
          page,
          skip,
          from,
          to,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, List<NotificationModel>>> getInfoNotifications({
    int page = 0,
    int? skip,
    DateTime? from,
    DateTime? to,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _notificationService.getInfoNotifications(
          page,
          skip,
          from,
          to,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, NotificationRead>> readNotification(
    int id,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _notificationService.readNotification(id);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, dynamic>> readAllNotifications() async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _notificationService.readAllNotifications();
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }
}
