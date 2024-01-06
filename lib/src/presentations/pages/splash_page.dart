import 'dart:async';

import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void splashing(BuildContext context) {
    OnboardingState state = context.read<OnboardingCubit>().state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () async {
        return state.maybeWhen(
          finished: () => context.goNamed(RouteNames.login),
          orElse: () => context.goNamed(RouteNames.onboarding),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<OnboardingCubit>(),
      child: Builder(
        builder: (context) {
          splashing(context);
          return Scaffold(body: _buildBody(context));
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        const Expanded(flex: 1, child: SizedBox()),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(flex: 1, child: SizedBox()),
              Expanded(
                flex: 2,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: context.width * .35,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'BACKTIX',
                  style: context.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const Expanded(
          flex: 1,
          child: Center(child: CircularProgressIndicator()),
        )
      ],
    );
  }
}
