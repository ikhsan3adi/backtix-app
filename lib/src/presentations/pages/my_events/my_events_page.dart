import 'package:backtix_app/src/blocs/events/my_events/my_events_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyEventsPage extends StatelessWidget {
  const MyEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => GetIt.I<MyEventsBloc>()
          ..add(const MyEventsEvent.getMyEvents(EventQuery(
            page: 0,
            status: EventStatus.published,
            ongoingOnly: true,
          ))),
        child: const _MyEventsPage(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: context.colorScheme.primary,
        onPressed: () async {
          final eventId = await ScanTicketEventListDialog.show(context);

          if (eventId != null && context.mounted) {
            context.goNamed(
              RouteNames.verifyTicket,
              pathParameters: {'id': eventId},
            );
          }
        },
        label: const Text('Scan Ticket'),
        icon: const Icon(Icons.qr_code_scanner_outlined),
      ),
    );
  }
}

class _MyEventsPage extends StatefulWidget {
  const _MyEventsPage();

  @override
  State<_MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<_MyEventsPage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onScroll() {
    if (_controller.hasClients && context.mounted) {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;

      if (currentScroll >= maxScroll) {
        context.read<MyEventsBloc>().add(const MyEventsEvent.getMoreMyEvents());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<MyEventsBloc>();
        bloc.state.mapOrNull(loaded: (state) {
          bloc.add(MyEventsEvent.getMyEvents(state.query.copyWith(page: 0)));
        });
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            title: const Text('My Events'),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  final bool? refresh = await context.pushNamed(
                    RouteNames.createNewEvent,
                  );
                  if (context.mounted && (refresh ?? false)) {
                    final bloc = context.read<MyEventsBloc>();
                    bloc.state.mapOrNull(loaded: (state) {
                      bloc.add(MyEventsEvent.getMyEvents(
                        state.query.copyWith(page: 0),
                      ));
                    });
                  }
                },
                label: const Text('New Event'),
                icon: const Icon(Icons.add),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: SizedBox(
                height: 50,
                child: _FilterChips(),
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, top: 4, right: 16),
            sliver: _EventList(),
          ),
          BlocBuilder<MyEventsBloc, MyEventsState>(
            builder: (context, state) {
              /// If list is not scrollable, get more data immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_controller.position.maxScrollExtent <= 0) {
                  context
                      .read<MyEventsBloc>()
                      .add(const MyEventsEvent.getMoreMyEvents());
                }
              });

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

class _FilterChips extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd/MM/y');

  @override
  Widget build(BuildContext context) {
    EventQuery lastQuery = const EventQuery(
      page: 0,
      status: EventStatus.published,
      ongoingOnly: true,
    );

    return BlocBuilder<MyEventsBloc, MyEventsState>(
      builder: (context, state) {
        final bloc = context.read<MyEventsBloc>();
        final loadedState = state.mapOrNull(loaded: (s) {
          lastQuery = s.query;
          return s;
        });
        final query = loadedState == null
            ? lastQuery
            : loadedState.query.copyWith(page: 0);

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            FilterChip(
              showCheckmark: false,
              avatar: Icon(
                Icons.calendar_month_outlined,
                color: context.colorScheme.onSurface,
              ),
              selected: query.from != null,
              label: Text(
                query.from != null
                    ? 'from: ${dateFormat.format(query.from!)}'
                    : 'from',
              ),
              onSelected: (value) async {
                if (!value) {
                  return bloc.add(MyEventsEvent.getMyEvents(
                    query.copyWith(from: null),
                  ));
                }

                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                );

                if (date != null) {
                  bloc.add(MyEventsEvent.getMyEvents(
                    query.copyWith(from: date),
                  ));
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: FilterChip(
                showCheckmark: false,
                avatar: Icon(
                  Icons.calendar_month,
                  color: context.colorScheme.onSurface,
                ),
                selected: query.to != null,
                label: Text(
                  query.to != null
                      ? 'to: ${dateFormat.format(query.to!)}'
                      : 'to',
                ),
                onSelected: (value) async {
                  if (!value) {
                    return bloc.add(MyEventsEvent.getMyEvents(
                      query.copyWith(to: null),
                    ));
                  }

                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );

                  if (date != null) {
                    bloc.add(MyEventsEvent.getMyEvents(
                      query.copyWith(to: date),
                    ));
                  }
                },
              ),
            ),
            ...EventStatus.values.map(
              (status) {
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    selected: query.status == status,
                    label: Text(status.toString()),
                    onSelected: (v) {
                      return bloc.add(MyEventsEvent.getMyEvents(
                        query.copyWith(
                          status: v ? status : null,
                          ongoingOnly: status == EventStatus.published,
                        ),
                      ));
                    },
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: FilterChip(
                selected: query.ongoingOnly,
                label: const Text('On Going'),
                onSelected: (value) async => bloc.add(MyEventsEvent.getMyEvents(
                  query.copyWith(ongoingOnly: value),
                )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: FilterChip(
                selected: query.endedOnly,
                label: const Text('Ended'),
                onSelected: (value) async => bloc.add(MyEventsEvent.getMyEvents(
                  query.copyWith(endedOnly: value),
                )),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyEventsBloc, MyEventsState>(
      listener: (_, state) {
        state.mapOrNull(
          loaded: (state) {
            if (state.exception != null) {
              ErrorDialog.show(context, state.exception!);
            }
          },
        );
      },
      builder: (context, state) {
        return state.maybeMap(
          orElse: () {
            return SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => Container(
                height: 120,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Shimmer(),
              ),
            );
          },
          loaded: (state) {
            if (state.events.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: NotFoundWidget()),
              );
            }

            final events = state.events;
            return SliverList.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final heroImageTag = UniqueKey().toString();
                return MyEventCard(
                  event: events[index],
                  heroImageTag: heroImageTag,
                  onTap: () => context.goNamed(
                    RouteNames.myEventDetail,
                    pathParameters: {'id': events[index].id},
                    queryParameters: {
                      'name': events[index].name,
                      'heroImageTag': heroImageTag,
                      if (events[index].images.isNotEmpty)
                        'heroImageUrl': events[index].images[0].image,
                    },
                  ),
                  onEdit: () async {
                    final bool? refresh = await context.pushNamed(
                      RouteNames.editEvent,
                      pathParameters: {'id': events[index].id},
                    );
                    if (context.mounted && (refresh ?? false)) {
                      context.read<MyEventsBloc>().add(
                            MyEventsEvent.getMyEvents(
                              state.query.copyWith(page: 0),
                            ),
                          );
                    }
                  },
                  onDelete: () async {
                    final confirm = await ConfirmDialog.show(context);
                    if (!context.mounted || !(confirm ?? false)) return;
                    context
                        .read<MyEventsBloc>()
                        .add(MyEventsEvent.deleteEvent(events[index].id));
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
