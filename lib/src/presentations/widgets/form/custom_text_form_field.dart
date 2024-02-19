import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    super.key,
    TextEditingController? controller,
    this.validator,
    this.onTap,
    this.onChanged,
    this.maxLines,
    this.minLines,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.decoration = const InputDecoration(),
  }) : _controller = controller;

  final TextEditingController? _controller;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final int? maxLines, minLines;
  final bool readOnly, obscureText;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;

  final inputBorderBase = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final inputBorder = inputBorderBase.copyWith(
      borderSide: inputBorderBase.borderSide.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );

    return TextFormField(
      controller: _controller,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      obscureText: obscureText,
      onTap: onTap,
      readOnly: readOnly,
      decoration: decoration?.copyWith(
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            width: 2.2,
            color: context.colorScheme.primary,
          ),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            width: 2,
            color: context.colorScheme.error,
          ),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            width: 2.2,
            color: context.colorScheme.error,
          ),
        ),
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            width: 1.8,
            color: context.theme.disabledColor,
          ),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
