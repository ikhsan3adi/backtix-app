import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/event/new_event_model.dart';
import 'package:backtix_app/src/data/models/event/update_event_model.dart';
import 'package:backtix_app/src/data/services/remote/event_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class EventRepository {
  final EventService _eventService;

  const EventRepository(this._eventService);

  Future<Either<DioException, List<EventModel>>> getPublishedEvents(
    EventQuery query,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _eventService.getPublishedEvents(query);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, List<EventModel>>> getNearbyPublishedEvents({
    int? count = 5,
    int? distance = 5,
  }) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _eventService.getNearbyPublishedEvents(
          count,
          distance,
        );
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, EventModel>> getPublishedEventDetail(
    String id,
  ) async {
    return await TaskEither.tryCatch(
      () async => (await _eventService.getPublishedEventDetail(id)).data,
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, List<EventModel>>> getMyEvents(
    EventQuery query,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _eventService.getMyEvents(query);
        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, EventModel>> getMyEventDetail(String id) async {
    return await TaskEither.tryCatch(
      () async => (await _eventService.getMyEventDetail(id)).data,
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, EventModel>> createNewEvent(
    NewEventModel newEvent,
  ) async {
    return await TaskEither.tryCatch(
      () async {
        final response = await _eventService.createNewEvent(
          eventImageFiles: newEvent.eventImageFiles
              .map((e) => MultipartFile.fromBytes(
                    e.readAsBytesSync(),
                    filename: e.path.split('/').last,
                  ))
              .toList(),
          ticketImageFiles: newEvent.ticketImageFiles
              .map((e) => MultipartFile.fromBytes(
                    e.readAsBytesSync(),
                    filename: e.path.split(Platform.pathSeparator).last,
                  ))
              .toList(),
          name: newEvent.name,
          description: newEvent.description,
          date: newEvent.date.toIso8601String(),
          endDate: newEvent.endDate?.toIso8601String(),
          location: newEvent.location,
          latitude: newEvent.latitude,
          longitude: newEvent.longitude,
          categories: newEvent.categories,
          imageDescriptions: newEvent.imageDescriptions,
          tickets: newEvent.tickets.map((e) => e.toJson()).toList(),
        );

        return response.data;
      },
      (error, _) => error as DioException,
    ).run();
  }

  Future<Either<DioException, EventModel>> deleteEvent(String id) async {
    return await TaskEither.tryCatch(
      () async => (await _eventService.deleteEvent(id)).data,
      (error, _) => error as DioException,
    ).run();
  }
}
