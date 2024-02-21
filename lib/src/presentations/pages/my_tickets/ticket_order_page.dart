import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/tickets/create_ticket_order/create_ticket_order_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/ticket_order/ticket_order_bloc.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/purchase/payment_method_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';

class TicketOrderPage extends StatelessWidget {
  const TicketOrderPage({super.key});

  static Future<void> show(
    BuildContext context, {
    required String eventId,
  }) async {
    context.read<AuthBloc>().add(const AuthEvent.updateUserDetails());
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GetIt.I<TicketOrderBloc>()
              ..add(TicketOrderEvent.init(eventId: eventId)),
          ),
          BlocProvider(
            create: (_) => CreateTicketOrderCubit(),
          ),
        ],
        child: const TicketOrderPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Ticket Order'),
        ),
        body: Column(
          children: [
            const Expanded(child: _TicketList()),
            ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.fromHeight(324)),
              child: Container(
                margin: const EdgeInsets.only(
                  left: 16,
                  top: 8,
                  right: 16,
                  bottom: 100,
                ),
                child: const _PaymentMethodWidget(),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const _BottomWidget(),
        ),
      ),
    );
  }
}

class _TicketList extends StatelessWidget {
  const _TicketList();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: BlocBuilder<TicketOrderBloc, TicketOrderState>(
            builder: (context, state) {
              return state.maybeMap(
                loaded: (state) {
                  if (state.event?.tickets?.isEmpty ?? true) {
                    return const SliverFillRemaining(
                      child: Center(child: NotFoundWidget()),
                    );
                  }
                  return SliverList.separated(
                    itemCount: state.event?.tickets?.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return TicketOrderCard(
                        ticket: state.event!.tickets![index],
                      );
                    },
                  );
                },
                orElse: () {
                  return SliverFillRemaining(
                    child: Center(
                      child: SpinKitFadingFour(
                        color: context.colorScheme.primary,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodWidget extends StatelessWidget {
  const _PaymentMethodWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Choose payment method',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
          builder: (context, order) {
            final balance = context.read<AuthBloc>().state.mapOrNull(
                  authenticated: (s) => s.user.balance?.balance,
                );
            if (order.paymentMethod == PaymentMethod.balance &&
                order.totalPrice > (balance ?? 0)) {
              return const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Insufficient balance, remaining bills will be paid directly',
                ),
              );
            }
            return const SizedBox();
          },
        ),
        const SizedBox(height: 8),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _DirectPaymentCard()),
            SizedBox(width: 8),
            Expanded(child: _BalancePaymentCard()),
          ],
        ),
      ],
    );
  }
}

class _DirectPaymentCard extends StatelessWidget {
  const _DirectPaymentCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
      builder: (context, order) {
        final bloc = context.read<CreateTicketOrderCubit>();
        final bool selected = order.paymentMethod == PaymentMethod.direct;

        final foregroundColor = context.isDark
            ? null
            : selected
                ? Colors.indigo
                : Colors.white;

        return Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    width: 3,
                    color: Colors.blue,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  )
                : null,
            color: selected
                ? Colors.blue.withOpacity(.3)
                : context.theme.disabledColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWelledStack(
            onTap: selected
                ? null
                : () => bloc.changePaymentMethod(PaymentMethod.direct),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foregroundColor,
                      ),
                    ),
                    Text(
                      'QRIS, Gopay, Shopeepay, Credit card etc.',
                      style: TextStyle(color: foregroundColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalancePaymentCard extends StatelessWidget {
  const _BalancePaymentCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
      builder: (context, order) {
        final bloc = context.read<CreateTicketOrderCubit>();
        final bool selected = order.paymentMethod == PaymentMethod.balance;
        final balance = context.watch<AuthBloc>().user?.balance?.balance;

        final foregroundColor = context.isDark
            ? null
            : selected
                ? const Color.fromARGB(255, 36, 124, 39)
                : Colors.white;

        return Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selected
                ? Border.all(
                    width: 3,
                    color: Colors.green,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  )
                : null,
            color: selected
                ? Colors.green.withOpacity(.3)
                : context.theme.disabledColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWelledStack(
            onTap: selected
                ? null
                : () => bloc.changePaymentMethod(PaymentMethod.balance),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance',
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.isDark ? null : foregroundColor,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Current balance: ',
                          ),
                          TextSpan(
                            text: Constant.toCurrency(balance ?? 0),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: context.isDark ? null : foregroundColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// CTA button & total price
class _BottomWidget extends StatelessWidget {
  const _BottomWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subtotal: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
                builder: (_, order) {
                  return Text(
                    Constant.toCurrency(order.totalPrice),
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocConsumer<TicketOrderBloc, TicketOrderState>(
            listener: (_, state) {
              state.mapOrNull(
                loaded: (state) async {
                  if (state.exception != null) {
                    return await ErrorDialog.show(context, state.exception!);
                  }
                  if (state.orderSuccess ?? false) {
                    return Navigator.pop(context);
                  }
                },
              );
            },
            builder: (ctx, state) {
              return FilledButton(
                onPressed: state.maybeMap(
                  orElse: () => null,
                  loaded: (state) => () async {
                    final order = ctx.read<CreateTicketOrderCubit>().state;
                    if (order.purchases.isEmpty) return;

                    final result = await TicketOrderCheckoutDialog.show(
                      context,
                      createOrderCubit: ctx.read<CreateTicketOrderCubit>(),
                      ticketPurchaseBloc: ctx.read<TicketOrderBloc>(),
                    );

                    if ((result ?? false) && context.mounted) {
                      await TicketOrderSuccessDialog.show(context);
                      if (context.mounted) {
                        return Navigator.pop(context, result);
                      }
                    }
                  },
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontSize: 18),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
