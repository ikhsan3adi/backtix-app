import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/user_activation/user_activation_cubit.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:validatorless/validatorless.dart';

class OtpActivationPage extends StatelessWidget {
  const OtpActivationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.height / 8),
            child: Text(
              'Activate your account',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BlocProvider(
            create: (_) => GetIt.I<UserActivationCubit>()..requestActivation(),
            child: Builder(
              builder: (_) {
                return BlocListener<UserActivationCubit, UserActivationState>(
                  listener: (context, state) {
                    state.whenOrNull(
                      success: (user) => context
                          .read<AuthBloc>()
                          .add(AuthEvent.updateUserDetails(user: user)),
                      error: (error) => ErrorDialog.show(context, error),
                    );
                  },
                  child: const _OtpActivationForm(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpActivationForm extends StatefulWidget {
  const _OtpActivationForm();

  @override
  State<_OtpActivationForm> createState() => _OtpActivationFormState();
}

class _OtpActivationFormState extends State<_OtpActivationForm> {
  final _formKey = GlobalKey<FormState>();

  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            validator: Validatorless.multiple([
              Validatorless.number('Value not a number'),
              Validatorless.required('OTP required'),
            ]),
          ),
          BlocBuilder<UserActivationCubit, UserActivationState>(
            builder: (context, state) {
              final bloc = context.read<UserActivationCubit>();
              return FilledButton.icon(
                onPressed: state.maybeWhen(
                  loading: null,
                  success: null,
                  orElse: () => () {
                    if (_formKey.currentState?.validate() ?? false) {
                      bloc.activateUser(otp: _otpController.value.text);
                    }
                  },
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: state.maybeWhen(
                  loading: () => const Text('Loading...'),
                  orElse: () => const Text('Login'),
                ),
              );
            },
          ),
          Row(
            children: [
              const Text('Doesn\'t receive an email?'),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  context.read<UserActivationCubit>().requestActivation();
                },
                child: Text(
                  'Resend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}