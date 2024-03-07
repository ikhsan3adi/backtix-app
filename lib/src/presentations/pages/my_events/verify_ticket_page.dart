import 'dart:io';

import 'package:backtix_app/src/blocs/events/published_event_detail/published_event_detail_cubit.dart';
import 'package:backtix_app/src/blocs/tickets/verify_ticket/verify_ticket_cubit.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class VerifyTicketPage extends StatelessWidget {
  const VerifyTicketPage({super.key, required this.eventId});

  final String eventId;

  static final bool supported = !Platform.isLinux && !Platform.isWindows;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Verify Ticket'),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                GetIt.I<PublishedEventDetailCubit>()..getMyEventDetail(eventId),
          ),
          BlocProvider(create: (_) => GetIt.I<VerifyTicketCubit>()),
        ],
        child: _VerifyTicketPage(eventId: eventId),
      ),
    );
  }
}

class _VerifyTicketPage extends StatefulWidget {
  const _VerifyTicketPage({required this.eventId});

  final String eventId;

  @override
  State<_VerifyTicketPage> createState() => _VerifyTicketPageState();
}

class _VerifyTicketPageState extends State<_VerifyTicketPage> {
  late final MobileScannerController _scannerController;

  final _settingsVisible = ValueNotifier<bool>(true);

  final _autoUse = ValueNotifier<bool>(false);
  final _autoDismiss = ValueNotifier<bool>(false);

  static const double _overlaySize = 250;

  @override
  void initState() {
    super.initState();
    if (VerifyTicketPage.supported) {
      _scannerController = MobileScannerController(
        detectionTimeoutMs: 1950,
        formats: [BarcodeFormat.qrCode],
      );
    }
  }

