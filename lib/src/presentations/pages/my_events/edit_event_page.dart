import 'dart:io';

import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/events/edit_event/edit_event_bloc.dart';
import 'package:backtix_app/src/blocs/events/edit_event/edit_event_images_form/edit_event_images_form_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_model.dart';
import 'package:backtix_app/src/data/models/event/new_event_model.dart';
import 'package:backtix_app/src/data/models/event/update_event_model.dart';
import 'package:backtix_app/src/data/services/remote/location_service.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnIterable;
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:validatorless/validatorless.dart';

class EditEventPage extends StatelessWidget {
  const EditEventPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Edit Event'),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) {
              return GetIt.I<EditEventBloc>()
                ..add(EditEventEvent.init(eventId));
            },
          ),
          BlocProvider(create: (_) => EditEventImagesFormCubit()),
        ],
        child: Builder(builder: (context) {
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              final refresh = await DiscardChangesDialog.show(context);
              if (context.mounted && (refresh ?? false)) {
                context.read<EditEventBloc>().add(EditEventEvent.init(eventId));
              }
            },
            child: BlocListener<EditEventBloc, EditEventState>(
              listener: (context, state) => state.whenOrNull(
                loading: () => SimpleLoadingDialog.show(context),
                success: (_) async {
                  SimpleLoadingDialog.hide(context);
                  await SuccessBottomSheet.show(
                    context,
                    text: 'Event updated',
                  );
                  if (context.mounted) return context.pop(true);
                  return;
                },
                loaded: (event, exception) async {
                  SimpleLoadingDialog.hide(context);
                  if (exception == null) return;
                  return ErrorDialog.show(
                    context,
                    exception,
                  );
                },
              ),
              child: ResponsivePadding(
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [_EditEventForm(eventId: eventId)],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EditEventForm extends StatefulWidget {
  const _EditEventForm({required this.eventId});

  final String eventId;

  @override
  State<_EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends State<_EditEventForm> {
  final DateFormat _dateFormat = DateFormat('dd/MM/y HH:mm');
  final _debouncer = Debouncer();

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _categoryController = TextEditingController();

  final _coords = ValueNotifier<LatLng?>(null);
  final _dateRange = ValueNotifier<({DateTime? start, DateTime? end})>(
    (start: null, end: null),
  );

  /// [String] category, [bool] selected
  final _categories = ValueNotifier<List<({String category, bool selected})>>(
    NewEventModel.initialCategories
        .map((e) => (category: e, selected: false))
        .toList(),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _coords.dispose();
    _dateRange.dispose();
    _categories.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  Future<DateTime?> pickDateTime(BuildContext context) async {
    return await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    ).then((date) async {
      if (date == null) return date;
      final time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 7, minute: 0),
      );
      if (time == null) return date;
      return date.copyWith(hour: time.hour, minute: time.minute);
    });
  }

  bool _initialized = false;

  void _initFields(BuildContext context, EventModel event) {
    if (_initialized) return;
    _initialized = true;
    final latLng =
        event.isLatLongSet ? LatLng(event.latitude!, event.longitude!) : null;

    final categories = [
      ...event.categories.map((e) => (category: e, selected: true)),
      ..._categories.value
        ..removeWhere((e) => event.categories.contains(e.category)),
    ];

    _nameController.text = event.name;
    _descriptionController.text = event.description;
    _locationController.text = event.location;
    _dateRange.value = (start: event.date, end: event.endDate);
    _coords.value = latLng;
    _categories.value = categories;

    context.read<EditEventImagesFormCubit>().init(event.images);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverList.list(
        children: [
          BlocListener<EditEventBloc, EditEventState>(
            listener: (context, state) => state.whenOrNull(
              loading: () => SimpleLoadingDialog.show(context),
              loaded: (event, exception) async {
                SimpleLoadingDialog.hide(context);
                if (event != null) _initFields(context, event);
                return;
              },
            ),
            child: const SizedBox(height: 8),
          ),
          // TEXTFORMFIELDS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // EVENT NAME & DESCRIPTION
                CustomTextFormField(
                  controller: _nameController,
                  debounce: true,
                  debouncer: _debouncer,
                  validator: Validatorless.multiple([
                    Validatorless.min(3, 'Must have at least 3 character'),
                    Validatorless.required('Name required'),
                  ]),
                  decoration: const InputDecoration(
                    labelText: 'Event name',
                    helperText: '',
                    hintText: 'Music Festival 2024',
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _descriptionController,
                  debounce: true,
                  debouncer: _debouncer,
                  minLines: 3,
                  validator: Validatorless.required('Description required'),
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe your event',
                    alignLabelWithHint: true,
                    helperText: '',
                  ),
                ),
                const SizedBox(height: 8),

                // EVENT DATE
                _eventDatePicker,
                const SizedBox(height: 32),

                // ADDRESS
                Text(
                  'Location',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextFormField(
                  controller: _locationController,
                  debounce: true,
                  debouncer: _debouncer,
                  validator: Validatorless.required('Address required'),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Ahmad Yani Street',
                    helperText: '',
                  ),
                ),
                const SizedBox(height: 8),

                // COORDINATES
                ValueListenableBuilder(
                  valueListenable: _coords,
                  builder: (context, coords, _) {
                    return CustomTextFormField(
                      debounce: true,
                      debouncer: _debouncer,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Location coordinates',
                        hintText: coords == null
                            ? 'lat, long'
                            : '${coords.latitude}, ${coords.longitude}',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        helperText: '',
                      ),
                    );
                  },
                ),
                _locationPicker,
                const SizedBox(height: 32),

                // CATEGORIES
                Text(
                  'Categories',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _categoryChoiceChips,
                const SizedBox(height: 6),
                _otherCategoryField,
              ],
            ),
          ),

          // EVENT IMAGE
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Text(
              'Images',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints.loose(
              const Size.fromHeight(230),
            ),
            child: const _EventImagesForm(),
          ),

          // SUBMIT BUTTON
          _submitButton,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget get _eventDatePicker {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start date',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                    final startDate = await pickDateTime(context);
                    if (startDate == null) return;

                    _dateRange.value = (
                      start: startDate,
                      end: _dateRange.value.end,
                    );
                  },
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined),
                        const SizedBox(width: 4),
                        ValueListenableBuilder(
                          valueListenable: _dateRange,
                          builder: (context, dateRange, _) {
                            return Text(
                              dateRange.start == null
                                  ? 'Start date'
                                  : _dateFormat.format(
                                      _dateRange.value.start!.toLocal(),
                                    ),
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
                'End date',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                    final endDate = await pickDateTime(context);
                    if (endDate == null) return;

                    _dateRange.value = (
                      start: _dateRange.value.start,
                      end: endDate,
                    );
                  },
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined),
                        const SizedBox(width: 4),
                        ValueListenableBuilder(
                          valueListenable: _dateRange,
                          builder: (context, dateRange, _) {
                            return Text(
                              dateRange.end == null
                                  ? 'End date'
                                  : _dateFormat.format(
                                      _dateRange.value.end!.toLocal(),
                                    ),
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

  Widget get _locationPicker {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                if (!LocationService.supportDeviceLocation) {
                  return context.showSimpleTextSnackBar(
                    'Not supported on ${Platform.operatingSystem}',
                  );
                }

                await LocationService.determinePosition().then((pos) async {
                  final coords = LatLng(pos.latitude, pos.longitude);
                  _coords.value = coords;
                  if (_locationController.text.isEmpty) {
                    await Future.delayed(const Duration(seconds: 1));
                    final address =
                        await LocationService.addressFromLatLong(coords);
                    if (address != null) {
                      _locationController.text = address;
                    }
                  }
                }).catchError((e) async {
                  ErrorDialog.show(
                    context,
                    e.runtimeType == Exception
                        ? e as Exception
                        : Exception(e.toString()),
                  );
                });
              },
              icon: const Icon(Icons.location_pin),
              label: const Text(
                'Get from current location',
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final user = context.read<AuthBloc>().user;
                final coords = await context.pushNamed(
                  RouteNames.locationPicker,
                  queryParameters: {
                    'latitude': user?.latitude.toString(),
                    'longitude': user?.longitude.toString(),
                  },
                ) as LatLng?;
                if (coords == null) return;
                _coords.value = coords;
                if (_locationController.text.isEmpty) {
                  await Future.delayed(const Duration(seconds: 1));
                  final address =
                      await LocationService.addressFromLatLong(coords);
                  if (address != null) {
                    _locationController.text = address;
                  }
                }
              },
              icon: const Icon(Icons.map),
              label: const Text('Get from maps'),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _categoryChoiceChips {
    return ValueListenableBuilder(
      valueListenable: _categories,
      builder: (context, categories, _) {
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...categories.mapWithIndex((e, index) {
              return ChoiceChip(
                label: Text(e.category),
                selected: e.selected,
                onSelected: (v) {
                  _categories.value = [
                    ...categories
                      ..replaceRange(
                        index,
                        index + 1,
                        [(category: e.category, selected: v)],
                      ),
                  ];
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget get _otherCategoryField {
    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            width: 1,
            color: context.colorScheme.onSurface,
          ),
        ),
        constraints: BoxConstraints.loose(const Size.fromWidth(250)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Other: '),
            const SizedBox(width: 8),
            Flexible(
              child: TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: _categoryController,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  if (value.length < 3 || value.length > 10) {
                    return 'Between 3-10 character';
                  }
                  return null;
                },
                maxLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    onPressed: () {
                      final text = _categoryController.value.text;
                      if (text.isEmpty || text.length < 3 || text.length > 10) {
                        return;
                      }
                      _categories.value = [
                        ..._categories.value
                          ..add((category: text, selected: true)),
                      ];
                      _categoryController.clear();
                    },
                    icon: const Icon(Icons.check),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _submitButton {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<EditEventBloc, EditEventState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: state.maybeMap(
              loading: (_) => null,
              success: (_) => null,
              orElse: () => () => _submit(context),
            ),
            child: Text(
              state.maybeMap(
                loading: (_) => 'Submitting...',
                success: (_) => 'Success',
                orElse: () => 'Submit',
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit(BuildContext context) {
    _categoryController.clear();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_dateRange.value.start == null) {
      context.showSimpleTextSnackBar('Event start date required');
      return;
    }
    if (_categories.value.where((e) => e.selected).isEmpty) {
      context.showSimpleTextSnackBar('Select at least 1 category');
      return;
    }

    final images = context.read<EditEventImagesFormCubit>().state.images;

    if (images.isEmpty) {
      context.showSimpleTextSnackBar('Add at least 1 image');
      return;
    }

    final updatedEvent = UpdateEventModel(
      name: _nameController.value.text,
      description: _descriptionController.value.text,
      date: _dateRange.value.start!,
      endDate: _dateRange.value.end,
      location: _locationController.value.text,
      latitude: _coords.value?.latitude,
      longitude: _coords.value?.longitude,
      categories: _categories.value
          .where((e) => e.selected)
          .map((e) => e.category)
          .toList(),
      images: images.map((e) => e.eventImage).toList(),
      eventImageFiles: images
          .where((e) =>
              e.file != null && e.eventImage.withImage && !e.eventImage.delete)
          .map((e) => e.file!)
          .toList(),
    );

    context.read<EditEventBloc>().add(EditEventEvent.updateEvent(
          widget.eventId,
          updatedEvent: updatedEvent,
        ));
  }
}

/// EVENT IMAGES
class _EventImagesForm extends StatelessWidget {
  const _EventImagesForm();

  static const double previewSize = 120;
  static const int maxCount = EditEventImagesFormCubit.maxCount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditEventImagesFormCubit, EditEventImagesFormState>(
      builder: (context, state) {
        final images = state.images;
        final maxCountReached = images.length == maxCount;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: maxCountReached ? images.length : images.length + 1,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final bool isLastIndex = index == images.length;

            if (isLastIndex) {
              return SizedBox(
                width: previewSize,
                child: EventImagePicker(
                  size: previewSize,
                  text: 'Select new images (${images.length}/$maxCount)',
                  onTap: () async {
                    await FilePicker.pickMultipleImage().then((imageFiles) {
                      return context
                          .read<EditEventImagesFormCubit>()
                          .addImages(imageFiles);
                    });
                  },
                ),
              );
            }
            final eventImage = images[index].eventImage;
            final oldImageUrl = images[index].oldImageUrl;
            final imageFile = images[index].file;

            return SizedBox(
              width: previewSize,
              child: EventImagePickerPreview(
                size: previewSize,
                imageFile: imageFile,
                imageUrl: oldImageUrl,
                description: eventImage.description?.trim() == ''
                    ? null
                    : eventImage.description?.trim(),
                isDeleted: eventImage.delete ||
                    (oldImageUrl != null && imageFile != null),
                onTap: () async {
                  await PickImageDialog.show(context).then((value) async {
                    if (value == null) return;
                    if (value == 0) {
                      await showImageViewer(
                        context,
                        imageFile == null
                            ? NetworkImage(oldImageUrl ?? '') as ImageProvider
                            : FileImage(imageFile),
                        useSafeArea: true,
                        doubleTapZoomable: true,
                        swipeDismissible: true,
                      );
                      return;
                    }
                    final file = await FilePicker.pickSingleImage(
                      fromCamera: value == 2,
                    ).then((file) async {
                      if (file == null) return null;
                      return await FilePicker.cropImage(file: file);
                    });

                    if (context.mounted && file != null) {
                      return context
                          .read<EditEventImagesFormCubit>()
                          .changeImage(index, imageFile: file);
                    }
                  });
                },
                onRemove: () =>
                    context.read<EditEventImagesFormCubit>().removeImage(index),
                onUndo: () => context
                    .read<EditEventImagesFormCubit>()
                    .revertToOldImage(index),
                onDescriptionTap: () async {
                  final desc = await EventImageDescriptionDialog.show(
                    context,
                    description: eventImage.description,
                  );
                  if (desc == null) return;
                  if (context.mounted) {
                    context
                        .read<EditEventImagesFormCubit>()
                        .changeDescription(index, description: desc);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
