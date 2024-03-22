import 'dart:async';
import 'dart:math';

import 'package:backtix_app/src/blocs/notifications/info_notifications_cubit.dart';
import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/background_service.dart';
import 'package:backtix_app/src/core/local_notification.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/services/background_notification_service.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notification'),
          actions: [
            TextButton.icon(
              onPressed: () async {
                final b = await ConfirmDialog.show(context);
                if ((b ?? false) && context.mounted) {
                  context.read<InfoNotificationsCubit>().readAllNotifications();
                  context.read<NotificationsCubit>().readAllNotifications();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Mark as read'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Important'),
              Tab(text: 'Info'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _NotificationList<NotificationsCubit>(
              key: ValueKey('important_notifications'),
            ),
            _NotificationList<InfoNotificationsCubit>(
              key: ValueKey('info_notifications'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList<C extends NotificationsCubit> extends StatefulWidget {
  const _NotificationList({super.key});

  @override
  State<_NotificationList<C>> createState() => _NS<C>();
}

/// _NotificationListState
class _NS<C extends NotificationsCubit> extends State<_NotificationList<C>> {
  final _scrollController = ScrollController();
  late StreamSubscription<Map<String, dynamic>?>? _ntxSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _ntxSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// Load more data when the user has scrolled to the end of the list
  void onScroll() async {
    if (_scrollController.hasClients && context.mounted) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll) {
        return context.read<C>().getMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const method = BackgroundNotificationService.updateMethod;
      String key = (widget.key as ValueKey).value;
      _ntxSubscription = BackgroundService.on(method)?.listen(
        (event) {
          final List data = event?[key] ?? [];
          final DateTime? lastUpdated = DateTime.tryParse(event?[
              C is InfoNotificationsCubit
                  ? 'info_last_updated'
                  : 'last_updated']);
          context.read<C>().addNewNotifications(
                data.map((e) => NotificationModel.fromJson(e)).toList(),
                lastUpdated,
              );
        },
      );
    });

    return RefreshIndicator.adaptive(
      onRefresh: () async => context.read<C>().getNotifications(),
      child: CustomScrollView(
        key: widget.key,
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 4,
              right: 16,
              bottom: 16,
            ),
            sliver: BlocConsumer<C, NotificationsState>(
              listener: (context, state) {
                state.mapOrNull(
                  loaded: (state) async {
                    if (state.exception != null) {
                      return ErrorDialog.show(context, state.exception!);
                    }
                    if (BackgroundService.supported) {
                      return BackgroundService.invoke(
                        BackgroundNotificationService.setDateMethod,
                        C is InfoNotificationsCubit
                            ? {'lastUpdatedInfo': state.lastUpdated}
                            : {'lastUpdated': state.lastUpdated},
                      );
                    }

                    //* Send notifications without background service
                    final lastUpdated = context.read<C>().previouslastUpdated;
                    final limit = Constant.notificationCountLimit;
                    final ntx = state.notifications.where((e) {
                      return !e.isRead &&
                          (e.updatedAt?.isAfter(lastUpdated) ?? false);
                    }).take(limit);
                    for (var n in ntx) {
                      await LocalNotification.show(
                        id: Random.secure().nextInt(6968),
                        title: n.type.title,
                        body: n.message,
                        payload: n.toSimpleJson().toString(),
                      );
                    }
                  },
                );
              },
              builder: (context, state) {
                /// If list is not scrollable, get more data immediately
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  if (_scrollController.position.maxScrollExtent <= 0) {
                    return context.read<C>().getMoreNotifications();
                  }
                });
                return state.maybeMap(
                  orElse: () {
                    return SliverList.separated(
                      itemCount: 10,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, __) => const SizedBox(
                        height: 100,
                        child: Shimmer(),
                      ),
                    );
                  },
                  loaded: (state) {
                    if (state.notifications.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: NotFoundWidget()),
                      );
                    }

                    return SliverList.separated(
                      itemCount: state.notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: NotificationHandler.onNotificationTap(
                            context,
                            notification,
                          ),
                          onRead: notification.isRead
                              ? null
                              : () => context
                                  .read<C>()
                                  .readNotification(notification.id),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          BlocConsumer<C, NotificationsState>(
            listener: (context, state) => state.mapOrNull(loaded: (s) async {
              if (s.exception != null) {
                return ErrorDialog.show(context, s.exception!);
              }
              return;
            }),
            builder: (context, state) {
              return state.maybeMap(
                loaded: (state) {
                  return SliverFillRemaining(
                    fillOverscroll: true,
                    hasScrollBody: false,
                    child: LoadNewListDataWidget(
                      reachedMax: state.hasReachedMax,
                    ),
                  );
                },
                orElse: () => const SliverToBoxAdapter(),
              );
            },
          ),
        ],
      ),
    );
  }
}
