import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ThemeToggleIconButton extends StatelessWidget {
  const ThemeToggleIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => context.read<ThemeModeCubit>().toggleTheme(),
      icon: BlocBuilder<ThemeModeCubit, ThemeMode>(
        builder: (context, state) {
          return switch (state) {
            ThemeMode.dark => const FaIcon(FontAwesomeIcons.sun),
            ThemeMode.light => const FaIcon(FontAwesomeIcons.moon),
            _ => const FaIcon(FontAwesomeIcons.sun),
          };
        },
      ),
    );
  }
}
