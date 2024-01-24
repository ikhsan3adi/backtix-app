import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class EventListTile extends StatelessWidget {
  const EventListTile({
    super.key,
    required this.event,
    this.onTap,
  });

  final EventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWelledStack(
        onTap: onTap,
        children: [
          Row(
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
                  child: CustomNetworkImage(
                    src: event.images[0].image,
                    small: true,
                  ),
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
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 18,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/y').format(event.date.toLocal()),
                        ),
                        const SizedBox(width: 8),
                        FaIcon(
                          FontAwesomeIcons.clock,
                          size: 18,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat.Hms().format(event.date.toLocal()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.locationDot,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(event.location),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: _TicketAvailableBadge(event: event),
          ),
        ],
      ),
    );
  }
}

class _TicketAvailableBadge extends StatelessWidget {
  const _TicketAvailableBadge({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final color = event.ticketAvailable ? Colors.green : Colors.red;
    final colorDarkTheme =
        event.ticketAvailable ? Colors.greenAccent : Colors.redAccent;

    return CustomBadge(
      margin: const EdgeInsets.all(4),
      borderColor: context.isDark ? colorDarkTheme : color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            event.ticketAvailable ? 'Available' : 'Sold out',
            style: context.textTheme.labelSmall?.copyWith(
              color: context.isDark ? colorDarkTheme : color,
            ),
          ),
        ],
      ),
    );
  }
}
