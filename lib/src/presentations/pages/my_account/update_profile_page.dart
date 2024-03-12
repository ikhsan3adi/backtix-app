import 'dart:io';

import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/user/update_profile/update_profile_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/user/update_user_model.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/data/services/remote/location_service.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:validatorless/validatorless.dart';

class UpdateProfilePage extends StatelessWidget {
  const UpdateProfilePage({super.key, this.highlightLocationField = false});

  final bool? highlightLocationField;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Profile'),
      ),
      body: BlocProvider(
        create: (_) => GetIt.I<UpdateProfileCubit>()..init(),
        child: ResponsivePadding(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _UpdateProfileForm(highlightLocationField),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpdateProfileForm extends StatefulWidget {
  const _UpdateProfileForm(this.highlightLocationField);

  final bool? highlightLocationField;

  @override
  State<_UpdateProfileForm> createState() => _UpdateProfileFormState();
}

class _UpdateProfileFormState extends State<_UpdateProfileForm> {
  final _debouncer = Debouncer();
  final _formKey = GlobalKey<FormState>();

  final _profileImage = ValueNotifier<({File? newImage, String? old})>(
    (newImage: null, old: null),
  );
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _coords = ValueNotifier<LatLng?>(null);

  bool _initialized = false;
  late UserModel old = UserModel.dummyUser;

  void _initFields(UserModel user) {
    old = user;
    final latLng =
        user.isUserLocationSet ? LatLng(user.latitude!, user.longitude!) : null;

    _profileImage.value = (
      old: user.image,
      newImage: _profileImage.value.newImage,
    );
    _fullnameController.text = user.fullname;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _addressController.text = user.location ?? '';
    _coords.value = latLng;
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _profileImage.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _coords.dispose();
    _formKey.currentState?.dispose();
    _initialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverList.list(
        children: [
          Center(child: _profilePicture),
          const SizedBox(height: 24),
          CustomTextFormField(
            controller: _fullnameController,
            debounce: true,
            debouncer: _debouncer,
            validator: Validatorless.required('Fullname required'),
            decoration: const InputDecoration(
              labelText: 'Fullname',
              hintText: 'John Doe',
              helperText: '',
            ),
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: _usernameController,
            debounce: true,
            debouncer: _debouncer,
            validator: Validatorless.multiple([
              Validatorless.min(3, 'Must have at least 3 character'),
              Validatorless.required('Username required'),
              Validatorless.regex(
                RegExp(r'^[a-zA-Z0-9_-]+$'),
                'Invalid username',
              ),
            ]),
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'johndoe',
              helperText: '',
            ),
          ),
          const SizedBox(height: 8),
          CustomTextFormField(
            controller: _emailController,
            debounce: true,
            debouncer: _debouncer,
            validator: Validatorless.multiple([
              Validatorless.required('Email required'),
              Validatorless.email('Invalid email'),
            ]),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'johndoe@email.com',
              helperText: '',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.highlightLocationField ?? false
                  ? context.colorScheme.primaryContainer
                  : null,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextFormField(
                  autoFocus: widget.highlightLocationField,
                  controller: _addressController,
                  debounce: true,
                  debouncer: _debouncer,
                  minLines: 2,
                  maxLength: 255,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    alignLabelWithHint: true,
                    hintText: 'abc street',
                    helperText: '',
                  ),
                ),
                const SizedBox(height: 8),
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
              ],
            ),
          ),
          _submitButton,
        ],
      ),
    );
  }

  Widget get _profilePicture {
    const double size = 120;

    return BlocConsumer<UpdateProfileCubit, UpdateProfileState>(
      listener: (context, state) => state.whenOrNull(
        initial: () => SimpleLoadingDialog.hide(context),
        loading: () => SimpleLoadingDialog.show(context),
        loaded: (user) {
          if (_initialized) return;
          _initialized = true;
          return _initFields(user);
        },
        success: (userWithAuth) async {
          SimpleLoadingDialog.hide(context);
          if (userWithAuth.newAuth != null) {
            context.read<AuthBloc>().add(AuthEvent.authenticate(
                  user: userWithAuth.user,
                  newAuth: userWithAuth.newAuth!,
                ));
          } else {
            context.read<AuthBloc>().add(
                  AuthEvent.updateUserDetails(user: userWithAuth.user),
                );
          }
          await SuccessBottomSheet.show(context);
          if (context.mounted) context.pop();
          return;
        },
        failed: (exception) async {
          SimpleLoadingDialog.hide(context);
          return ErrorDialog.show(context, exception);
        },
      ),
      builder: (context, state) {
        return ValueListenableBuilder(
          valueListenable: _profileImage,
          builder: (context, img, _) {
            final oldImage = img.old;
            final newImage = img.newImage;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colorScheme.secondaryContainer,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: InkWelledStack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    onTap: () async {
                      final image = await PickImageDialog.show(
                        context,
                        withShowButton: false,
                      ).then((value) async {
                        if (value == null) return null;
                        return await FilePicker.pickSingleImage(
                                fromCamera: value == 2)
                            .then((file) async {
                          if (file == null) return null;
                          return await FilePicker.cropImage(
                            file: file,
                            maxWidth: 360,
                            ratioX: 1,
                            ratioY: 1,
                          );
                        });
                      });
                      if (image != null) {
                        _profileImage.value = (
                          newImage: image,
                          old: oldImage,
                        );
                      }
                    },
                    children: [
                      state.maybeWhen(
                        orElse: () => Icon(
                          Icons.person_outline,
                          size: 48,
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                        loaded: (user) {
                          if (newImage != null) {
                            return CustomFileImage(file: newImage);
                          } else if (oldImage == null) {
                            return Icon(
                              Icons.person_outline,
                              size: 48,
                              color: context.colorScheme.onSecondaryContainer,
                            );
                          }

                          return CustomNetworkImage(
                            src: oldImage,
                            errorWidget: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: context.colorScheme.onSecondaryContainer,
                            ),
                            cached: false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if ((oldImage != null || newImage != null) || old.image != null)
                  Positioned(
                    right: -5,
                    top: -5,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        onPressed: () {
                          if (newImage != null) {
                            _profileImage.value = (
                              newImage: null,
                              old: oldImage,
                            );
                          } else if (oldImage != null) {
                            _profileImage.value = (
                              newImage: newImage,
                              old: null,
                            );
                          } else {
                            _profileImage.value = (
                              newImage: newImage,
                              old: old.image,
                            );
                          }
                        },
                        icon: Icon(
                          newImage != null
                              ? Icons.delete_forever
                              : oldImage != null
                                  ? Icons.delete
                                  : Icons.undo,
                          color: context.colorScheme.onError,
                          size: 20,
                        ),
                        tooltip: newImage != null
                            ? oldImage != null
                                ? 'Revert'
                                : 'Delete'
                            : oldImage != null
                                ? 'Delete'
                                : 'Undo',
                        style: IconButton.styleFrom(
                          backgroundColor: newImage != null
                              ? context.colorScheme.error.withOpacity(0.5)
                              : oldImage != null
                                  ? context.colorScheme.error.withOpacity(0.5)
                                  : context.colorScheme.primary
                                      .withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
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
                  if (_addressController.text.isEmpty) {
                    await Future.delayed(const Duration(seconds: 1));
                    final address =
                        await LocationService.addressFromLatLong(coords);
                    if (address != null) {
                      _addressController.text = address;
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
                if (_addressController.text.isEmpty) {
                  await Future.delayed(const Duration(seconds: 1));
                  final address =
                      await LocationService.addressFromLatLong(coords);
                  if (address != null) {
                    _addressController.text = address;
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

  Widget get _submitButton {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
        builder: (context, state) {
          return FilledButton(
            onPressed: state.maybeWhen(
              loading: () => null,
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
    if (!_initialized) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    bool isUsernameChanged = _usernameController.value.text != old.username;
    bool isEmailChanged = _emailController.value.text != old.email;

    final updatedUser = UpdateUserModel(
      image: _profileImage.value.newImage,
      deleteImage: _profileImage.value.old == null &&
              _profileImage.value.newImage == null
          ? true
          : null,
      fullname: _fullnameController.value.text,
      username: isUsernameChanged ? _usernameController.value.text : null,
      email: isEmailChanged ? _emailController.value.text : null,
      location: _addressController.value.text,
      latitude: _coords.value?.latitude,
      longitude: _coords.value?.longitude,
    );

    context.read<UpdateProfileCubit>().updateUserProfile(updatedUser);
  }
}
