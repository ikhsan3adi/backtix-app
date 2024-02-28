import 'dart:io';

import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NewTicketCard extends StatelessWidget {
  NewTicketCard({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.ticket,
    this.onTap,
  });

  /// Used on edit form
  final String? imageUrl;
  final File? imageFile;
  final NewTicketModel ticket;
  final VoidCallback? onTap;

  final _dateFormatter = DateFormat('dd/MM/yy HH:mm');

  @override
  Widget build(BuildContext context) {
    final dateStart = _dateFormatter.format(ticket.salesOpenDate.toLocal());
    final dateEnd = ticket.purchaseDeadline == null
        ? ''
        : ' - ${_dateFormatter.format(ticket.purchaseDeadline!.toLocal())}';

    final dateText = '$dateStart$dateEnd';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWelledStack(
        onTap: onTap,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.all(1),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.theme.disabledColor,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageFile == null
                    ? imageUrl == null
                        ? const Center(child: TicketImagePlaceholder())
                        : CustomNetworkImage(
                            src: imageUrl!,
                            small: true,
                          )
                    : CustomFileImage(
                        file: imageFile!,
                        small: true,
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              ticket.name,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              Constant.toCurrency(ticket.price),
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: context.colorScheme.primary,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.calendarDay,
                                size: 14,
                                color: context.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              FaIcon(
                                FontAwesomeIcons.solidClock,
                                size: 14,
                                color: context.colorScheme.primary,
                              ),
                            ],
                          ),
                          Text(dateText),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Initial stock: ${ticket.stock}',
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
