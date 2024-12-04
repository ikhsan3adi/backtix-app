import 'dart:async';
import 'dart:io';

import 'package:backtix_app/src/blocs/tickets/upsert_ticket/upsert_ticket_cubit.dart';
import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/update_ticket_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:validatorless/validatorless.dart';

class UpsertTicketDialog extends StatefulWidget {
  const UpsertTicketDialog({
    super.key,
    this.eventId,
    required this.ticket,
    this.onDelete,
  });

  static Future<bool?> show(
    BuildContext context, {
    String? eventId,
    TicketModel? ticket,
    FutureOr<void> Function()? onDelete,
  }) async {
    return await showAdaptiveDialog<bool>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => GetIt.I<UpsertTicketCubit>(),
        child: UpsertTicketDialog(
          ticket: ticket,
          onDelete: onDelete,
          eventId: eventId,
        ),
      ),
    );
  }

  final String? eventId;
  final TicketModel? ticket;
  final FutureOr<void> Function()? onDelete;

  @override
  State<UpsertTicketDialog> createState() => _UpsertTicketDialogState();
}

class _UpsertTicketDialogState extends State<UpsertTicketDialog> {
  final DateFormat _dateFormat = DateFormat('dd/MM/y HH:mm');
  final _debouncer = Debouncer();

  final _formKey = GlobalKey<FormState>();

  final _image = ValueNotifier<({File? newImageFile, String? oldImageUrl})>(
    (newImageFile: null, oldImageUrl: null),
  );

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  final _salesOpenDate = ValueNotifier<DateTime?>(null);
  final _salesEndDate = ValueNotifier<DateTime?>(null);

  late bool _isCreate;
  late bool _hasOldImage;

  @override
  void initState() {
    super.initState();
    _isCreate = widget.ticket == null && widget.eventId != null;
    _hasOldImage = widget.ticket?.image != null;
    _image.value = (newImageFile: null, oldImageUrl: widget.ticket?.image);
    _nameController = TextEditingController(text: widget.ticket?.name);
    _priceController = TextEditingController(
      text: widget.ticket?.price.toString(),
    );
    _stockController = TextEditingController(text: _isCreate ? '1' : '0');
    _salesOpenDate.value = widget.ticket?.salesOpenDate;
    _salesEndDate.value = widget.ticket?.purchaseDeadline;
  }

  @override
  void dispose() {
    _image.dispose();
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
      if (context.mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: const TimeOfDay(hour: 0, minute: 0),
        );
        if (time == null) return date;
        return date.copyWith(hour: time.hour, minute: time.minute);
      }
      return null;
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
                    if (!_isCreate)
                      TextButton.icon(
                        onPressed: () async {
                          final delete = await ConfirmDialog.show(context);
                          if ((delete ?? false) && context.mounted) {
                            await context
                                .read<UpsertTicketCubit>()
                                .deleteTicket(widget.ticket!.id);
                          }
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
          valueListenable: _image,
          builder: (_, img, __) => _Image(
            newImage: img.newImageFile,
            oldImageUrl: img.oldImageUrl,
            isDeleted: img.newImageFile == null && img.oldImageUrl == null,
            onTap: () async {
              final file = await FilePicker.pickSingleImage();
              if (file == null) return;
              final cropped = await FilePicker.cropImage(
                file: file,
                maxWidth: 720,
              );
              if (cropped != null) {
                _image.value = (
                  newImageFile: cropped,
                  oldImageUrl: img.oldImageUrl,
                );
              }
            },
            onRemove: () {
              if (img.newImageFile == null) {
                _image.value = (
                  oldImageUrl: null,
                  newImageFile: img.newImageFile,
                );
                return;
              }
              _image.value = (
                oldImageUrl: img.oldImageUrl,
                newImageFile: null,
              );
            },
            onUndo: () {},
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: _priceController,
            debounce: true,
            debouncer: _debouncer,
            keyboardType: TextInputType.number,
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
            validator: (v) => Validatorless.multiple([
              Validatorless.number('Value is not a number'),
              if (_isCreate) ...[
                Validatorless.numbersBetweenInterval(
                  1,
                  double.maxFinite,
                  'Min 1',
                ),
                Validatorless.required('Stock required')
              ] else if (v?.isNotEmpty ?? false)
                Validatorless.numbersBetweenInterval(
                  (widget.ticket!.currentStock - 1) * -1,
                  double.maxFinite,
                  'Current stock can\'t be negative',
                ),
            ]).call(v),
            decoration: InputDecoration(
              labelText:
                  _isCreate ? 'Initial stock' : 'Stock addition/reduction',
              helperText: _isCreate
                  ? ''
                  : 'Current stock: ${widget.ticket?.currentStock}',
              errorMaxLines: 2,
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
    return BlocConsumer<UpsertTicketCubit, UpsertTicketState>(
      listener: (context, state) {
        state.whenOrNull(
          loading: () => SimpleLoadingDialog.show(context),
          error: (err) async {
            SimpleLoadingDialog.hide(context);
            return ErrorDialog.show(context, err);
          },
          success: (_) {
            SimpleLoadingDialog.hide(context);
            Navigator.pop(context, true);
          },
        );
      },
      builder: (context, state) {
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
                onPressed: state.isLoading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        if (_salesOpenDate.value == null) {
                          await Toast.show(context, msg: 'Date required');
                          return;
                        }
                        if (_isCreate) {
                          final newTicket = NewTicketModel(
                            imageFile: _image.value.newImageFile,
                            name: _nameController.value.text,
                            price: num.parse(_priceController.value.text),
                            stock: int.parse(_stockController.value.text),
                            hasImage: _image.value.newImageFile != null,
                            salesOpenDate: _salesOpenDate.value!,
                            purchaseDeadline: _salesEndDate.value,
                          );

                          return await context
                              .read<UpsertTicketCubit>()
                              .createNewTicket(
                                widget.eventId!,
                                ticket: newTicket,
                              );
                        }
                        final updatedTicket = UpdateTicketModel(
                          name: _nameController.value.text,
                          price: num.parse(_priceController.value.text),
                          additionalStock:
                              int.tryParse(_stockController.value.text),
                          deleteImage:
                              _hasOldImage && _image.value.oldImageUrl == null,
                          newImageFile: _image.value.newImageFile,
                          salesOpenDate: _salesOpenDate.value!,
                          purchaseDeadline: _salesEndDate.value,
                        );

                        context.read<UpsertTicketCubit>().updateTicket(
                              widget.ticket!.id,
                              ticket: updatedTicket,
                            );
                      },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({
    required this.onTap,
    required this.onRemove,
    this.onUndo,
    this.newImage,
    this.oldImageUrl,
    required this.isDeleted,
  });

  final File? newImage;
  final String? oldImageUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback? onUndo;
  final bool isDeleted;

  static const double size = 120;

  @override
  Widget build(BuildContext context) {
    return newImage != null || oldImageUrl != null
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
                    newImage == null
                        ? CustomNetworkImage(src: oldImageUrl!)
                        : CustomFileImage(
                            file: newImage!,
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
                    tooltip: isDeleted
                        ? newImage == null
                            ? 'Undo'
                            : 'Revert'
                        : 'Delete',
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
