import 'package:backtix_app/src/blocs/tickets/ticket_sales/ticket_sales_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SalesByTicketPage extends StatelessWidget {
  const SalesByTicketPage({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<TicketSalesCubit>()
        ..getTicketSales(
          ticketId,
          const TicketPurchaseQuery(
            page: 0,
            status: TicketPurchaseStatus.completed,
          ),
        ),
      child: const Scaffold(body: _SalesByTicket()),
    );
  }
}

class _SalesByTicket extends StatefulWidget {
  const _SalesByTicket();

  @override
  State<_SalesByTicket> createState() => _SalesByTicketState();
}

class _SalesByTicketState extends State<_SalesByTicket> {
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
        context.read<TicketSalesCubit>().getMoreTicketSales();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<TicketSalesCubit>();
        await bloc.state.mapOrNull(loaded: (state) async {
          await bloc.getTicketSales(
            state.ticketId,
            state.query.copyWith(page: 0),
          );
        });
      },
      child: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            centerTitle: true,
            pinned: true,
            floating: true,
            title: const Text('Ticket Sales'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(120),
              child: BlocBuilder<TicketSalesCubit, TicketSalesState>(
                builder: (context, state) {
                  return state.maybeMap(
                    orElse: () => Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Shimmer(),
                    ),
                    loaded: (state) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: EventDetailTicketCard(
                          ticket: state.purchasesWithTicket.ticket,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 4,
              right: 16,
              bottom: 16,
            ),
            sliver: BlocBuilder<TicketSalesCubit, TicketSalesState>(
              builder: (context, state) {
                return state.maybeMap(
                  orElse: () {
                    return SliverList.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, __) => Container(
                        height: 100,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Shimmer(),
                      ),
                    );
                  },
                  loaded: (state) {
                    if (state.purchasesWithTicket.purchases.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: NotFoundWidget()),
                      );
                    }
                    final purchases = state.purchasesWithTicket.purchases;
                    return SliverList.separated(
                      itemCount: purchases.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final purchase = purchases[index];
                        return TicketSalesCard(
                          purchase: purchase,
                          ticket: state.purchasesWithTicket.ticket,
                          onTap: (purchase) => context.pushNamed(
                            RouteNames.eventTicketSalesDetail,
                            pathParameters: {
                              'id': state.ticketId,
                              'uid': purchase.uid
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          _loadMoreDataWidget,
        ],
      ),
    );
  }

  Widget get _loadMoreDataWidget {
    return BlocConsumer<TicketSalesCubit, TicketSalesState>(
      listener: (context, state) => state.mapOrNull(loaded: (s) async {
        if (s.exception != null) {
          return await ErrorDialog.show(context, s.exception!);
        }
        return null;
      }),
      builder: (context, state) {
        /// If list is not scrollable, get more data immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_controller.position.maxScrollExtent <= 0) {
            context.read<TicketSalesCubit>().getMoreTicketSales();
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
