import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EventImagePicker extends StatelessWidget {
  const EventImagePicker({
    super.key,
    this.onTap,
    this.text = 'Select new images',
    this.size = 120,
  });

  final VoidCallback? onTap;
  final String text;

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          height: size,
          width: size,
          child: InkWelledStack(
            onTap: onTap,
            children: [
              SizedBox(
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
