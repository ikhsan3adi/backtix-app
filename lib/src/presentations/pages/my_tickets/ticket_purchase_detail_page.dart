import 'dart:io';

import 'package:backtix_app/src/blocs/tickets/my_ticket_purchase_detail/my_ticket_purchase_detail_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class TicketPurchaseDetailPage extends StatelessWidget {
  const TicketPurchaseDetailPage({
    super.key,
    required this.uid,
    this.asEventOwner = false,
  });

  final String uid;
  final bool asEventOwner;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return GetIt.I<MyTicketPurchaseDetailCubit>()
          ..getTicketPurchaseDetail(uid);
      },
      child: Builder(builder: (context) {
        return BlocBuilder<MyTicketPurchaseDetailCubit,
            MyTicketPurchaseDetailState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: state.maybeWhen(
                loaded: (p) {
                  if (p.refundStatus == TicketPurchaseRefundStatus.refunded) {
                    return context.colorScheme.errorContainer;
                  }
                  return context.colorScheme.inversePrimary;
                },
                orElse: () => context.colorScheme.inversePrimary,
              ),
              body: ResponsivePadding(
                child: _TicketPurchaseDetail(
                  uid: uid,
                  asEventOwner: asEventOwner,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _TicketPurchaseDetail extends StatelessWidget {
  const _TicketPurchaseDetail({required this.uid, required this.asEventOwner});

  final String uid;
  final bool asEventOwner;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        final bloc = context.read<MyTicketPurchaseDetailCubit>();
        bloc.state.mapOrNull(loaded: (state) async {
          await bloc.getTicketPurchaseDetail(uid);
        });
      },
      child: CustomScrollView(
        slivers: [
          BlocBuilder<MyTicketPurchaseDetailCubit, MyTicketPurchaseDetailState>(
            builder: (context, state) {
              return SliverAppBar(
                centerTitle: true,
                title: Text(
                  state.maybeWhen(
                    loaded: (p) => switch (p.refundStatus) {
                      TicketPurchaseRefundStatus.refunded =>
                        'Ticket (Refunded)',
                      _ => 'Ticket',
                    },
                    orElse: () => 'Ticket',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                foregroundColor: state.maybeWhen(
                  loaded: (p) {
                    if (p.refundStatus == TicketPurchaseRefundStatus.refunded) {
                      return context.colorScheme.onErrorContainer;
                    }
                    return context.colorScheme.onSurface;
                  },
                  orElse: () => context.colorScheme.onSurface,
                ),
                backgroundColor: state.maybeWhen(
                  loaded: (p) {
                    if (p.refundStatus == TicketPurchaseRefundStatus.refunded) {
                      return context.colorScheme.errorContainer;
                    }
                    return context.colorScheme.inversePrimary;
                  },
                  orElse: () => context.colorScheme.inversePrimary,
                ),
                // forceMaterialTransparency: true,
              );
            },
          ),
          BlocConsumer<MyTicketPurchaseDetailCubit,
              MyTicketPurchaseDetailState>(
            listener: (_, state) {
              state.mapOrNull(
                error: (state) => ErrorDialog.show(context, state.exception),
              );
            },
            builder: (context, state) {
              return state.map(
                error: (state) => _errorWidget(
                  context,
                  exception: state.exception as DioException,
                ),
                loading: (_) => _loadingWidget(context),
                loaded: (state) {
                  final ticketPurchase = state.ticketPurchase;

                  final ticketWidget = TicketWidget(
                    ticketPurchase: ticketPurchase,
                  );

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    sliver: SliverList.list(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Flexible(child: ticketWidget)],
                        ),
                        asEventOwner
                            ? _EventOwnerButtons(purchase: ticketPurchase)
                            : _Buttons(
                                ticketPurchase: ticketPurchase,
                                ticketWidget: ticketWidget,
                              ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: SpinKitFadingFour(
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _errorWidget(
    BuildContext context, {
    required DioException exception,
  }) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_outlined,
              color: context.colorScheme.error,
              size: 52,
            ),
            const SizedBox(height: 4),
            Text(
              exception.response?.data['message'] ?? exception.message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({
    required this.ticketPurchase,
    required this.ticketWidget,
  });

  final TicketPurchaseModel ticketPurchase;
  final TicketWidget ticketWidget;

  Future<void> _shareTicket(
    BuildContext context, {
    required TicketPurchaseModel ticketPurchase,
    required Widget ticketWidget,
  }) async {
    try {
      final ScreenshotController screenshotController = ScreenshotController();

      Screenshot(
        controller: screenshotController,
        child: ticketWidget,
      );

      final image = await screenshotController.captureFromWidget(
        ticketWidget,
        context: context,
        pixelRatio: 2.5,
      );

      final dir = Platform.isAndroid || Platform.isIOS
          ? await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory()
          : await getApplicationDocumentsDirectory();
      final path = '${dir.path}${Platform.pathSeparator}BackTix';

      if (!Directory(path).existsSync()) {
        Directory(path).createSync(recursive: true);
      }

      final filename = '${ticketPurchase.uid}_${ticketPurchase.orderId}.png';
      final imageFile = await File('$path${Platform.pathSeparator}$filename')
          .writeAsBytes(image);

      if (Platform.isLinux && context.mounted) {
        return context.showSimpleTextSnackBar(
          'Sharing files is not supported on ${Platform.operatingSystem}',
        );
      }

      final uid = ticketPurchase.uid;
      final ticketName = ticketPurchase.ticket?.name;
      final event = ticketPurchase.ticket?.event;
      final eventName = event?.name;
      final eventLocationUrl = event!.isLatLongSet
          ? Constant.googleMapsUrlFromLatLong(
              lat: event.latitude!,
              long: event.longitude!,
            )
          : null;

      final shareText =
          '$eventName\n$ticketName\nUID: $uid\nLocation: $eventLocationUrl';

      final result = await Share.shareXFiles(
        [
          XFile(
            imageFile.path,
            bytes: imageFile.readAsBytesSync(),
            length: imageFile.lengthSync(),
          ),
        ],
        text: shareText,
      );

      if (context.mounted) {
        if (result.status == ShareResultStatus.success) return;

        return context.showSimpleTextSnackBar('Failed to share ticket');
      }
    } catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        return context.showSimpleTextSnackBar(
          'Failed to share ticket\nError:$e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () async => await _shareTicket(
                context,
                ticketPurchase: ticketPurchase,
                ticketWidget: ticketWidget,
              ),
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ),
          if (ticketPurchase.refundStatus == null) ...[
            const SizedBox(width: 8),
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: context.colorScheme.onPrimaryContainer,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () async {
                    await ConfirmTicketRefundDialog.show(
                      context,
                      ticketPurchase: ticketPurchase,
                      onConfirm: (cubit) async {
                        return await cubit.refundTicketPurchase(
                          ticketPurchase.uid,
                        );
                      },
                    ).then((refunded) {
                      if (refunded ?? false) {
                        Toast.show(
                          context,
                          msg: 'Refund request successful',
                        );
                        context.pop(true);
                      }
                    });
                  },
                  child: Text(
                    'Refund ticket purchase',
                    style: TextStyle(color: context.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EventOwnerButtons extends StatelessWidget {
  const _EventOwnerButtons({required this.purchase});

  final TicketPurchaseModel purchase;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (purchase.refundStatus != TicketPurchaseRefundStatus.refunded &&
              purchase.status == TicketPurchaseStatus.completed)
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  await ConfirmTicketRefundDialog.show(
                    context,
                    ticketPurchase: purchase,
                    titleText: 'Accept Refund Confirmation',
                    buttonText: 'Confirm & Accept',
                    confirmText:
                        'Are you sure you want to reject the refund request?',
                    onConfirm: (cubit) async {
                      return await cubit.acceptTicketRefund(
                        purchase.uid,
                      );
                    },
                  ).then((success) {
                    if (success ?? false) {
                      Toast.show(
                        context,
                        msg: 'Accept refund request successful',
                      );
                      context.pop(true);
                    }
                  });
                },
                style: purchase.refundStatus == null
                    ? FilledButton.styleFrom(
                        backgroundColor: context.colorScheme.error,
                        foregroundColor: context.colorScheme.onError,
                      )
                    : null,
                child: Text(
                  purchase.refundStatus != null
                      ? 'Accept Refund Request'
                      : 'Cancel & Refund ticket',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (purchase.refundStatus ==
              TicketPurchaseRefundStatus.refunding) ...[
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  await ConfirmTicketRefundDialog.show(
                    context,
                    ticketPurchase: purchase,
                    titleText: 'Refuse Refund Confirmation',
                    buttonText: 'Confirm & Reject',
                    onConfirm: (cubit) async {
                      return await cubit.rejectTicketRefund(
                        purchase.uid,
                      );
                    },
                  ).then((success) {
                    if (success ?? false) {
                      Toast.show(
                        context,
                        msg: 'Successfully refused refund request',
                      );
                      context.pop(true);
                    }
                  });
                },
                style: FilledButton.styleFrom(
                  backgroundColor: context.colorScheme.errorContainer,
                  foregroundColor: context.colorScheme.onErrorContainer,
                ),
                child: const Text(
                  'Refuse Refund Request',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
