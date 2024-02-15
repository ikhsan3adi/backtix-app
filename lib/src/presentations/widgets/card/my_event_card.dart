import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/event_status_enum.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class MyEventCard extends StatelessWidget {
  const MyEventCard({
    super.key,
    required this.event,
    this.onTap,
    this.heroImageTag,
  });

  final EventModel event;
  final VoidCallback? onTap;
  final Object? heroImageTag;

  @override
  Widget build(BuildContext context) {
    final dateStart = DateFormat('dd/MM/y').format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${DateFormat('dd/MM/y').format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            constraints: const BoxConstraints(minHeight: 120),
            child: InkWelledStack(
              onTap: onTap,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.all(1),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.theme.disabledColor,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Hero(
                        tag: heroImageTag ?? event.id,
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
                              color: event.isEnded
                                  ? context.theme.disabledColor
                                  : null,
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
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Text('Status'),
                              const SizedBox(width: 4),
                              _StatusBadge(event: event),
                            ],
                          ),
                          const SizedBox(height: 6),
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
            ),
          ),
        ),
        PopupMenuButton(
          itemBuilder: (_) => [
            PopupMenuItem(
              child: const ListTile(
                title: Text('Edit'),
                trailing: Icon(Icons.edit),
              ),
              onTap: () {
                // TODO goto edit event page
              },
            ),
            if (event.status != EventStatus.published)
              PopupMenuItem(
                child: ListTile(
                  title: const Text('Delete'),
                  trailing: const Icon(Icons.delete_forever),
                  textColor: context.colorScheme.error,
                  iconColor: context.colorScheme.error,
                ),
                onTap: () {},
              ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final String text = event.isEnded
        ? 'Ended'
        : event.isOnGoing || event.status != EventStatus.published
            ? event.status.toString()
            : 'Not Started';

    return CustomBadge(
      borderColor: getColor(context.isDark),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: getColor(context.isDark),
        ),
      ),
    );
  }

  Color getColor(bool isDark) {
    final color = event.isEnded
        ? Colors.red
        : event.isOnGoing || event.status != EventStatus.published
            ? switch (event.status) {
                EventStatus.draft => Colors.yellow,
                EventStatus.published => Colors.green,
                EventStatus.cancelled => Colors.red,
                EventStatus.rejected => Colors.red,
              }
            : Colors.yellowAccent;

    final colorDarkTheme = event.isEnded
        ? Colors.redAccent
        : event.isOnGoing || event.status != EventStatus.published
            ? switch (event.status) {
                EventStatus.draft => Colors.yellowAccent,
                EventStatus.published => Colors.greenAccent,
                EventStatus.cancelled => Colors.redAccent,
                EventStatus.rejected => Colors.redAccent,
              }
            : Colors.yellowAccent;

    return isDark ? colorDarkTheme : color;
  }
}
