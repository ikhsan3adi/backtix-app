import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>.value(
      value: GetIt.I<OnboardingCubit>(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: SizedBox(
              height: context.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () async {
                      context.read<OnboardingCubit>().finishOnboarding();
                      context.goNamed(RouteNames.login);
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
