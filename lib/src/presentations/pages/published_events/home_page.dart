import 'package:backtix_app/src/blocs/events/published_events/published_events_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_filter.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = ScrollController();

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

  /// Load more data when the user has scrolled to the end of the list
  ///
  /// related widget [LoadNewListDataWidget]
  void onScroll() {
    if (_controller.hasClients && context.mounted) {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;

      if (currentScroll >= maxScroll) {
        context.read<PublishedEventsBloc>().add(
              const PublishedEventsEvent.getMorePublishedEvents(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          final bloc = context.read<PublishedEventsBloc>();
          bloc.state.mapOrNull(loaded: (state) {
            bloc.add(PublishedEventsEvent.getPublishedEvents(
              state.query.copyWith(page: 0),
              refreshNearbyEvents: true,
              isUserLocationSet: context.read<UserModel>().isUserLocationSet,
            ));
          });
        },
        child: CustomScrollView(
          controller: _controller,
          scrollBehavior: const MaterialScrollBehavior(),
          slivers: [
            _SliverAppBar(),
            const _Carousels(),
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: _OtherEventList(),
            ),
            BlocBuilder<PublishedEventsBloc, PublishedEventsState>(
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
      ),
    );
  }
}

class _SliverAppBar extends StatefulWidget {
  @override
  State<_SliverAppBar> createState() => _SliverAppBarState();
}

class _SliverAppBarState extends State<_SliverAppBar> {
  final _hideSearchBar = ValueNotifier(true);
  final searchBar = const EventSearchBar();

  @override
  void dispose() {
    _hideSearchBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _hideSearchBar,
      builder: (_, hideSearchBar, __) {
        return SliverAppBar(
          pinned: true,
          floating: true,
          centerTitle: true,
          leading: hideSearchBar ? const ThemeToggleIconButton() : null,
          title: hideSearchBar
              ? Text(
                  'BACKTIX',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                )
              : searchBar,
          actions: [
            IconButton(
              onPressed: () => _hideSearchBar.value = !_hideSearchBar.value,
              icon: FaIcon(
                hideSearchBar
                    ? FontAwesomeIcons.magnifyingGlass
                    : FontAwesomeIcons.xmark,
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SizedBox(
              height: 50,
              child: _FilterChips(),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd/MM/y');

  @override
  Widget build(BuildContext context) {
    EventQuery lastQuery = const EventQuery(page: 0);

    return BlocBuilder<PublishedEventsBloc, PublishedEventsState>(
      builder: (context, state) {
        final bloc = context.read<PublishedEventsBloc>();
        final loadedState = state.mapOrNull(loaded: (s) {
          lastQuery = s.query;
          return s;
        });
        final query = loadedState == null
            ? lastQuery
            : loadedState.query.copyWith(page: 0);
        final event = GetPublishedEvents(
          query.copyWith(page: 0),
          isUserLocationSet: context.read<UserModel>().isUserLocationSet,
        );

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              label: Text(
                query.from != null
                    ? 'from: ${dateFormat.format(query.from!)}'
                    : 'from',
              ),
              onSelected: (value) async {
                if (!value) {
                  return bloc.add(event.copyWith(
                    query: event.query.copyWith(from: null),
                  ));
                }

                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                );

                if (date != null) {
                  bloc.add(event.copyWith(
                    query: event.query.copyWith(from: date),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                label: Text(
                  query.to != null
                      ? 'to: ${dateFormat.format(query.to!)}'
                      : 'to',
                ),
                onSelected: (value) async {
                  if (!value) {
                    return bloc.add(event.copyWith(
                      query: event.query.copyWith(to: null),
                    ));
                  }

                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );

                  if (date != null) {
                    bloc.add(event.copyWith(
                      query: event.query.copyWith(to: date),
                    ));
                  }
                },
              ),
            ),
            ...EventFilter.filters.map(
              (e) {
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: FilterChip(
                    selected: switch (e.type) {
                      EventFilterType.location => query.location == e.filter,
                      EventFilterType.category =>
                        query.categories.contains(e.filter),
                      EventFilterType.keyword => query.search == e.filter,
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    label: Text(e.filter),
                    onSelected: (value) async {
                      switch (e.type) {
                        case EventFilterType.location:
                          return bloc.add(
                            event.copyWith(
                              query: event.query.copyWith(
                                location: value ? e.filter : null,
                              ),
                            ),
                          );
                        case EventFilterType.category:
                          if (value) {
                            return bloc.add(
                              event.copyWith(
                                query: event.query.copyWith(
                                  categories: [...query.categories, e.filter],
                                ),
                              ),
                            );
                          }
                          return bloc.add(
                            event.copyWith(
                              query: event.query.copyWith(
                                categories: [...query.categories]
                                  ..remove(e.filter),
                              ),
                            ),
                          );
                        case EventFilterType.keyword:
                          return bloc.add(
                            event.copyWith(
                              query: event.query.copyWith(
                                search: value ? e.filter : null,
                              ),
                            ),
                          );
                      }
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _Carousels extends StatelessWidget {
  const _Carousels();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Upcoming events',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          UpcomingEventsCarousel(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Text(
              'Nearby events',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NearbyEventsCarousel(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
            child: Text(
              'Other events',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtherEventList extends StatelessWidget {
  const _OtherEventList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublishedEventsBloc, PublishedEventsState>(
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
          loaded: (state) {
            final events = state.events.skip(5).toList();
            if (events.isEmpty) {
              return SliverToBoxAdapter(
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: context.isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: NotFoundWidget()),
                ),
              );
            }
            return SliverList.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                //! Avoid hero tag conflict
                final heroImageTag = UniqueKey().toString();
                return PublishedEventCard(
                  onTap: () => context.goNamed(
                    RouteNames.eventDetail,
                    pathParameters: {'id': events[index].id},
                    queryParameters: {
                      'name': events[index].name,
                      'heroImageTag': heroImageTag,
                      'heroImageUrl': events[index].images[0].image,
                    },
                  ),
                  event: events[index],
                  heroImageTag: heroImageTag,
                );
              },
            );
          },
          // loading
          orElse: () {
            return SliverList.separated(
              itemCount: 2,
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
        );
      },
    );
  }
}
