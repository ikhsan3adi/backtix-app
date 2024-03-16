import 'dart:async';

import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/repositories/notification_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_cubit.freezed.dart';
part 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;

  NotificationsCubit(this.repository)
      : super(const NotificationsState.initial());

  DateTime? lastUpdated;
  Timer? timer;
  Duration get interval => const Duration(seconds: 15);

  void stopRefreshing() => timer?.cancel();

  void startRefreshing() {
    stopRefreshing();
    timer = Timer.periodic(interval, (_) async => await getNewNotifications());
  }

  @override
  Future<void> close() async {
    stopRefreshing();
    super.close();
  }

  void getNotifications() async {
    emit(const NotificationsState.loading());

    final result = await repository.getImportantNotifications();

    result.fold(
      (e) => emit(NotificationsState.loaded([], exception: e)),
      (notifications) {
        lastUpdated = DateTime.now();
        return emit(NotificationsState.loaded(notifications));
      },
    );
    return startRefreshing();
  }

  Future<void> getNewNotifications() async {
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final result = await repository.getImportantNotifications(
      from: lastUpdated,
    );

    return result.fold(
      (_) {},
      (newNotifications) {
        lastUpdated = DateTime.now();
        return emit(NotificationsState.loaded(
          [...newNotifications, ...previousData],
          page: page,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }

  Future<void> getMoreNotifications() async {
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final newPage = hasReachedMax ? page : page + 1;

    final result = await repository.getImportantNotifications(page: newPage);

    return result.fold(
      (e) => emit(NotificationsState.loaded(
        previousData,
        exception: e,
        hasReachedMax: true,
      )),
      (notifications) => emit(NotificationsState.loaded(
        [...previousData, ...notifications],
        page: newPage,
        hasReachedMax: notifications.isEmpty,
      )),
    );
  }

  Future<void> readNotification(int id) async {
    if (state is! _Loaded) return;
    final currentState = state as _Loaded;

    final result = await repository.readNotification(id);

    return result.fold(
      (e) => emit(currentState.copyWith(exception: e)),
      (read) {
        final notifications = currentState.notifications;
        final index = notifications.indexWhere((e) => e.id == id);
        return emit(currentState.copyWith(
          notifications: [...notifications]..replaceRange(index, index + 1, [
              notifications[index].copyWith(reads: [read])
            ]),
        ));
      },
    );
  }

  Future<void> readAllNotifications() async {
    if (state is! _Loaded) return;
    final currentState = state as _Loaded;

    final result = await repository.readAllNotifications();

    return result.fold(
      (e) => emit(currentState.copyWith(exception: e)),
      (notifications) => emit(currentState.copyWith(
        notifications: currentState.notifications.map((e) {
          if (e.isRead) return e;
          return e.copyWith(reads: [e.reads[0].copyWith(isRead: true)]);
        }).toList(),
      )),
    );
  }
}
