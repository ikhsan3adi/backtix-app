import 'package:backtix_app/src/blocs/user/reset_password/reset_password_cubit.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reset Password'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: BlocProvider(
              create: (_) =>
                  GetIt.I<ResetPasswordCubit>()..requestPasswordReset(),
              child: const _ResetPasswordForm(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetPasswordForm extends StatefulWidget {
  const _ResetPasswordForm();

  @override
  State<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<_ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _debouncer = Debouncer();

  final _resetCodeController = TextEditingController();

  final _newPasswordController = TextEditingController();
  final _obscurePassword = ValueNotifier(true);

  final _resendCount = ValueNotifier(0);

  @override
  void dispose() {
    _obscurePassword.dispose();
    _resetCodeController.dispose();
    _newPasswordController.dispose();
    _resendCount.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SliverList.list(
        children: [
          CustomTextFormField(
            controller: _resetCodeController,
            debounce: true,
            debouncer: _debouncer,
            keyboardType: TextInputType.number,
            validator: Validatorless.multiple([
              Validatorless.number('Value not a number'),
              Validatorless.required('Reset code required'),
            ]),
            decoration: const InputDecoration(
              labelText: 'Reset code',
              helperText: '',
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<bool>(
            valueListenable: _obscurePassword,
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
                      _obscurePassword.value = !_obscurePassword.value;
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
          BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
            listener: (context, state) => state.whenOrNull(
              initial: () => SimpleLoadingDialog.hide(context),
              loading: () => SimpleLoadingDialog.show(context),
              success: (userWithAuth) async {
                SimpleLoadingDialog.hide(context);
                await SuccessBottomSheet.show(
                  context,
                  text: 'Password updated!',
                );
                if (context.mounted) context.pop();
                return;
              },
              error: (exception) async {
                SimpleLoadingDialog.hide(context);
                return ErrorDialog.show(context, exception);
              },
            ),
            builder: (context, state) {
              final bloc = context.read<ResetPasswordCubit>();
              return FilledButton.icon(
                onPressed: state.maybeWhen(
                  loading: null,
                  success: null,
                  orElse: () => () {
                    if (_formKey.currentState?.validate() ?? false) {
                      bloc.passwordReset(
                        resetCode: _resetCodeController.value.text,
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
            child: ValueListenableBuilder(
              valueListenable: _resendCount,
              builder: (_, value, __) {
                if (value >= 5) {
                  return const SizedBox();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Doesn\'t receive an email?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (value >= 5) return;
                        context
                            .read<ResetPasswordCubit>()
                            .requestPasswordReset();
                        _resendCount.value += 1;
                      },
                      child: Text(
                        'Resend ($value)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
