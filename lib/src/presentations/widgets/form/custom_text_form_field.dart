import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.controller,
    this.validator,
    this.onTap,
    this.onChanged,
    this.maxLines,
    this.minLines,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.decoration = const InputDecoration(),
    this.debounce = false,
    this.debouncer,
  });

  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final int? maxLines, minLines;
  final bool readOnly, obscureText;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;
  final bool debounce;
  final Debouncer? debouncer;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final inputBorderBase = OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: const BorderSide(width: 2),
  );

  late final InputBorder inputBorder;

  Debouncer? _debouncer;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.debounce) _debouncer = widget.debouncer ?? Debouncer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    inputBorder = inputBorderBase.copyWith(
      borderSide: inputBorderBase.borderSide.copyWith(
        color: context.colorScheme.onSurface,
      ),
    );
  }

  @override
  void dispose() {
    _debouncer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      onChanged: (value) {
        widget.onChanged?.call(value);
        if (widget.debounce) {
          _debouncer?.run(() {
            setState(() => _errorText = widget.validator?.call(value));
          });
        }
      },
      onTapOutside: widget.debounce
          ? (_) => setState(() {
                _errorText = widget.validator?.call(widget.controller?.text);
              })
          : null,
      validator: widget.debounce ? (_) => _errorText : widget.validator,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      obscureText: widget.obscureText,
      onTap: widget.onTap,
      readOnly: widget.readOnly,
      decoration: widget.decoration?.copyWith(
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
      keyboardType: widget.keyboardType,
    );
  }
}
