import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'onboarding_cubit.freezed.dart';
part 'onboarding_state.dart';

class OnboardingCubit extends HydratedCubit<OnboardingState> {
  OnboardingCubit() : super(const OnboardingState.initial());

  void finishOnboarding() async => emit(const OnboardingState.finished());

  @override
  OnboardingState? fromJson(Map<String, dynamic> json) {
    bool onboardingFinished = json['onboardingFinished'] ?? false;
    return onboardingFinished
        ? const OnboardingState.finished()
        : const OnboardingState.unfinish();
  }

  @override
  Map<String, dynamic>? toJson(OnboardingState state) {
    return {
      'onboardingFinished': switch (state) {
        _Finished() => true,
        _Unfinish() => false,
        _ => false,
      },
    };
  }
}
