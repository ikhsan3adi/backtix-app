import 'package:backtix_app/src/blocs/events/published_event_detail/published_event_detail_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/presentations/pages/webview_page.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({
    super.key,
    required this.id,
    this.name,
    this.heroImageTag,
    this.heroImageUrl,
  });

  final String id;
  final String? name;
  final Object? heroImageTag;
  final String? heroImageUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.I<PublishedEventDetailCubit>()..getPublishedEventDetail(id),
      child: Builder(builder: (context) {
        return Scaffold(
          body: _EventDetailPage(
            id: id,
            name: name,
            heroImageTag: heroImageTag,
            heroImageUrl: heroImageUrl,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ResponsivePadding(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        // TODO: buy ticket
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 22),
                      ),
                      child: const Text(
                        'Get Ticket',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EventDetailPage extends StatefulWidget {
  const _EventDetailPage({
    required this.id,
    this.name,
    this.heroImageTag,
    this.heroImageUrl,
  });

  final String id;
  final String? name;
  final Object? heroImageTag;
  final String? heroImageUrl;

  @override
  State<_EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<_EventDetailPage> {
  final _scrollController = ScrollController();
  final _kExpandedHeight = 450.0;

  final _isAppBarExpanded = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      _isAppBarExpanded.value =
          _scrollController.offset <= _kExpandedHeight - kToolbarHeight;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _isAppBarExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: RefreshIndicator.adaptive(
        onRefresh: () async {
          final bloc = context.read<PublishedEventDetailCubit>();
          bloc.state.mapOrNull(loaded: (state) async {
            await bloc.getPublishedEventDetail(widget.id);
          });
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: _kExpandedHeight,
              centerTitle: true,
              title: ValueListenableBuilder(
                valueListenable: _isAppBarExpanded,
                builder: (_, isExpanded, __) {
                  if (isExpanded) return const SizedBox();
                  return const Text(
                    'Detail',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  );
                },
              ),
              leading: ValueListenableBuilder(
                  valueListenable: _isAppBarExpanded,
                  builder: (_, isExpanded, __) {
                    return IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: isExpanded ? Colors.black38 : null,
                      ),
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: isExpanded ? Colors.white : null,
                      ),
                    );
                  }),
              flexibleSpace: FlexibleSpaceBar(
                background: EventDetailImagesCarousel(
                  heroImageTag: widget.heroImageTag,
                  heroImageUrl: widget.heroImageUrl,
                  height: _kExpandedHeight,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 72,
              ),
              sliver: _EventInfo(name: widget.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfo extends StatefulWidget {
  const _EventInfo({this.name});
  final String? name;

  @override
  State<_EventInfo> createState() => _EventInfoState();
}

class _EventInfoState extends State<_EventInfo> {
  final _isDescExpanded = ValueNotifier(false); // change description max lines
  final _dateFormat = DateFormat('dd/MM/y HH:mm');
  final _timeZoneName = DateTime(2024).timeZoneName; // WIB, WITA, WIT etc.

  @override
  void dispose() {
    _isDescExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PublishedEventDetailCubit, PublishedEventDetailState>(
      listener: (_, state) {
        state.mapOrNull(
          error: (state) => ErrorDialog.show(context, state.exception),
        );
      },
      builder: (context, state) {
        return SliverList.list(
          children: [
            Text(
              state.maybeMap(
                loaded: (state) => state.event.name,
                orElse: () => widget.name ?? 'Unknown',
              ),
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...state.maybeMap(
              orElse: () => _loadingWidget,
              loaded: (state) {
                final event = state.event;
                final dateStart =
                    '${_dateFormat.format(event.date.toLocal())} $_timeZoneName';
                final dateEnd = event.endDate == null
                    ? ''
                    : '${_dateFormat.format(event.endDate!.toLocal())} $_timeZoneName';

                return [
                  _eventDescription(event, context),
                  const Divider(height: 32),

                  // Event start date
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      color: event.isEnded ? context.theme.disabledColor : null,
                      fontWeight: FontWeight.w500,
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDay,
                          size: 18,
                          color: event.isEnded
                              ? context.theme.disabledColor
                              : context.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Start date'),
                        const Spacer(),
                        Text(dateStart),
                      ],
                    ),
                  ),

                  // Event end date
                  if (event.endDate != null) ...[
                    const SizedBox(height: 8),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color:
                            event.isEnded ? context.theme.disabledColor : null,
                        fontWeight: FontWeight.w500,
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendarCheck,
                            size: 18,
                            color: event.isEnded
                                ? context.theme.disabledColor
                                : context.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text('End date'),
                          const Spacer(),
                          Text(dateEnd),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Event location
                  InkWell(
                    onTap: !event.isLatLongSet
                        ? null
                        : () async {
                            await WebViewPage.show(
                              context,
                              url: Constant.googleMapsUrlFromLatLong(
                                lat: event.latitude!,
                                long: event.longitude!,
                              ),
                              title: event.location,
                            );
                          },
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: event.isEnded
                            ? context.theme.disabledColor
                            : event.isLatLongSet
                                ? context.colorScheme.primary
                                : null,
                        decoration: TextDecoration.underline,
                        decorationColor: event.isLatLongSet
                            ? context.colorScheme.primary
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.locationDot,
                                size: 18,
                                color: event.isEnded
                                    ? context.theme.disabledColor
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(event.location),
                            ],
                          ),
                          if (event.isLatLongSet)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.mapLocationDot,
                                color: event.isEnded
                                    ? context.theme.disabledColor
                                    : context.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Event owner user
                  ListTile(
                    onTap: () {}, // TODO: goto user profile?????
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: event.user?.image == null
                          ? null
                          : CachedNetworkImageProvider(event.user!.image!),
                    ),
                    title: Text(
                      event.user?.fullname ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '@${event.user?.username} | ${event.user?.email}',
                    ),
                  ),
                  const Divider(height: 48),

                  // Tickets
                  Text(
                    'Tickets',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    event.tickets?.length ?? 0,
                    (i) => EventDetailTicketCard(ticket: event.tickets![i]),
                  ),
                ];
              },
            ),
          ],
        );
      },
    );
  }

  Widget _eventDescription(EventModel event, BuildContext context) {
    return GestureDetector(
      onTap: () => _isDescExpanded.value = !_isDescExpanded.value,
      child: ValueListenableBuilder(
        valueListenable: _isDescExpanded,
        builder: (_, isDescExpanded, __) {
          return Stack(
            children: [
              Text(
                event.description,
                maxLines: !isDescExpanded ? 4 : 9999999,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isDescExpanded)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          context.colorScheme.surface.withOpacity(0),
                          context.colorScheme.surface,
                        ],
                        stops: const [.3, 1],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> get _loadingWidget {
    return [
      const SizedBox(
        height: 40,
        child: Shimmer(),
      ),
      const Divider(height: 32),
      const SizedBox(
        height: 40,
        child: Shimmer(),
      ),
      const SizedBox(height: 8),
      const SizedBox(
        height: 40,
        child: Shimmer(),
      ),
    ];
  }
}