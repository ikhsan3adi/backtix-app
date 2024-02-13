import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketWidget extends StatelessWidget {
  const TicketWidget({
    super.key,
    required this.ticketPurchase,
  });

  final TicketPurchaseModel ticketPurchase;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipBehavior: Clip.hardEdge,
      clipper: TicketClipper(
        holeRadius: 35,
        top: 431,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            QrImageView(
              data: ticketPurchase.uid,
              size: 350,
              backgroundColor: Colors.transparent,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: context.colorScheme.onSurface,
                dataModuleShape: QrDataModuleShape.square,
              ),
              eyeStyle: QrEyeStyle(
                color: context.colorScheme.onSurface,
                eyeShape: QrEyeShape.square,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: MarqueeWidget(
                child: Text(
                  'UID: ${ticketPurchase.uid}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.disabledColor,
                  ),
                ),
              ),
            ),
            const DashedDivider(
              margin: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: _TicketInfo(purchase: ticketPurchase),
            ),
          ],
        ),
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
    final event = ticket.event!;
    final dateStart = dateFormatter.format(event.date.toLocal());
    final dateEnd = event.endDate == null
        ? ''
        : ' - ${dateFormatter.format(event.endDate!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.w500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 19,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
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
              const Expanded(
                flex: 2,
                child: Text('Price'),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  Constant.toCurrency(ticket.price),
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
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.calendarDay,
                    size: 16,
                    color: context.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  const Text('Date'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(dateText),
                  if (event.endDate == null) ...[
                    const SizedBox(width: 8),
                    FaIcon(
                      FontAwesomeIcons.clock,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat.Hm().format(event.date.toLocal()),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.locationDot,
                    size: 16,
                    color: Colors.red,
                  ),
                  SizedBox(width: 6),
                  Text('Location'),
                  SizedBox(width: 16),
                ],
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  event.location,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
