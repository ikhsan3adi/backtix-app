// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:backtix_app/src/config/constant.dart';
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

  DateTime previouslastUpdated = DateTime.now();
  DateTime lastUpdated = DateTime.now();
  Timer? timer;
  Duration get interval => Constant.shortInterval;

  void stopRefreshing() => timer?.cancel();

  /// Used when background service is not supported
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

    previouslastUpdated = lastUpdated;
    lastUpdated = DateTime.now();
    final result = await repository.getImportantNotifications(page: 0);

    result.fold(
      (e) => emit(NotificationsState.loaded([], exception: e)),
      (notifications) {
        return emit(NotificationsState.loaded(
          notifications,
          lastUpdated: lastUpdated,
        ));
      },
    );
  }

  /// Use [addNewNotifications] if background service is supported
  Future<void> getNewNotifications() async {
    previouslastUpdated = lastUpdated;
    final (previousData, page, hasReachedMax) = state.maybeMap(
      loaded: (state) => (state.notifications, state.page, state.hasReachedMax),
      orElse: () => (<NotificationModel>[], 0, false),
    );

    final result = await repository.getImportantNotifications(
      from: lastUpdated,
    );
    lastUpdated = DateTime.now();

    return result.fold(
      (_) {},
      (newNotifications) {
        return emit(NotificationsState.loaded(
          [...newNotifications, ...previousData],
          lastUpdated: lastUpdated,
          page: page,
          hasReachedMax: hasReachedMax,
        ));
      },
    );
  }

  void addNewNotifications(
    List<NotificationModel> notifications, [
    DateTime? lastUpdated,
  ]) {
    if (state is! _Loaded) return;
    final currentState = state as _Loaded;
    this.lastUpdated = lastUpdated ?? this.lastUpdated;
    return emit(currentState.copyWith(
      notifications: [...notifications, ...currentState.notifications],
    ));
  }

  Future<void> getMoreNotifications() async {
    if (state is! _Loaded) return;
    final currentState = state as _Loaded;

    previouslastUpdated = lastUpdated;

    final (previousData, hasReachedMax) = (
      currentState.notifications,
      currentState.hasReachedMax,
    );

    final newPage = hasReachedMax ? currentState.page : currentState.page + 1;

    final result = await repository.getImportantNotifications(
      skip: previousData.length,
      to: lastUpdated,
    );

    return result.fold(
      (e) => emit(currentState.copyWith(
        notifications: previousData,
        exception: e,
        hasReachedMax: true,
      )),
      (notifications) => emit(currentState.copyWith(
        notifications: [...previousData, ...notifications],
        page: newPage,
        hasReachedMax: notifications.isEmpty,
      )),
    );
  }

  Future<void> readNotification(int id) async {
    if (state is! _Loaded) return;
    final currentState = state as _Loaded;

    previouslastUpdated = lastUpdated;

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

    previouslastUpdated = lastUpdated;

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
