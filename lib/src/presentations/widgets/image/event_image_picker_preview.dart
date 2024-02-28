import 'dart:io';

import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EventImagePickerPreview extends StatelessWidget {
  const EventImagePickerPreview({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.description,
    this.onTap,
    this.onDescriptionTap,
    this.onRemove,
    this.onUndo,
    this.size = 120,
    this.isDeleted = false,
  });

  /// Used on edit form
  final String? imageUrl;

  final File? imageFile;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onUndo;
  final VoidCallback? onDescriptionTap;

  final double size;

  final bool isDeleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Image(
          size: size,
          onTap: onTap,
          imageFile: imageFile,
          imageUrl: imageUrl,
          onRemove: onRemove,
          onUndo: onUndo,
          isDeleted: isDeleted,
        ),
        const SizedBox(height: 8),
        if (description == null)
          TextButton(
            onPressed: onDescriptionTap,
            child: const Text(
              'Add Description',
              textAlign: TextAlign.center,
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.hardEdge,
            child: InkWelledStack(
              onTap: onDescriptionTap,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        description ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Edit Description',
                      textAlign: TextAlign.center,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.size,
    required this.onTap,
    required this.imageFile,
    required this.imageUrl,
    required this.onRemove,
    this.onUndo,
    this.isDeleted = false,
  });

  final String? imageUrl;

  final File? imageFile;
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onUndo;

  final bool isDeleted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topRight,
      children: [
        Container(
          height: size,
          width: size,
          margin: const EdgeInsets.all(1),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.theme.disabledColor,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWelledStack(
            onTap: onTap,
            fit: StackFit.expand,
            children: [
              imageFile != null
                  ? CustomFileImage(file: imageFile!, small: true)
                  : CustomNetworkImage(src: imageUrl!, small: true),
              if (isDeleted && imageFile == null)
                Container(
                  color: context.theme.disabledColor.withOpacity(0.6),
                  child: Center(
                    child: Text(
                      'Removed',
                      style: context.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // REMOVE BUTTON
        Positioned(
          right: -5,
          top: -5,
          child: SizedBox(
            width: 36,
            height: 36,
            child: IconButton.filled(
              onPressed: isDeleted ? onUndo : onRemove,
              icon: Icon(
                isDeleted ? Icons.undo_outlined : Icons.delete_forever,
                color: context.colorScheme.onError,
                size: 20,
              ),
              tooltip: isDeleted
                  ? imageFile == null
                      ? 'Undo'
                      : 'Revert'
                  : 'Delete',
              style: IconButton.styleFrom(
                backgroundColor: isDeleted
                    ? context.colorScheme.primary.withOpacity(0.5)
                    : context.colorScheme.error.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
