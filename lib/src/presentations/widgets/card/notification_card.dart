import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/models/notification/notification_type_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onRead,
  });
  final DateFormat _formattter = DateFormat('EEE, dd/MM/y HH:mm:ss');
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onRead;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  switch (notification.type) {
                    NotificationType.ticketPurchase => FontAwesomeIcons.ticket,
                    NotificationType.ticketSales => Icons.show_chart_outlined,
                    NotificationType.withdrawStatus =>
                      Icons.account_balance_wallet_outlined,
                    NotificationType.other => Icons.notifications_outlined,
                    NotificationType.ticketRefundRequest =>
                      Icons.rotate_left_rounded,
                    NotificationType.ticketRefundStatus =>
                      Icons.rotate_left_rounded,
                    NotificationType.eventStatus =>
                      Icons.calendar_month_outlined,
                  },
                  color: notification.isRead
                      ? context.theme.disabledColor
                      : context.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      color: notification.isRead
                          ? context.theme.disabledColor
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.type.title,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: notification.isRead
                                ? context.theme.disabledColor
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(notification.message),
                        const SizedBox(height: 6),
                        Text(_formattter.format(notification.updatedAt)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (!notification.isRead)
          IconButton(
            onPressed: onRead,
            icon: Icon(
              Icons.check,
              color: context.colorScheme.primary,
              size: 28,
            ),
          ),
      ],
    );
  }
}
