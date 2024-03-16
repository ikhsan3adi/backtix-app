import 'package:backtix_app/src/blocs/notifications/notifications_cubit.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationNavIcon extends StatelessWidget {
  const NotificationNavIcon({super.key})
      : iconData = Icons.notifications_outlined;

  const NotificationNavIcon.selected({super.key})
      : iconData = Icons.notifications;

  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsCubit, NotificationsState>(
      builder: (context, state) {
        return state.maybeMap(
          loaded: (state) {
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(iconData),
                if (state.notifications.isNotEmpty)
                  Positioned(
                    top: -1,
                    right: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorScheme.error,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '${state.notifications.length}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
          orElse: () => Icon(iconData),
        );
      },
    );
  }
}
