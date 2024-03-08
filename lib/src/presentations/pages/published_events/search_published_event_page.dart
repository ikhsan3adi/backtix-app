import 'package:backtix_app/src/blocs/events/event_search/event_search_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_filter.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SearchPublishedEventPage extends StatelessWidget {
  const SearchPublishedEventPage({super.key, required this.keyword});

  final String keyword;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return GetIt.I<EventSearchCubit>()
          ..getEvents(EventQuery(search: keyword, ongoingOnly: false));
      },
      child: Scaffold(
        body: ResponsivePadding(child: _SearchEventPage(keyword: keyword)),
      ),
    );
  }
}

class _SearchEventPage extends StatefulWidget {
  const _SearchEventPage({required this.keyword});

  final String keyword;

  @override
  State<_SearchEventPage> createState() => _SearchEventPageState();
}

class _SearchEventPageState extends State<_SearchEventPage> {
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

  /// Load more data when the user has scrolled to the end of the list
  ///
  /// related widget [LoadNewListDataWidget]
  void onScroll() {
    if (_controller.hasClients && context.mounted) {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;

      if (currentScroll >= maxScroll) {
        context.read<EventSearchCubit>().getMoreEvents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<EventSearchCubit>();
        bloc.state.mapOrNull(loaded: (state) {
          bloc.getEvents(state.query.copyWith(page: 0));
        });
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller,
        scrollBehavior: const MaterialScrollBehavior(),
        slivers: [
          _AppBar(widget.keyword),
          const SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: _EventList(),
          ),
          BlocBuilder<EventSearchCubit, EventSearchState>(
            builder: (context, state) {
              /// If list is not scrollable, call [getMoreEvents] immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_controller.position.maxScrollExtent <= 0) {
                  context.read<EventSearchCubit>().getMoreEvents();
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

class _AppBar extends StatelessWidget {
  const _AppBar(this.initialKeyword);

  final String? initialKeyword;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      centerTitle: true,
      title: EventSearchBar(keyword: initialKeyword),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: SizedBox(
          height: 50,
          child: _FilterChips(),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd/MM/y');

  @override
  Widget build(BuildContext context) {
    EventQuery lastQuery = const EventQuery(page: 0);

    return BlocBuilder<EventSearchCubit, EventSearchState>(
      builder: (context, state) {
        final bloc = context.read<EventSearchCubit>();
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
                if (!value) return bloc.getEvents(query.copyWith(from: null));

                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2050),
                );

                if (date != null) {
                  bloc.getEvents(query.copyWith(from: date));
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
                  if (!value) return bloc.getEvents(query.copyWith(to: null));

                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2050),
                  );

                  if (date != null) {
                    bloc.getEvents(query.copyWith(to: date));
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
                    label: Text(e.filter),
                    onSelected: (value) async {
                      switch (e.type) {
                        case EventFilterType.location:
                          return bloc.getEvents(query.copyWith(
                            location: value ? e.filter : null,
                          ));
                        case EventFilterType.category:
                          if (value) {
                            return bloc.getEvents(query.copyWith(
                              categories: [...query.categories, e.filter],
                            ));
                          }
                          return bloc.getEvents(query.copyWith(
                            categories: [...query.categories]..remove(e.filter),
                          ));
                        case EventFilterType.keyword:
                          return bloc.getEvents(query.copyWith(
                            search: value ? e.filter : null,
                          ));
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

class _EventList extends StatelessWidget {
  const _EventList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EventSearchCubit, EventSearchState>(
      listener: (context, state) {
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
            if (state.events.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: NotFoundWidget()),
              );
            }
            return SliverList.separated(
              itemCount: state.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                return PublishedEventCard(
                  onTap: () => context.pushNamed(
                    RouteNames.eventDetail,
                    pathParameters: {'id': state.events[index].id},
                    queryParameters: {
                      'name': state.events[index].name,
                      'heroImageTag': state.events[index].id,
                      if (state.events[index].images.isNotEmpty)
                        'heroImageUrl': state.events[index].images[0].image,
                    },
                  ),
                  event: state.events[index],
                );
              },
            );
          },
          orElse: () {
            return SliverList.separated(
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, __) {
                return Shimmer(child: Container(height: 120));
              },
            );
          },
        );
      },
    );
  }
}
