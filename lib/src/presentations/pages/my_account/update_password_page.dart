import 'package:backtix_app/src/blocs/user/update_password/update_password_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

class UpdatePasswordPage extends StatelessWidget {
  const UpdatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Update Password'),
      ),
      body: ResponsivePadding(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: BlocProvider(
                create: (_) => GetIt.I<UpdatePasswordCubit>(),
                child: const _UpdatePasswordForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatePasswordForm extends StatefulWidget {
  const _UpdatePasswordForm();

  @override
  State<_UpdatePasswordForm> createState() => _UpdatePasswordFormState();
}

class _UpdatePasswordFormState extends State<_UpdatePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer();

  final _oldPasswordController = TextEditingController();
  final _obscurePassword0 = ValueNotifier(true);

  final _newPasswordController = TextEditingController();
  final _obscurePassword1 = ValueNotifier(true);

  @override
  void dispose() {
    _obscurePassword0.dispose();
    _obscurePassword1.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverList.list(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _obscurePassword0,
            builder: (context, value, widget) {
              return CustomTextFormField(
                controller: _oldPasswordController,
                obscureText: value,
                debounce: true,
                debouncer: _debouncer,
                validator: Validatorless.multiple([
                  Validatorless.between(8, 64, 'Must have minimum 8 character'),
                  Validatorless.required('Password required'),
                ]),
                decoration: InputDecoration(
                  labelText: 'Old password',
                  helperText: '',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _obscurePassword0.value = !_obscurePassword0.value;
                    },
                    icon: Icon(
                      value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: _obscurePassword1,
            builder: (context, value, widget) {
              return CustomTextFormField(
                controller: _newPasswordController,
                obscureText: value,
                debounce: true,
                debouncer: _debouncer,
                validator: Validatorless.multiple([
                  Validatorless.between(8, 64, 'Must have minimum 8 character'),
                  Validatorless.required('Password required'),
                ]),
                decoration: InputDecoration(
                  labelText: 'New password',
                  helperText: '',
                  suffixIcon: IconButton(
                    onPressed: () {
                      _obscurePassword1.value = !_obscurePassword1.value;
                    },
                    icon: Icon(
                      value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BlocConsumer<UpdatePasswordCubit, UpdatePasswordState>(
            listener: (context, state) => state.whenOrNull(
              initial: () => SimpleLoadingDialog.hide(context),
              loading: () => SimpleLoadingDialog.show(context),
              success: (_) async {
                SimpleLoadingDialog.hide(context);
                await SuccessBottomSheet.show(
                  context,
                  text: 'Password updated!',
                );
                if (context.mounted) context.pop();
                return;
              },
              failed: (exception) async {
                SimpleLoadingDialog.hide(context);
                return ErrorDialog.show(context, exception);
              },
            ),
            builder: (context, state) {
              final bloc = context.read<UpdatePasswordCubit>();
              return FilledButton.icon(
                onPressed: state.maybeWhen(
                  loading: null,
                  success: null,
                  orElse: () => () {
                    if (_formKey.currentState?.validate() ?? false) {
                      bloc.updateUserPassword(
                        oldPassword: _oldPasswordController.value.text,
                        newPassword: _newPasswordController.value.text,
                      );
                    }
                  },
                ),
                icon: const Icon(Icons.login_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: state.maybeWhen(
                    loading: () => const Text('Loading...'),
                    orElse: () => const Text('Update Password'),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Forgot your password?'),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => context.pushReplacementNamed(
                    RouteNames.resetPassword,
                  ),
                  child: Text(
                    'Reset my password',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
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
