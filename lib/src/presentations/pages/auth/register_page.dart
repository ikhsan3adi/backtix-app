import 'dart:io';

import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/register/register_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/auth/register_user_model.dart';
import 'package:backtix_app/src/data/services/remote/google_auth_service.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:validatorless/validatorless.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
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
              'Enter your details to continue',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          BlocProvider(
            create: (_) => GetIt.I<RegisterBloc>(),
            child: Builder(builder: (_) {
              return BlocListener<RegisterBloc, RegisterState>(
                listener: (context, state) {
                  state.whenOrNull(
                    success: (user, auth, isRegistered) {
                      if (auth != null && (isRegistered)) {
                        Toast.show(context, msg: 'User has been registered');
                        return context
                            .read<AuthBloc>()
                            .add(AuthEvent.authenticate(newAuth: auth));
                      } else if (user != null) {
                        Toast.show(context, msg: 'User register successful');
                        return context.goNamed(
                          RouteNames.login,
                          queryParameters: {'username': user.username},
                        );
                      }
                      Toast.show(context, msg: 'Sign up failed, try again');
                    },
                    error: (error) => ErrorDialog.show(context, error),
                  );
                },
                child: const _RegisterUserForm(),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Already have an account?'),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => context.goNamed(RouteNames.login),
                  child: Text(
                    'Sign in',
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

class _RegisterUserForm extends StatefulWidget {
  const _RegisterUserForm();

  @override
  State<_RegisterUserForm> createState() => _RegisterUserFormState();
}

class _RegisterUserFormState extends State<_RegisterUserForm> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _obscurePassword = ValueNotifier(true);

  final _debouncer = Debouncer();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _obscurePassword.dispose();
    _formKey.currentState?.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...formWidgets,
          const SizedBox(height: 16),
          BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
              final bloc = context.read<RegisterBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final user = RegisterUserModel(
                            email: _emailController.value.text,
                            username: _usernameController.value.text,
                            fullname: _fullnameController.value.text,
                            password: _passwordController.value.text,
                          );

                          bloc.add(RegisterEvent.registerUser(user));
                        }
                      },
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        state.maybeWhen(
                          loading: () => 'Loading...',
                          orElse: () => 'Register',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        if (GoogleAuthService.supported) {
                          return bloc.add(const RegisterEvent.googleSignUp());
                        }
                        context.showSimpleTextSnackBar(
                          'Google sign up not supported on ${Platform.operatingSystem}',
                        );
                      },
                    ),
                    icon: const FaIcon(FontAwesomeIcons.google),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sign Up with Google'),
                    ),
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  late final formWidgets = [
    CustomTextFormField(
      controller: _emailController,
      debounce: true,
      debouncer: _debouncer,
      validator: Validatorless.multiple([
        Validatorless.email('Value is not email'),
        Validatorless.required('Email required'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Enter your email',
        helperText: '',
      ),
    ),
    const SizedBox(height: 8),
    CustomTextFormField(
      controller: _usernameController,
      debounce: true,
      debouncer: _debouncer,
      validator: Validatorless.multiple([
        Validatorless.between(3, 16, 'Must have between 3 and 16 character'),
        Validatorless.required('Username required'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Enter your username',
        helperText: '',
      ),
    ),
    const SizedBox(height: 8),
    CustomTextFormField(
      controller: _fullnameController,
      debounce: true,
      debouncer: _debouncer,
      validator: Validatorless.required('Full name required'),
      decoration: const InputDecoration(
        labelText: 'Enter your full name',
        helperText: '',
      ),
    ),
    const SizedBox(height: 8),
    ValueListenableBuilder<bool>(
      valueListenable: _obscurePassword,
      builder: (context, value, widget) {
        return CustomTextFormField(
          controller: _passwordController,
          obscureText: value,
          debounce: true,
          debouncer: _debouncer,
          validator: Validatorless.multiple([
            Validatorless.required('Password required'),
            Validatorless.between(8, 64, 'Must have minimum 8 character'),
            Validatorless.regex(
              RegExp(RegexPattern.passwordHard),
              'Password must contains uppercase, lowercase, number and symbol',
            ),
          ]),
          decoration: InputDecoration(
            labelText: 'Enter your password',
            helperText: '',
            errorMaxLines: 2,
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
    const SizedBox(height: 8),
    CustomTextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      debounce: true,
      debouncer: _debouncer,
      validator: Validatorless.multiple([
        Validatorless.between(8, 64, 'Must have minimum 8 character'),
        Validatorless.required('Password confirmation required'),
        Validatorless.compare(_passwordController, 'Passwords do not match'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Confirm your password',
        helperText: '',
      ),
    ),
  ];
}
