import 'package:backtix_app/src/blocs/events/published_events/published_events_bloc.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class UpcomingEventsCarousel extends StatelessWidget {
  UpcomingEventsCarousel({super.key});

  final CarouselController _carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublishedEventsBloc, PublishedEventsState>(
      builder: (_, state) {
        if (state.mapOrNull(loaded: (s) => s.events)?.isEmpty ?? false) {
          return Container(
            height: 300,
            margin: const EdgeInsets.only(left: 16, right: 16),
            decoration: BoxDecoration(
              color: context.isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: NotFoundWidget()),
          );
        }
        return CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            height: 300,
            enableInfiniteScroll: false,
            padEnds: false,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            enlargeFactor: 0.25,
          ),
          items: state.maybeMap(
            orElse: () {
              return List.generate(2, (index) {
                return Shimmer(
                  child: Container(
                    height: 300,
                    margin: EdgeInsets.only(
                      left: 16,
                      right: index == 1 ? 16 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              });
            },
            loaded: (state) {
              final events = state.events.take(5).toList();
              return List.generate(
                events.length,
                (index) {
                  return _EventCard(
                    onTap: () {
                      // TODO goto event detail
                    },
                    event: events[index],
                    margin: EdgeInsets.only(
                      left: 16,
                      right: index == events.length - 1 ? 16 : 0,
                    ),
                    height: 300,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    this.margin,
    this.onTap,
    this.height,
  });

  final EventModel event;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        margin: const EdgeInsets.all(1),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(
            color: context.theme.disabledColor,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWelledStack(
          onTap: onTap,
          alignment: Alignment.bottomLeft,
          children: [
            SizedBox(
              height: height,
              width: double.infinity,
              child: CustomNetworkImage(src: event.images[0].image),
            ),
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black26.withBlue(20).withGreen(10),
                    Colors.black54.withBlue(50).withGreen(30),
                    Colors.black87.withBlue(50).withGreen(30),
                  ],
                  stops: const [0, 0.5, 0.6, 0.7, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.name,
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/y').format(event.date.toLocal()),
                        ),
                        const SizedBox(width: 8),
                        const FaIcon(
                          FontAwesomeIcons.clock,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(DateFormat.Hms().format(event.date.toLocal())),
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
            ),
            Align(
              alignment: Alignment.topRight,
              child: CustomBadge(
                margin: const EdgeInsets.all(8),
                borderColor: event.ticketAvailable
                    ? Colors.greenAccent
                    : Colors.redAccent,
                fillColor: event.ticketAvailable
                    ? Colors.black54.withGreen(50)
                    : Colors.black54.withRed(50),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.ticketAvailable ? 'Available' : 'Sold out',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: event.ticketAvailable
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}