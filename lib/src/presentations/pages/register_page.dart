import 'package:backtix_app/src/blocs/register/register_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/data/models/auth/register_user_model.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.height / 8),
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
                    success: (user) {
                      // TODO: show snackbar
                      context.goNamed(
                        RouteNames.login,
                        queryParameters: {'username': user.username},
                      );
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

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _fullnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                        bloc.add(const RegisterEvent.googleSignUp());
                      },
                    ),
                    icon: const Icon(Icons.login_outlined),
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
      validator: Validatorless.multiple([
        Validatorless.email('Value is not email'),
        Validatorless.required('Email required'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Enter your email',
        helperText: '',
      ),
    ),
    CustomTextFormField(
      controller: _usernameController,
      validator: Validatorless.multiple([
        Validatorless.between(
          3,
          16,
          'Must have between 3 and 16 character',
        ),
        Validatorless.required('Username required'),
      ]),
      decoration: const InputDecoration(
        labelText: 'Enter your username',
        helperText: '',
      ),
    ),
    CustomTextFormField(
      controller: _fullnameController,
      validator: Validatorless.required('Full name required'),
      decoration: const InputDecoration(
        labelText: 'Enter your full name',
        helperText: '',
      ),
    ),
    CustomTextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: Validatorless.multiple([
        Validatorless.between(8, 64, 'Must have minimum 8 character'),
        Validatorless.required('Password required'),
      ]),
      decoration: InputDecoration(
        labelText: 'Enter your password',
        helperText: '',
        suffixIcon: IconButton.outlined(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    ),
    CustomTextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
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
