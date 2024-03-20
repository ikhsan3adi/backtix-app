import 'package:backtix_app/src/blocs/user/my_withdraw_requests/my_withdraw_requests_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/withdraw/withdraw_status_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyWithdrawRequestsPage extends StatelessWidget {
  const MyWithdrawRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<MyWithdrawRequestsCubit>()
        ..getMyWithdrawRequests(WithdrawStatus.pending),
      child: Builder(builder: (context) {
        return Scaffold(
          body: RefreshIndicator.adaptive(
            onRefresh: () async {
              final bloc = context.read<MyWithdrawRequestsCubit>();
              bloc.state.mapOrNull(loaded: (state) {
                bloc.getMyWithdrawRequests(state.status);
              });
            },
            child: const _MyWithdrawRequestsScreen(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            foregroundColor: context.colorScheme.primary,
            onPressed: () async {
              final bool? refresh = await context.pushNamed(
                RouteNames.withdraw,
              );
              if (context.mounted && (refresh ?? false)) {
                final bloc = context.read<MyWithdrawRequestsCubit>();
                bloc.state.mapOrNull(loaded: (state) {
                  bloc.getMyWithdrawRequests(state.status);
                });
              }
            },
            label: const Text('New Withdraw Request'),
            icon: const Icon(Icons.payments_outlined),
          ),
        );
      }),
    );
  }
}

class _MyWithdrawRequestsScreen extends StatefulWidget {
  const _MyWithdrawRequestsScreen();

  @override
  State<_MyWithdrawRequestsScreen> createState() =>
      _MyWithdrawRequestsScreenState();
}

class _MyWithdrawRequestsScreenState extends State<_MyWithdrawRequestsScreen> {
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
        context.read<MyWithdrawRequestsCubit>().getMoreMyWithdrawRequests();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _controller,
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: true,
          centerTitle: true,
          title: const Text('My Withdraw Requests'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: SizedBox(
              height: 50,
              child: _FilterChips(),
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 72),
          sliver: _WithdrawRequestList(),
        ),
        BlocBuilder<MyWithdrawRequestsCubit, MyWithdrawRequestsState>(
          builder: (context, state) {
            /// If list is not scrollable, get more data immediately
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_controller.position.maxScrollExtent <= 0) {
                context
                    .read<MyWithdrawRequestsCubit>()
                    .getMoreMyWithdrawRequests();
              }
            });

            return state.maybeMap(
              loaded: (state) {
                return SliverFillRemaining(
                  fillOverscroll: true,
                  hasScrollBody: false,
                  child: LoadNewListDataWidget(reachedMax: state.hasReachedMax),
                );
              },
              orElse: () => const SliverToBoxAdapter(),
            );
          },
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('dd/MM/y');

  @override
  Widget build(BuildContext context) {
    WithdrawStatus? lastStatus = WithdrawStatus.pending;

    return BlocBuilder<MyWithdrawRequestsCubit, MyWithdrawRequestsState>(
      builder: (context, state) {
        final bloc = context.read<MyWithdrawRequestsCubit>();
        final loadedState = state.mapOrNull(loaded: (s) {
          lastStatus = s.status;
          return s;
        });
        final query = loadedState == null ? lastStatus : loadedState.status;

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: WithdrawStatus.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final status = WithdrawStatus.values[index];
            return FilterChip(
              selected: query == status,
              label: Text(status.value),
              onSelected: (v) => bloc.getMyWithdrawRequests(v ? status : null),
            );
          },
        );
      },
    );
  }
}

class _WithdrawRequestList extends StatelessWidget {
  const _WithdrawRequestList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyWithdrawRequestsCubit, MyWithdrawRequestsState>(
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
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, __) => const SizedBox(
                height: 75,
                child: Shimmer(),
              ),
            );
          },
          loaded: (state) {
            if (state.withdraws.isEmpty) {
              return const SliverFillRemaining(
                child: Center(child: NotFoundWidget()),
              );
            }

            final DateFormat dateFormat = DateFormat('dd/MM/y HH:mm:ss');
            final withdraws = state.withdraws;

            return SliverList.separated(
              itemCount: withdraws.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final withdraw = withdraws[index];

                return ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: Icon(
                    switch (withdraw.status) {
                      WithdrawStatus.pending => Icons.hourglass_bottom,
                      WithdrawStatus.completed => Icons.check,
                      WithdrawStatus.rejected => Icons.close,
                    },
                    color: switch (withdraw.status) {
                      WithdrawStatus.pending => Colors.orange,
                      WithdrawStatus.completed => Colors.green,
                      WithdrawStatus.rejected => context.colorScheme.error,
                    },
                  ),
                  title: Text(withdraw.method),
                  subtitle: Text('From: ${withdraw.from.value}'),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Utils.toCurrency(withdraw.amount),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.primary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        'Admin fee: -${Utils.toCurrency(withdraw.fee)}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.error,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                  children: [
                    if (withdraw.createdAt != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date'),
                          const SizedBox(width: 16),
                          Text(
                            dateFormat.format(withdraw.createdAt!),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    if (withdraw.updatedAt != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last update'),
                          const SizedBox(width: 16),
                          Text(
                            dateFormat.format(withdraw.updatedAt!),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(child: Text('Details ')),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Text(
                            withdraw.details,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
