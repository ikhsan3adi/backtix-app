import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 0 = show image, 1 = pick from gallery, 2 = pick from camera
class PickImageDialog extends StatelessWidget {
  const PickImageDialog({super.key, required this.withShowButton});

  static Future<int?> show(
    BuildContext context, {
    bool withShowButton = true,
  }) async {
    return await showDialog<int>(
      context: context,
      useSafeArea: true,
      builder: (_) => PickImageDialog(withShowButton: withShowButton),
    );
  }

  final bool withShowButton;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withShowButton)
            _buildListTile(
              context,
              title: 'Show',
              icon: const Icon(Icons.visibility_outlined),
              onTap: () => context.pop(0),
            ),
          _buildListTile(
            context,
            title: 'Choose from gallery',
            icon: const Icon(Icons.photo_library_outlined),
            onTap: () => context.pop(1),
          ),
          _buildListTile(
            context,
            title: 'Take picture',
            icon: const Icon(Icons.camera_outlined),
            onTap: () => context.pop(2),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    Icon? icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.primaryContainer,
        child: icon,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
