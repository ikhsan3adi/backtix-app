import 'dart:async';
import 'dart:io';

import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:validatorless/validatorless.dart';

class TicketFormDialog extends StatefulWidget {
  const TicketFormDialog({super.key, this.old, this.onDelete});

  static Future<NewTicketWithImage?> show(
    BuildContext context, {
    NewTicketWithImage? old,
    FutureOr<void> Function()? onDelete,
  }) async {
    return await showAdaptiveDialog<NewTicketWithImage>(
      context: context,
      builder: (_) => TicketFormDialog(old: old, onDelete: onDelete),
    );
  }

  final NewTicketWithImage? old;
  final FutureOr<void> Function()? onDelete;

  @override
  State<TicketFormDialog> createState() => _TicketFormDialogState();
}

class _TicketFormDialogState extends State<TicketFormDialog> {
  final DateFormat _dateFormat = DateFormat('dd/MM/y HH:mm');
  final _debouncer = Debouncer();

  final _formKey = GlobalKey<FormState>();

  final _imageFile = ValueNotifier<File?>(null);

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  final _salesOpenDate = ValueNotifier<DateTime?>(null);
  final _salesEndDate = ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _imageFile.value = widget.old?.file;
    _nameController = TextEditingController(text: widget.old?.ticket.name);
    _priceController = TextEditingController(
      text: widget.old?.ticket.price.toString(),
    );
    _stockController = TextEditingController(
      text: widget.old?.ticket.stock.toString(),
    );
    _salesOpenDate.value = widget.old?.ticket.salesOpenDate;
    _salesEndDate.value = widget.old?.ticket.purchaseDeadline;
  }

  @override
  void dispose() {
    _imageFile.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _salesOpenDate.dispose();
    _salesEndDate.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    return await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    ).then((date) async {
      if (date == null) return date;
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 0, minute: 0),
      );
      if (time == null) return date;
      return date.copyWith(hour: time.hour, minute: time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ticket',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.old != null)
                      TextButton.icon(
                        onPressed: () async {
                          await widget.onDelete?.call();
                          if (context.mounted) Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete ticket'),
                      )
                  ],
                ),
              ),
              _imageAndTicketName,
              const SizedBox(height: 16),
              _priceAndStock,
              const SizedBox(height: 8),
              _datePicker,
              const SizedBox(height: 24),
              _actionButtons,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _imageAndTicketName {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: _imageFile,
          builder: (_, img, __) => _Image(
            img,
            onTap: () async {
              final file = await FilePicker.pickSingleImage();
              if (file == null) return;
              final cropped = await FilePicker.cropImage(
                file: file,
                maxWidth: 720,
              );
              if (cropped != null) _imageFile.value = cropped;
            },
            onRemove: () => _imageFile.value = null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              CustomTextFormField(
                controller: _nameController,
                debounce: true,
                debouncer: _debouncer,
                validator: Validatorless.multiple([
                  Validatorless.min(3, 'Must have at least 3 character'),
                  Validatorless.required('Name required'),
                ]),
                minLines: 3,
                maxLength: 128,
                decoration: const InputDecoration(
                  labelText: 'Ticket name',
                  alignLabelWithHint: true,
                  helperText: '',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _priceAndStock {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: _priceController,
            debounce: true,
            debouncer: _debouncer,
            validator: Validatorless.multiple([
              Validatorless.number('Value is not a number'),
              Validatorless.numbersBetweenInterval(
                1000,
                double.maxFinite,
                'Min 1000',
              ),
              Validatorless.required('Price required'),
            ]),
            decoration: const InputDecoration(
              labelText: 'Ticket price',
              helperText: '',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextFormField(
            controller: _stockController,
            debounce: true,
            debouncer: _debouncer,
            keyboardType: TextInputType.number,
            validator: Validatorless.multiple([
              Validatorless.number('Value is not a number'),
              Validatorless.numbersBetweenInterval(
                1,
                double.maxFinite,
                'Min 1',
              ),
              Validatorless.required('Stock required'),
            ]),
            decoration: const InputDecoration(
              labelText: 'Initial stock',
              helperText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget get _datePicker {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Sales open date'),
                    TextSpan(
                      text: '*',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ],
                ),
                style: context.textTheme.titleMedium,
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    width: 2,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                height: 50,
                child: InkWelledStack(
                  fit: StackFit.expand,
                  onTap: () async {
                    final startDate = await _pickDateTime(context);
                    if (startDate == null) return;
                    _salesOpenDate.value = startDate;
                  },
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined),
                        const SizedBox(width: 4),
                        ValueListenableBuilder(
                          valueListenable: _salesOpenDate,
                          builder: (context, date, _) {
                            return Text(
                              date == null
                                  ? 'Start date'
                                  : _dateFormat.format(date.toLocal()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales end (optional)',
                style: context.textTheme.titleMedium,
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    width: 2,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                height: 50,
                child: InkWelledStack(
                  fit: StackFit.expand,
                  onTap: () async {
                    final endDate = await _pickDateTime(context);
                    _salesEndDate.value = endDate;
                  },
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined),
                        const SizedBox(width: 4),
                        ValueListenableBuilder(
                          valueListenable: _salesEndDate,
                          builder: (context, date, _) {
                            return Text(
                              date == null
                                  ? 'End date'
                                  : _dateFormat.format(date.toLocal()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _actionButtons {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              if (!(_formKey.currentState?.validate() ?? false)) return;
              if (_salesOpenDate.value == null) return;

              return Navigator.pop(
                context,
                (
                  file: _imageFile.value,
                  ticket: NewTicketModel(
                    name: _nameController.value.text,
                    price: num.parse(_priceController.value.text),
                    stock: int.parse(_stockController.value.text),
                    hasImage: _imageFile.value != null,
                    salesOpenDate: _salesOpenDate.value,
                    purchaseDeadline: _salesEndDate.value,
                  )
                ),
              );
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image(this.img, {required this.onTap, required this.onRemove});

  final File? img;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const double size = 120;

  @override
  Widget build(BuildContext context) {
    return img != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(1),
                clipBehavior: Clip.hardEdge,
                height: size,
                width: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.theme.disabledColor,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: InkWelledStack(
                  onTap: onTap,
                  fit: StackFit.expand,
                  children: [
                    CustomFileImage(
                      file: img!,
                      small: true,
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
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.delete_forever,
                      color: context.colorScheme.onError,
                      size: 20,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          context.colorScheme.error.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            clipBehavior: Clip.hardEdge,
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: context.colorScheme.primaryContainer,
            ),
            child: InkWelledStack(
              onTap: onTap,
              fit: StackFit.expand,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 32,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add ticket image',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
