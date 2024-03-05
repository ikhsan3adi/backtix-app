import 'package:backtix_app/src/blocs/events/published_event_detail/published_event_detail_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/pages/my_tickets/ticket_order_page.dart';
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
    this.isPublishedEvent = true,
  });

  final bool isPublishedEvent;

  final String id;
  final String? name;
  final Object? heroImageTag;
  final String? heroImageUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        if (isPublishedEvent) {
          return GetIt.I<PublishedEventDetailCubit>()
            ..getPublishedEventDetail(id);
        }
        return GetIt.I<PublishedEventDetailCubit>()..getMyEventDetail(id);
      },
      child: Builder(builder: (context) {
        return Scaffold(
          body: _EventDetailPage(
            id: id,
            name: name,
            heroImageTag: heroImageTag,
            heroImageUrl: heroImageUrl,
            isPublishedEvent: isPublishedEvent,
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: ResponsivePadding(
            child: isPublishedEvent ? _ctaButton : _ownerCtaButton(context),
          ),
        );
      }),
    );
  }

  Widget get _ctaButton {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: BlocBuilder<PublishedEventDetailCubit,
                PublishedEventDetailState>(
              builder: (context, state) {
                return FilledButton(
                  onPressed: state.maybeMap(
                    loaded: (state) => state.event.isEnded
                        ? null
                        : () async => await TicketOrderPage.show(
                              context,
                              eventId: state.event.id,
                            ),
                    orElse: () => null,
                  ),
                  child: Text(
                    state.whenOrNull(
                          loaded: (e) =>
                              e.isEnded ? 'Event has ended' : 'Get Ticket',
                        ) ??
                        'Loading',
                    style: const TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _ownerCtaButton(BuildContext context) {
    return Container(
      height: 136,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => context.goNamed(
                RouteNames.verifyTicket,
                pathParameters: {'id': id},
              ),
              icon: const Icon(Icons.qr_code_scanner_outlined),
              label: const Text(
                'Scan Ticket',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => context.goNamed(
                      RouteNames.eventTicketRefundRequest,
                      pathParameters: {'id': id},
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colorScheme.errorContainer,
                    ),
                    child: Text(
                      'Ticket refund request',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.goNamed(
                      RouteNames.eventTicketSales,
                      pathParameters: {'id': id},
                    ),
                    icon: const FaIcon(
                      FontAwesomeIcons.ticket,
                      size: 18,
                    ),
                    label: const Text(
                      'Ticket sales',
                      style: TextStyle(fontSize: 16),
                    ),
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

class _EventDetailPage extends StatefulWidget {
  const _EventDetailPage({
    required this.id,
    this.name,
    this.heroImageTag,
    this.heroImageUrl,
    required this.isPublishedEvent,
  });

  final String id;
  final String? name;
  final Object? heroImageTag;
  final String? heroImageUrl;

  final bool isPublishedEvent;

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
          await bloc.state.mapOrNull(loaded: (state) async {
            widget.isPublishedEvent
                ? await bloc.getPublishedEventDetail(widget.id)
                : await bloc.getMyEventDetail(widget.id);
          });
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
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
                },
              ),
              actions: [
                if (!widget.isPublishedEvent)
                  SizedBox(
                    height: kToolbarHeight,
                    width: kToolbarHeight,
                    child: ValueListenableBuilder(
                      valueListenable: _isAppBarExpanded,
                      builder: (_, isExpanded, __) {
                        return IconButton(
                          onPressed: () => context.goNamed(
                            RouteNames.editEvent,
                            pathParameters: {'id': widget.id},
                          ),
                          tooltip: 'Edit',
                          style: IconButton.styleFrom(
                            backgroundColor: isExpanded ? Colors.black38 : null,
                          ),
                          icon: Icon(
                            Icons.edit,
                            color: isExpanded ? Colors.white : null,
                          ),
                        );
                      },
                    ),
                  ),
              ],
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
                bottom: 156,
              ),
              sliver: _EventInfo(
                name: widget.name,
                isPublishedEvent: widget.isPublishedEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfo extends StatefulWidget {
  const _EventInfo({this.name, required this.isPublishedEvent});
  final String? name;
  final bool isPublishedEvent;

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
            state.maybeWhen(
              loaded: (event) => Row(
                children: [
                  const Text('Categories:  '),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 30,
                      child: ListView.separated(
                        itemCount: event.categories.length,
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (_, __) => const SizedBox(width: 6),
                        itemBuilder: (_, index) {
                          final category = event.categories[index];
                          return Chip(
                            label: Text(
                              category,
                              style: context.textTheme.labelMedium,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              orElse: () => const SizedBox(height: 12),
            ),
            ...state.maybeWhen(
              orElse: () => _loadingWidget,
              loaded: (event) => _loadedWIdgets(context, event),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _loadedWIdgets(
    BuildContext context,
    EventModel event,
  ) {
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
            color: event.isEnded ? context.theme.disabledColor : null,
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
                await WebViewPage.showAsBottomSheet(
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
            decorationColor:
                event.isLatLongSet ? context.colorScheme.primary : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                    Flexible(
                      child: Text(
                        event.location,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
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
      const SizedBox(height: 14),
      if (!widget.isPublishedEvent)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: AddTicketCard(
            size: 75,
            onTap: () async {
              final success = await UpsertTicketDialog.show(
                context,
                eventId: event.id,
              );
              if ((success ?? false) && context.mounted) {
                context
                    .read<PublishedEventDetailCubit>()
                    .getMyEventDetail(event.id);
              }
            },
          ),
        ),
      ...event.tickets!.map(
        (ticket) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: EventDetailTicketCard(
            event: event,
            ticket: ticket,
            onTap: widget.isPublishedEvent
                ? null
                : () => context.goNamed(
                      RouteNames.salesByTicket,
                      pathParameters: {
                        'id': event.id,
                        'ticketId': ticket.id,
                      },
                    ),
            onEdit: widget.isPublishedEvent
                ? null
                : () async {
                    final edited = await UpsertTicketDialog.show(
                      context,
                      ticket: ticket,
                    );
                    if (context.mounted && (edited ?? false)) {
                      context
                          .read<PublishedEventDetailCubit>()
                          .getMyEventDetail(event.id);
                    }
                  },
          ),
        ),
      ),
    ];
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
