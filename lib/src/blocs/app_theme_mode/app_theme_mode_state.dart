part of 'app_theme_mode_cubit.dart';

@freezed
class AppThemeModeState with _$AppThemeModeState {
  const factory AppThemeModeState.light() = _LightThemeState;
  const factory AppThemeModeState.dark() = _DarkThemeState;
}
