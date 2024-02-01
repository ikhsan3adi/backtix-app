import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventDetailTicketCard extends StatelessWidget {
  const EventDetailTicketCard({super.key, required this.ticket});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    final dateStart =
        DateFormat('dd/MM/y').format(ticket.salesOpenDate.toLocal());
    final dateEnd =
        ' - ${DateFormat('dd/MM/y').format(ticket.purchaseDeadline.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
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
                  ? const Center(child: Text('No image'))
                  : CustomNetworkImage(
                      src: ticket.image!,
                      small: true,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendarDay,
                            size: 14,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          const Text('Sales open'),
                        ],
                      ),
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
                          Text('Available stock: ${ticket.currentStock}'),
                        ],
                      ),
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
      ),
    );
  }
}
