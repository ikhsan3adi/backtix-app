import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/login/login_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.initialUsername});

  final String? initialUsername;

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
            create: (_) => GetIt.I<LoginBloc>(),
            child: Builder(
              builder: (context) {
                return BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    state.whenOrNull(
                      success: (auth) => context
                          .read<AuthBloc>()
                          .add(AuthEvent.authenticate(newAuth: auth)),
                      error: (error) => ErrorDialog.show(context, error),
                    );
                  },
                  child: _UsernameLoginForm(
                    initialUsername: initialUsername,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Don\'t have an account?'),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => context.goNamed(RouteNames.register),
                  child: Text(
                    'Sign up',
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

class _UsernameLoginForm extends StatefulWidget {
  const _UsernameLoginForm({this.initialUsername});

  final String? initialUsername;

  @override
  State<_UsernameLoginForm> createState() => _UsernameLoginFormState();
}

class _UsernameLoginFormState extends State<_UsernameLoginForm> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.initialUsername ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
          BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              final bloc = context.read<LoginBloc>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        if (_formKey.currentState?.validate() ?? false) {
                          bloc.add(
                            LoginEvent.usernamelogin(
                              username: _usernameController.value.text,
                              password: _passwordController.value.text,
                            ),
                          );
                        }
                      },
                    ),
                    icon: const Icon(Icons.login_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: state.maybeWhen(
                        loading: () => const Text('Loading...'),
                        orElse: () => const Text('Login'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: state.maybeWhen(
                      loading: null,
                      success: null,
                      orElse: () => () {
                        bloc.add(const LoginEvent.googleSignIn());
                      },
                    ),
                    icon: const Icon(Icons.login_outlined),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('Sign in with Google'),
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
      controller: _usernameController,
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
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: Validatorless.multiple([
        Validatorless.between(8, 64, 'Must have minimum 8 character'),
        Validatorless.required('Password required'),
      ]),
      decoration: InputDecoration(
        labelText: 'Enter your password',
        helperText: '',
        suffixIcon: IconButton(
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
  ];
}