import 'package:backtix_app/src/blocs/tickets/create_ticket_order/create_ticket_order_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/ticket_purchase/ticket_purchase_bloc.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketOrderCheckoutDialog extends StatelessWidget {
  const TicketOrderCheckoutDialog({super.key});

  static Future<bool?> show(
    BuildContext context, {
    required CreateTicketOrderCubit createOrderCubit,
    required TicketPurchaseBloc ticketPurchaseBloc,
  }) {
    return showDialog<bool>(
      useSafeArea: true,
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: createOrderCubit),
          BlocProvider.value(value: ticketPurchaseBloc),
        ],
        child: const TicketOrderCheckoutDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList.list(
              children: [
                BlocListener<TicketPurchaseBloc, TicketPurchaseState>(
                  listener: (context, state) {
                    state.mapOrNull(
                      loaded: (state) async {
                        if (state.error != null) {
                          return await ErrorDialog.show(context, state.error!);
                        }
                        if (state.orderSuccess != null) {
                          return Navigator.pop(context, state.orderSuccess);
                        }
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Checkout',
                      style: context.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
                  builder: (context, order) {
                    return Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(2),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          children: [
                            TableCell(
                              child: Text(
                                'Item',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Text(
                                'Qty',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TableCell(
                              child: Text(
                                'Subtotal',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...order.purchases.map((e) {
                          return TableRow(
                            children: [
                              TableCell(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.ticket.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      Constant.toCurrency(e.ticket.price),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Text('x${e.quantity}'),
                              ),
                              TableCell(
                                child: Text(
                                  Constant.toCurrency(
                                      e.ticket.price * e.quantity),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        TableRow(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          children: [
                            const TableCell(
                              child: Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const TableCell(child: SizedBox()),
                            TableCell(
                              child: Text(
                                Constant.toCurrency(order.totalPrice),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    final order = context.read<CreateTicketOrderCubit>().state;
                    if (order.purchases.isEmpty) return;

                    context.read<TicketPurchaseBloc>().add(
                          TicketPurchaseEvent.createTicketOrder(order),
                        );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Confirm & Pay'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
