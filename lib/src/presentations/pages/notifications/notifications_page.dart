import 'package:backtix_app/src/blocs/notifications/info_notifications_cubit.dart';
import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/background_service.dart';
import 'package:backtix_app/src/core/local_notification.dart';
import 'package:backtix_app/src/data/models/notification/notification_entity_type_enum.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/models/notification/notification_type_enum.dart';
import 'package:backtix_app/src/data/services/background_notification_service.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load more data when the user has scrolled to the end of the list
  void onScroll() async {
    if (_scrollController.hasClients && context.mounted) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll) {
        if (_tabController.index == 0) {
          return context.read<NotificationsCubit>().getMoreNotifications();
        }
        return context.read<InfoNotificationsCubit>().getMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            if (_tabController.index == 0) {
              return context.read<NotificationsCubit>().getNotifications();
            }
            return context.read<InfoNotificationsCubit>().getNotifications();
          },
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('Notification'),
                floating: true,
                snap: true,
                forceElevated: innerBoxIsScrolled,
                actions: [
                  TextButton.icon(
                    onPressed: () async {
                      final b = await ConfirmDialog.show(context);
                      if ((b ?? false) && context.mounted) {
                        if (_tabController.index == 0) {
                          return await context
                              .read<NotificationsCubit>()
                              .readAllNotifications();
                        }
                        return await context
                            .read<InfoNotificationsCubit>()
                            .readAllNotifications();
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark as read'),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Important'),
                    Tab(text: 'Info'),
                  ],
                ),
              ),
            ],
            body: Builder(builder: (context) {
              /// If list is not scrollable, get more data immediately
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (_scrollController.position.maxScrollExtent <=
                    kToolbarHeight + kTextTabBarHeight) {
                  if (_tabController.index == 0) {
                    return context
                        .read<NotificationsCubit>()
                        .getMoreNotifications();
                  }
                  return context
                      .read<InfoNotificationsCubit>()
                      .getMoreNotifications();
                }
              });
              return TabBarView(
                controller: _tabController,
                children: const [
                  _NotificationList<NotificationsCubit>(
                    key: PageStorageKey<String>('important_notifications'),
                  ),
                  _NotificationList<InfoNotificationsCubit>(
                    key: PageStorageKey<String>('info_notifications'),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NotificationList<C extends NotificationsCubit> extends StatelessWidget {
  const _NotificationList({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackgroundService.on(BackgroundNotificationService.updateMethod)?.listen(
        (event) {
          final List data = event?[(key as PageStorageKey<String>).value] ?? [];
          debugPrint(event.toString());
          context.read<C>().addNewNotifications(
                data.map((e) => NotificationModel.fromJson(e)).toList(),
                DateTime.tryParse(event?[C is InfoNotificationsCubit
                    ? 'info_last_updated'
                    : 'last_updated']),
              );
        },
      );
    });
    return CustomScrollView(
      key: key,
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
                loaded: (state) {
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
                  final lastUpdated = context.read<C>().previouslastUpdated;
                  final limit = Constant.notificationCountLimit;
                  final ntx = state.notifications.where((e) {
                    return !e.isRead && e.updatedAt.isAfter(lastUpdated);
                  }).take(limit);
                  for (var n in ntx) {
                    LocalNotification.show(
                      id: 6969,
                      title: n.type.title,
                      body: n.message,
                      payload: '${n.id}',
                    );
                  }
                },
              );
            },
            builder: (context, state) {
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
                        onTap: _onNotificationTap(context, notification),
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
    );
  }

  VoidCallback _onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    return () {
      switch (notification.entityType) {
        case NotificationEntityType.event:
          if (notification.type == NotificationType.ticketPurchase) {
            return context.goNamed(RouteNames.myTickets);
          } else if (notification.type == NotificationType.ticketSales) {
            return context.goNamed(
              RouteNames.eventTicketSales,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          } else if (notification.type ==
              NotificationType.ticketRefundRequest) {
            return context.goNamed(
              RouteNames.eventTicketRefundRequest,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          } else if (notification.type == NotificationType.ticketRefundStatus) {
            return context.goNamed(
              RouteNames.myTickets,
              queryParameters: {'refund': 'yes'},
            );
          } else if (notification.type == NotificationType.eventStatus) {
            return context.goNamed(
              RouteNames.myEventDetail,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          }
          return context.goNamed(
            RouteNames.eventDetail,
            pathParameters: {'id': notification.entityId ?? ''},
          );
        case NotificationEntityType.withdrawRequest:
          return context.goNamed(RouteNames.myWithdraws);
        case NotificationEntityType.purchase:
        case NotificationEntityType.ticket:
        default:
        // Not implemented
      }
    };
  }
}
