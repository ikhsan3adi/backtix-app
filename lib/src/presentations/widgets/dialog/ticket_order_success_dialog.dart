import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TicketOrderSuccessDialog extends StatelessWidget {
  const TicketOrderSuccessDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const TicketOrderSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.circleCheck,
                size: 64,
                color: context.isDark ? Colors.greenAccent : Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment successful',
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
