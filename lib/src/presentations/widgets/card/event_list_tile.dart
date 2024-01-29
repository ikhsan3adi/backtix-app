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
    final dateStart = DateFormat('dd/MM/y').format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${DateFormat('dd/MM/y').format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomNetworkImage(
                        src: event.images[0].image,
                        small: true,
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
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: CustomBadge(
                          margin: const EdgeInsets.all(2),
                          borderColor: Colors.white,
                          fillColor: Colors.black87,
                          strokeWidth: 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: BoxConstraints.loose(
                              const Size.fromWidth(82),
                            ),
                            child: MarqueeWidget(
                              child: Text(
                                '@${event.user?.username ?? 'Unknown'}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        color:
                            event.isEnded ? context.theme.disabledColor : null,
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
                        const SizedBox(width: 8),
                        if (event.endDate == null) ...[
                          FaIcon(
                            FontAwesomeIcons.clock,
                            size: 18,
                            color: event.isEnded
                                ? context.theme.disabledColor
                                : context.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat.Hms().format(event.date.toLocal()),
                            style: TextStyle(
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
                            ),
                          ),
                        ]
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
    final color =
        event.ticketAvailable && !event.isEnded ? Colors.green : Colors.red;
    final colorDarkTheme = event.ticketAvailable && !event.isEnded
        ? Colors.greenAccent
        : Colors.redAccent;

    final String text = event.isEnded
        ? 'Ended'
        : event.ticketAvailable
            ? 'Available'
            : 'Sold out';

    return CustomBadge(
      margin: const EdgeInsets.all(4),
      borderColor: context.isDark ? colorDarkTheme : color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.isDark ? colorDarkTheme : color,
            ),
          ),
        ],
      ),
    );
  }
}
