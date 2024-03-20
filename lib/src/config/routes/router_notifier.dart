import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class RouterNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;

  RouterNotifier({required AuthBloc authBloc}) : _authBloc = authBloc {
    _authBloc.stream.listen((_) => notifyListeners());
  }

  String? redirect(_, GoRouterState state) {
    // if (kDebugMode) {
    //   debugPrint(_authBloc.state);
    //   debugPrint(state.matchedLocation);
    // }

    return _authBloc.state.whenOrNull(
      unauthenticated: (_) {
        switch (state.matchedLocation) {
          case '/':
          case '/onboarding':
          case '/login':
          case '/login/register':
            return null;
          default:
            return '/login';
        }
      },
      authenticated: (user, _) {
        if (!user.activated) return '/activation';

        switch (state.matchedLocation) {
          case '/login':
          case '/login/register':
          case '/activation':
            return '/home';
        }
        return null;
      },
    );
  }
}
