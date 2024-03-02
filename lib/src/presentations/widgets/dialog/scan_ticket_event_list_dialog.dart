import 'package:backtix_app/src/blocs/events/my_events/my_events_bloc.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class ScanTicketEventListDialog extends StatefulWidget {
  const ScanTicketEventListDialog({super.key});

  static Future<String?> show(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider(
        create: (_) => GetIt.I<MyEventsBloc>()
          ..add(const MyEventsEvent.getMyEvents(EventQuery(
            page: 0,
            status: EventStatus.published,
          ))),
        child: const ScanTicketEventListDialog(),
      ),
    );
  }

  @override
  State<ScanTicketEventListDialog> createState() =>
      _ScanTicketEventListDialogState();
}

class _ScanTicketEventListDialogState extends State<ScanTicketEventListDialog> {
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
          const SliverAppBar(
            pinned: true,
            floating: true,
            centerTitle: true,
            title: Text('Select Your Event'),
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
                return MyEventCard.small(
                  event: events[index],
                  onTap: () => Navigator.pop(context, events[index].id),
                );
              },
            );
          },
        );
      },
    );
  }
}
