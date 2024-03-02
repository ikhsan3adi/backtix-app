import 'package:backtix_app/src/blocs/tickets/my_ticket_purchases/my_ticket_purchases_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TicketPurchaseList extends StatefulWidget {
  const TicketPurchaseList({super.key});

  @override
  State<TicketPurchaseList> createState() => _TicketPurchaseListState();
}

class _TicketPurchaseListState extends State<TicketPurchaseList> {
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
        context.read<MyTicketPurchasesBloc>().add(
              const MyTicketPurchasesEvent.getMoreTicketPurchases(),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<MyTicketPurchasesBloc>();
        bloc.state.mapOrNull(loaded: (state) {
          bloc.add(MyTicketPurchasesEvent.getMyTicketPurchases(
            state.query.copyWith(page: 0),
          ));
        });
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller,
        slivers: [
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 100),
            sliver: _PurchasesList(),
          ),
          BlocBuilder<MyTicketPurchasesBloc, MyTicketPurchasesState>(
            builder: (context, state) {
              /// If list is not scrollable, get more data immediately
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_controller.position.maxScrollExtent <= 0) {
                  context.read<MyTicketPurchasesBloc>().add(
                        const MyTicketPurchasesEvent.getMoreTicketPurchases(),
                      );
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

class _PurchasesList extends StatelessWidget {
  const _PurchasesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyTicketPurchasesBloc, MyTicketPurchasesState>(
      builder: (context, state) {
        return state.maybeMap(
          orElse: () {
            return SliverList.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => Container(
                height: 150,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Shimmer(),
              ),
            );
          },
          loaded: (state) {
            if (state.purchasesWithEvent.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: NotFoundWidget()),
              );
            }
            return SliverList.separated(
              itemCount: state.purchasesWithEvent.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final eventWithPurchases = state.purchasesWithEvent[index];
                final heroImageTag = UniqueKey().toString();
                return PurchasesWithEventCard(
                  eventWithPurchases: eventWithPurchases,
                  eventHeroImageTag: heroImageTag,
                  onEventTap: () => context.pushNamed(
                    RouteNames.eventDetail,
                    pathParameters: {'id': eventWithPurchases.event.id},
                    queryParameters: {
                      'name': eventWithPurchases.event.name,
                      'heroImageTag': heroImageTag,
                      if (eventWithPurchases.event.images.isNotEmpty)
                        'heroImageUrl':
                            eventWithPurchases.event.images[0].image,
                    },
                  ),
                  onPurchaseTap: (purchase) {
                    if (purchase.refundStatus !=
                        TicketPurchaseRefundStatus.refunded) {
                      context.pushNamed(
                        RouteNames.myTicketDetail,
                        pathParameters: {'uid': purchase.uid},
                      );
                    }
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
