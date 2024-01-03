import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'app_theme_mode_cubit.freezed.dart';
part 'app_theme_mode_state.dart';

class AppThemeModeCubit extends HydratedCubit<AppThemeModeState> {
  AppThemeModeCubit() : super(const AppThemeModeState.light());

  void toggleTheme([bool dark = false]) {
    emit(
      dark ? const AppThemeModeState.dark() : const AppThemeModeState.light(),
    );
  }

  @override
  AppThemeModeState? fromJson(Map<String, dynamic> json) {
    bool isDark = json['isDark'] ?? false;
    return isDark
        ? const AppThemeModeState.dark()
        : const AppThemeModeState.light();
  }

  @override
  Map<String, dynamic>? toJson(AppThemeModeState state) {
    return {
      'isDark': state.maybeWhen(
        dark: () => true,
        orElse: () => false,
      )
    };
  }
}
