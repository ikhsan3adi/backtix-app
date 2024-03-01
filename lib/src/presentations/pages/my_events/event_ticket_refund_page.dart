import 'package:backtix_app/src/blocs/tickets/event_ticket_sales/event_ticket_sales_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class EventTicketRefundPage extends StatelessWidget {
  const EventTicketRefundPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<EventTicketSalesCubit>()
        ..getTicketSales(
          eventId,
          const TicketPurchaseQuery(
            page: 0,
            refundStatus: TicketPurchaseRefundStatus.refunding,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Ticket Refund'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: SizedBox(
              height: 50,
              child: _FilterChips(),
            ),
          ),
        ),
        body: const _TicketPurchasesList(),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    TicketPurchaseQuery lastQuery = const TicketPurchaseQuery(
      page: 0,
      refundStatus: TicketPurchaseRefundStatus.refunding,
    );

    return BlocBuilder<EventTicketSalesCubit, EventTicketSalesState>(
      builder: (context, state) {
        final bloc = context.read<EventTicketSalesCubit>();
        final loadedState = state.mapOrNull(loaded: (s) {
          lastQuery = s.query;
          return s;
        });
        final query = loadedState == null
            ? lastQuery
            : loadedState.query.copyWith(page: 0);

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemCount: TicketPurchaseRefundStatus.values.length,
          itemBuilder: (_, index) {
            final filter = TicketPurchaseRefundStatus.values[index];
            return FilterChip(
              selected: query.refundStatus == filter,
              onSelected: (s) async {
                if (loadedState?.eventId == null) return;

                await bloc.getTicketSales(
                  loadedState!.eventId,
                  query.copyWith(refundStatus: s ? filter : null),
                );
              },
              label: Text(filter.toString()),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            );
          },
        );
      },
    );
  }
}

class _TicketPurchasesList extends StatefulWidget {
  const _TicketPurchasesList();

  @override
  State<_TicketPurchasesList> createState() => _TicketPurchasesListState();
}

class _TicketPurchasesListState extends State<_TicketPurchasesList> {
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
  void onScroll() {
    if (_controller.hasClients && context.mounted) {
      double maxScroll = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;

      if (currentScroll >= maxScroll) {
        context.read<EventTicketSalesCubit>().getMoreTicketSales();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<EventTicketSalesCubit>();
        await bloc.state.mapOrNull(loaded: (state) async {
          await bloc.getTicketSales(
            state.eventId,
            state.query.copyWith(page: 0),
          );
        });
      },
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 16),
            sliver: _SliverList(),
          ),
          _loadMoreDataWidget,
        ],
      ),
    );
  }

  Widget get _loadMoreDataWidget {
    return BlocConsumer<EventTicketSalesCubit, EventTicketSalesState>(
      listener: (context, state) => state.mapOrNull(loaded: (s) async {
        if (s.exception != null) {
          return ErrorDialog.show(context, s.exception!);
        }
        return;
      }),
      builder: (context, state) {
        /// If list is not scrollable, get more data immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.position.maxScrollExtent <= 0) {
            context.read<EventTicketSalesCubit>().getMoreTicketSales();
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
    );
  }
}

class _SliverList extends StatelessWidget {
  const _SliverList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventTicketSalesCubit, EventTicketSalesState>(
      builder: (context, state) {
        return state.maybeMap(
          orElse: () {
            return SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => Container(
                height: 75,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Shimmer(),
              ),
            );
          },
          loaded: (state) {
            if (state.purchases.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: NotFoundWidget()),
              );
            }
            return SliverList.separated(
              itemCount: state.purchases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final purchase = state.purchases[index];
                return EventTicketSalesCard(
                  purchase: purchase,
                  onTap: (purchase) => context.pushNamed(
                    RouteNames.eventTicketSalesDetail,
                    pathParameters: {'id': state.eventId, 'uid': purchase.uid},
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
