import 'dart:async';

import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketVerificationDialog extends StatelessWidget {
  const TicketVerificationDialog({
    super.key,
    required this.purchase,
    required this.onUse,
    required this.autoDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required TicketPurchaseModel ticketPurchase,
    VoidCallback? onUse,
    bool autoDismiss = false,
  }) async {
    return await showAdaptiveDialog(
      context: context,
      builder: (_) => TicketVerificationDialog(
        purchase: ticketPurchase,
        onUse: onUse,
        autoDismiss: autoDismiss,
      ),
    );
  }

  final TicketPurchaseModel purchase;
  final VoidCallback? onUse;
  final bool autoDismiss;

  /// milliseconds
  static const _autoDismissDelay = 1200;

  @override
  Widget build(BuildContext context) {
    if (autoDismiss) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timer(const Duration(milliseconds: _autoDismissDelay), () {
          return Navigator.pop(context);
        });
      });
    }
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              purchase.used ? 'Ticket used!' : 'Ticket found!',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: purchase.used
                    ? context.colorScheme.error
                    : context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            _qrCode(context),
            MarqueeWidget(
              child: Text(
                'UID: ${purchase.uid}',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.disabledColor,
                ),
              ),
            ),
            const DashedDivider(
              margin: EdgeInsets.symmetric(vertical: 16),
            ),
            _TicketInfo(purchase: purchase),
            Container(
              height: 48,
              margin: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  if (!purchase.used) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          onUse?.call();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'USE',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCode(BuildContext context) {
    return QrImageView(
      data: purchase.uid,
      size: 120,
      backgroundColor: Colors.transparent,
      errorCorrectionLevel: QrErrorCorrectLevel.M,
      padding: const EdgeInsets.only(right: 12),
      dataModuleStyle: QrDataModuleStyle(
        color: context.colorScheme.onSurface,
        dataModuleShape: QrDataModuleShape.square,
      ),
      eyeStyle: QrEyeStyle(
        color: context.colorScheme.onSurface,
        eyeShape: QrEyeShape.square,
      ),
    );
  }
}

class _TicketInfo extends StatelessWidget {
  _TicketInfo({required this.purchase});

  final TicketPurchaseModel purchase;
  final dateFormatter = DateFormat('dd/MM/y');

  @override
  Widget build(BuildContext context) {
    final ticket = purchase.ticket!;

    return DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.w500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ticket.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('User')),
              Flexible(
                child: Text(
                  '@${purchase.user?.username ?? 'Unknown'}',
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                flex: 2,
                child: Text('Price'),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  Utils.toCurrency(ticket.price),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colorScheme.primary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(child: Text('Purchase date')),
              Expanded(
                child: Text(
                  DateFormat('HH:mm:ss dd/MM/y')
                      .format(purchase.createdAt.toLocal()),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order ID'),
              Text(purchase.orderId),
            ],
          ),
        ],
      ),
    );
  }
}
