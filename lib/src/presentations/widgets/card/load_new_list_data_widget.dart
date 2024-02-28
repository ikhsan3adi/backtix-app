import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadNewListDataWidget extends StatelessWidget {
  const LoadNewListDataWidget({
    super.key,
    required this.reachedMax,
  });

  final bool reachedMax;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 75,
          child: Center(
            child: reachedMax
                ? Text(
                    'No more data available',
                    style: TextStyle(
                      color: context.theme.disabledColor,
                    ),
                  )
                : SpinKitFadingFour(color: context.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
