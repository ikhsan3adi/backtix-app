import 'package:backtix_app/src/blocs/tickets/create_ticket_order/create_ticket_order_cubit.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:intl/intl.dart';

class TicketOrderCard extends StatelessWidget {
  const TicketOrderCard({
    super.key,
    this.event,
    required this.ticket,
  });

  final EventModel? event;
  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final dateStart = (ticket.salesOpenDate ?? event?.date) == null
        ? ''
        : DateFormat('dd/MM/yy')
            .format(ticket.salesOpenDate?.toLocal() ?? event!.date);
    final dateEnd = (ticket.purchaseDeadline ?? event?.endDate) == null
        ? ''
        : ' - ${DateFormat('dd/MM/yy').format(ticket.purchaseDeadline?.toLocal() ?? event!.endDate!)}';

    final dateText = '$dateStart$dateEnd';

    final isAvailable = ticket.status == TicketStatus.available;

    return Row(
      children: [
        BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
          builder: (context, order) {
            final bloc = context.read<CreateTicketOrderCubit>();

            return Checkbox.adaptive(
              value: isAvailable ? order.hasTicketId(ticket.id) : false,
              onChanged: isAvailable ? (_) => bloc.selectTicket(ticket) : null,
            );
          },
        ),
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.all(1),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.disabledColor,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ticket.image == null
              ? const Center(child: TicketImagePlaceholder())
              : CustomNetworkImage(
                  src: ticket.image!,
                  small: true,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        ticket.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        Utils.toSimpleCurrency(ticket.price),
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colorScheme.primary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.calendarDay,
                      size: 14,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(dateText),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.ticket,
                          size: 14,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text('Stock: ${ticket.currentStock}'),
                      ],
                    ),
                    if (isAvailable)
                      _QuantityInput(ticket: ticket)
                    else
                      CustomBadge(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1.5,
                        ),
                        borderColor: switch (ticket.status) {
                          TicketStatus.notOpenedYet => Colors.orange,
                          TicketStatus.available => Colors.green,
                          _ => Colors.red,
                        },
                        child: Text(
                          ticket.status.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: switch (ticket.status) {
                              TicketStatus.notOpenedYet => Colors.orange,
                              TicketStatus.available => Colors.green,
                              _ => Colors.red,
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityInput extends StatelessWidget {
  const _QuantityInput({required this.ticket});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateTicketOrderCubit, CreateTicketOrderState>(
      buildWhen: (p, c) {
        return p.purchases.any((e) => e.ticket.id == ticket.id) !=
            c.purchases.any((e) => e.ticket.id == ticket.id);
      },
      builder: (context, order) {
        return InputQty.int(
          key: ValueKey(order.purchases.any((e) => e.ticket.id == ticket.id)),
          initVal: order.hasTicketId(ticket.id) ? 1 : 0,
          maxVal: ticket.currentStock,
          decoration: QtyDecorationProps(
            iconColor: context.colorScheme.onSurface,
            btnColor: context.colorScheme.onSurface,
            isBordered: false,
            plusBtn: _qtyBtn(context, iconData: Icons.add),
            minusBtn: _qtyBtn(context, iconData: Icons.remove),
          ),
          onQtyChanged: (v) {
            context.read<CreateTicketOrderCubit>().updateOrderQuantity(
                  ticket,
                  quantity: v,
                );
          },
        );
      },
    );
  }

  Widget _qtyBtn(BuildContext context, {required IconData iconData}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: context.colorScheme.secondaryContainer,
      ),
      child: Icon(iconData, size: 17),
    );
  }
}
