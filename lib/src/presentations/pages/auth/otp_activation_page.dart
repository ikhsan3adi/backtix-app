import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/user_activation/user_activation_cubit.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
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
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        leadingWidth: context.width / 3,
        leading: TextButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Logout'),
          style: TextButton.styleFrom(
            alignment: AlignmentDirectional.centerStart,
          ),
          onPressed: () async {
            context
                .read<AuthBloc>()
                .add(const AuthEvent.removeAuthentication());
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: context.height / 8,
              top: (context.height / 8) - kToolbarHeight,
            ),
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

  final _resendCount = ValueNotifier(0);

  @override
  void dispose() {
    _otpController.dispose();
    _resendCount.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            debounce: true,
            validator: Validatorless.multiple([
              Validatorless.number('Value not a number'),
              Validatorless.required('OTP required'),
            ]),
            decoration: const InputDecoration(labelText: 'Enter 6-digit OTP'),
          ),
          const SizedBox(height: 16),
          BlocBuilder<UserActivationCubit, UserActivationState>(
            builder: (context, state) {
              final bloc = context.read<UserActivationCubit>();
              return FilledButton.icon(
                onPressed: state.maybeWhen(
                  loading: null,
                  success: null,
                  orElse: () => () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await bloc.activateUser(otp: _otpController.value.text);
                    }
                  },
                ),
                icon: const Icon(Icons.check_circle_outline),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(state.maybeWhen(
                    loading: () => 'Loading...',
                    orElse: () => 'Activate',
                  )),
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
                        context.read<UserActivationCubit>().requestActivation();
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
