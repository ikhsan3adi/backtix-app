import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/notification/notification_entity_type_enum.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/models/notification/notification_type_enum.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NotificationHandler {
  static VoidCallback onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    return () {
      switch (notification.entityType) {
        case NotificationEntityType.event:
          if (notification.type == NotificationType.ticketPurchase) {
            return context.goNamed(RouteNames.myTickets);
          } else if (notification.type == NotificationType.ticketSales) {
            return context.goNamed(
              RouteNames.eventTicketSales,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          } else if (notification.type ==
              NotificationType.ticketRefundRequest) {
            return context.goNamed(
              RouteNames.eventTicketRefundRequest,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          } else if (notification.type == NotificationType.ticketRefundStatus) {
            return context.goNamed(
              RouteNames.myTickets,
              queryParameters: {'refund': 'yes'},
            );
          } else if (notification.type == NotificationType.eventStatus) {
            return context.goNamed(
              RouteNames.myEventDetail,
              pathParameters: {'id': notification.entityId ?? ''},
            );
          }
          return context.goNamed(
            RouteNames.eventDetail,
            pathParameters: {'id': notification.entityId ?? ''},
          );
        case NotificationEntityType.withdrawRequest:
          return context.goNamed(RouteNames.myWithdraws);
        case NotificationEntityType.purchase:
        case NotificationEntityType.ticket:
        default:
        // Not implemented
      }
    };
  }
}
