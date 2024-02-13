import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchases_by_event_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PurchasesWithEventCard extends StatelessWidget {
  const PurchasesWithEventCard({
    super.key,
    required this.eventWithPurchases,
    required this.onEventTap,
    required this.onPurchaseTap,
    this.eventHeroImageTag,
  });

  final TicketPurchasesByEventModel eventWithPurchases;
  final VoidCallback onEventTap;
  final void Function(TicketPurchaseModel) onPurchaseTap;
  final Object? eventHeroImageTag;

  @override
  Widget build(BuildContext context) {
    final event = eventWithPurchases.event;
    final purchases = eventWithPurchases.purchases;

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.theme.disabledColor,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: event.status == EventStatus.cancelled
                ? context.colorScheme.errorContainer
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.status == EventStatus.cancelled) ...[
                  Text(
                    'Event cancelled!',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(8),
                  child: _PurchasesEventCard(
                    onEventTap: onEventTap,
                    event: event,
                    heroImageTag: eventHeroImageTag,
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: Text(
              'Your tickets',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            children: List.generate(purchases.length, (index) {
              final purchase = purchases[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: TicketPurchaseCard(
                  purchase: purchase,
                  onTap: onPurchaseTap,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PurchasesEventCard extends StatelessWidget {
  const _PurchasesEventCard({
    required this.onEventTap,
    required this.event,
    this.heroImageTag,
  });

  final VoidCallback onEventTap;
  final EventModel event;
  final Object? heroImageTag;

  @override
  Widget build(BuildContext context) {
    final dateStart = DateFormat('dd/MM/yy').format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${DateFormat('dd/MM/yy').format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return InkWelledStack(
      onTap: onEventTap,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 75,
              width: 75,
              margin: const EdgeInsets.all(1),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.theme.disabledColor,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroImageTag ?? event.id,
                    child: CustomNetworkImage(
                      src: event.images[0].image,
                      small: true,
                    ),
                  ),
                  if (event.isEnded)
                    Container(
                      color: Colors.grey.withAlpha(100),
                      child: const Center(
                        child: Icon(
                          Icons.not_interested_outlined,
                          color: Colors.white70,
                          size: 32,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: event.isEnded ? context.theme.disabledColor : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.calendarDay,
                        size: 18,
                        color: event.isEnded
                            ? context.theme.disabledColor
                            : context.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : null,
                        ),
                      ),
                      if (event.endDate == null) ...[
                        const SizedBox(width: 8),
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 18,
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.Hm().format(event.date.toLocal()),
                          style: TextStyle(
                            color: event.isEnded
                                ? context.theme.disabledColor
                                : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 18,
                        color: event.isEnded
                            ? context.theme.disabledColor
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location,
                        style: TextStyle(
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