  @override
  void dispose() {
    _autoUse.dispose();
    _autoDismiss.dispose();
    _settingsVisible.dispose();
    _scannerController.startArguments.dispose();
    _scannerController.cameraFacingState.dispose();
    _scannerController.torchState.dispose();
    _scannerController.hasTorchState.dispose();
    _scannerController.zoomScaleState.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            context.read<PublishedEventDetailCubit>().state.whenOrNull(
              loaded: (event) async {
                final value = capture.barcodes[0].rawValue;
                debugPrint('Barcode found! $value');

                final bloc = context.read<VerifyTicketCubit>();

                // check if no dialog is currently shown (loading, error etc.)
                final isFocused = ModalRoute.of(context)?.isCurrent ?? false;

                if (!bloc.state.isLoading && isFocused && value != null) {
                  if (_autoUse.value) {
                    return await bloc.useTicket(
                      uid: value,
                      eventId: event.id,
                    );
                  }
                  return await bloc.validateTicket(
                    uid: value,
                    eventId: event.id,
                  );
                }
              },
            );
          },
          overlay: CustomPaint(
            size: Size.square(_overlaySize + (context.height / 32)),
            painter: const ScannerOverlayPainter(),
          ),
        ),
        _settings(context),
        Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cameraControls,
              const SizedBox(height: 16),
              _eventDetailPreview,
            ],
          ),
        ),
      ],
    );
  }

  Widget _settings(BuildContext context) {
    return BlocListener<VerifyTicketCubit, VerifyTicketState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () {
            ErrorDialog.hide(context);
            SimpleLoadingDialog.show(context);
          },
          success: (ticket) async {
            SimpleLoadingDialog.hide(context);
            context.read<PublishedEventDetailCubit>().state.whenOrNull(
              loaded: (event) async {
                await TicketVerificationDialog.show(
                  context,
                  ticketPurchase: ticket,
                  onUse: () => context.read<VerifyTicketCubit>().useTicket(
                        uid: ticket.uid,
                        eventId: event.id,
                      ),
                  autoDismiss: _autoDismiss.value,
                );
              },
            );
          },
          failed: (err) async {
            SimpleLoadingDialog.hide(context);
            ErrorDialog.show(context, err);
          },
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.only(bottom: 4, top: 2),
          width: context.width,
          color: Colors.black38,
          child: ValueListenableBuilder(
            valueListenable: _settingsVisible,
            builder: (context, visible, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (visible) ...[
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'After ticket validated',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _autoUse,
                          builder: (context, autoUse, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Auto-use ticket',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Checkbox.adaptive(
                                  value: autoUse,
                                  onChanged: (v) => _autoUse.value = v ?? false,
                                ),
                              ],
                            );
                          },
                        ),
                        ValueListenableBuilder(
                          valueListenable: _autoUse,
                          builder: (context, autoUse, _) {
                            if (!autoUse) {
                              _autoDismiss.value = false;
                              return const SizedBox();
                            }
                            return ValueListenableBuilder(
                              valueListenable: _autoDismiss,
                              builder: (context, autoDismiss, _) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Auto dismiss',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Checkbox.adaptive(
                                      value: autoDismiss,
                                      onChanged: (v) =>
                                          _autoDismiss.value = v ?? false,
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _settingsVisible.value = !visible,
                    onVerticalDragEnd: (drag) {
                      if ((drag.primaryVelocity ?? 0) < 0) {
                        _settingsVisible.value = false;
                      } else if ((drag.primaryVelocity ?? 0) > 0) {
                        _settingsVisible.value = true;
                      }
                    },
                    child: SizedBox(
                      width: context.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Icon(
                          visible
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// flash & camera facing button
  Widget get _cameraControls {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black38,
            foregroundColor: Colors.white,
          ),
          icon: ValueListenableBuilder(
            valueListenable: _scannerController.cameraFacingState,
            builder: (context, state, child) {
              switch (state) {
                case CameraFacing.front:
                  return const Icon(Icons.camera_front_outlined);
                case CameraFacing.back:
                  return const Icon(Icons.camera_rear_outlined);
              }
            },
          ),
          iconSize: 32.0,
          onPressed: () => _scannerController.switchCamera(),
        ),
        const SizedBox(width: 16),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.black38,
            foregroundColor: Colors.white,
          ),
          icon: ValueListenableBuilder(
            valueListenable: _scannerController.torchState,
            builder: (context, state, child) {
              switch (state) {
                case TorchState.off:
                  return const Icon(Icons.flashlight_off_outlined);
                case TorchState.on:
                  return const Icon(
                    Icons.flashlight_on,
                    color: Colors.yellow,
                  );
              }
            },
          ),
          iconSize: 32.0,
          onPressed: () => _scannerController.toggleTorch(),
        ),
      ],
    );
  }

  Widget get _eventDetailPreview {
    return ResponsivePadding(
      child: BlocBuilder<PublishedEventDetailCubit, PublishedEventDetailState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => state.whenOrNull(
              loaded: (event) => _EventDetail.show(
                context,
                event: event,
              ),
            ),
            onVerticalDragEnd: (drag) {
              if ((drag.primaryVelocity ?? 0) < 0) {
                state.whenOrNull(
                  loaded: (event) => _EventDetail.show(
                    context,
                    event: event,
                  ),
                );
              }
            },
            child: Container(
              width: context.width,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.keyboard_arrow_up),
                  const Text(
                    'Event detail',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.maybeWhen(
                      loaded: (event) => event.name,
                      error: (_) => 'Error',
                      orElse: () => 'Loading...',
                    ),
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EventDetail extends StatelessWidget {
  _EventDetail({required this.event});

  static show(BuildContext context, {required EventModel event}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints.loose(const Size.fromHeight(500)),
      builder: (_) => _EventDetail(event: event),
    );
  }

  final dateFormat = DateFormat('dd/MM/y HH:mm');
  final timeZoneName = DateTime(2024).timeZoneName;

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final dateStart =
        '${dateFormat.format(event.date.toLocal())} $timeZoneName';
    final dateEnd = event.endDate == null
        ? ''
        : '${dateFormat.format(event.endDate!.toLocal())} $timeZoneName';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.name,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (event.categories.isNotEmpty)
            Row(
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
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          const Divider(height: 32),
          // Event start date
          DefaultTextStyle.merge(
            style: const TextStyle(fontWeight: FontWeight.w500),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.calendarDay,
                  size: 18,
                  color: context.colorScheme.primary,
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
              style: const TextStyle(fontWeight: FontWeight.w500),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarCheck,
                    size: 18,
                    color: context.colorScheme.primary,
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
          DefaultTextStyle.merge(
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: event.isLatLongSet ? context.colorScheme.primary : null,
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
                      const FaIcon(
                        FontAwesomeIcons.locationDot,
                        size: 18,
                        color: Colors.red,
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
                      color: context.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
