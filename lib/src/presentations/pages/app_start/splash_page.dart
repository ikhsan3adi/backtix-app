import 'dart:async';

import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void splashing(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OnboardingState state = context.read<OnboardingCubit>().state;
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
    splashing(context);
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Expanded(
                  flex: 2,
                  child: SvgPicture.asset('assets/images/logo.svg'),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'BACKTIX',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: SpinKitFadingFour(color: context.colorScheme.primary),
            ),
          )
        ],
      ),
    );
  }
}
