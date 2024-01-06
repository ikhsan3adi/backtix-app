part of 'onboarding_cubit.dart';

@freezed
sealed class OnboardingState with _$OnboardingState {
  const factory OnboardingState.initial() = _Initial;
  const factory OnboardingState.unfinish() = _Unfinish;
  const factory OnboardingState.finished() = _Finished;
}
