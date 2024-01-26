import 'dart:async';

import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
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
    splashing(context);
    return Scaffold(body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
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
    );
  }
}
