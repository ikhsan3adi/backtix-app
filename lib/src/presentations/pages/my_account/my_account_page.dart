import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/user/user_model.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/utils/utils.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const ThemeToggleIconButton(),
        centerTitle: true,
        title: const Text('My Account'),
        actions: [
          IconButton(
            onPressed: () => context.goNamed(RouteNames.updateProfile),
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          context.read<AuthBloc>().add(const AuthEvent.updateUserDetails());
        },
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: _MyAccount(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyAccount extends StatelessWidget {
  const _MyAccount();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final (user, hasUser) = state.maybeWhen(
          authenticated: (user, _) => (user, true),
          orElse: () => (UserModel.dummyUser, false),
        );

        final noProfileImageWidget = Text(
          user.fullname.splitMapJoin(
            ' ',
            onMatch: (v) => '',
            onNonMatch: (v) => v[0],
          ),
        );

        return SliverList.list(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  foregroundColor: context.colorScheme.onTertiary,
                  backgroundColor: context.colorScheme.tertiary,
                  child: hasUser
                      ? user.image != null
                          ? Container(
                              clipBehavior: Clip.hardEdge,
                              constraints: const BoxConstraints.expand(),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CustomNetworkImage(
                                src: user.image!,
                                errorWidget: noProfileImageWidget,
                              ),
                            )
                          : noProfileImageWidget
                      : const Icon(Icons.person),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullname,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(user.username),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _balanceCards,
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: FilledButton.tonal(
                onPressed: () => context.goNamed(RouteNames.withdraw),
                child: const Text('Withdraw requests'),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outlined),
              title: const Text('********'),
              subtitle: const Text('Password'),
              trailing: TextButton(
                onPressed: () => context.goNamed(RouteNames.updatePassword),
                child: const Text('Change password'),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.alternate_email_outlined),
              title: Text(user.email),
              subtitle: const Text('Email'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_pin),
              title: Text(
                user.location ?? 'Not set',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                user.isUserLocationSet
                    ? '${user.latitude?.toStringAsFixed(4)}, ${user.longitude?.toStringAsFixed(4)}'
                    : 'Location coordinates not set',
              ),
              trailing: TextButton(
                onPressed: () => context.goNamed(
                  RouteNames.updateProfile,
                  queryParameters: {'location': 'true'},
                ),
                child: Text(user.isUserLocationSet
                    ? 'Update location'
                    : 'Set your location'),
              ),
            ),
            _logoutButton,
          ],
        );
      },
    );
  }

  Widget get _balanceCards {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user, _) => user,
          orElse: () => UserModel.dummyUser,
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.colorScheme.primaryContainer,
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWelledStack(
                  onTap: () => context.goNamed(RouteNames.withdraw),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Balance',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: context.colorScheme.onSurface,
                              ),
                            ],
                          ),
                          Text(
                            Utils.toCurrency(user.balance.balance),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: context.colorScheme.tertiaryContainer,
                ),
                clipBehavior: Clip.hardEdge,
                child: InkWelledStack(
                  onTap: () => context.goNamed(
                    RouteNames.withdraw,
                    queryParameters: {'from': 'revenue'},
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Revenue',
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.show_chart_outlined,
                                color: context.colorScheme.onSurface,
                              ),
                            ],
                          ),
                          Text(
                            Utils.toCurrency(user.balance.revenue),
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: context.colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget get _logoutButton {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          bool loggingout = false;
          return FilledButton.icon(
            onPressed: state.mapOrNull(
              authenticated: (_) => () {
                if (loggingout) return;
                loggingout = true;
                context
                    .read<AuthBloc>()
                    .add(const AuthEvent.removeAuthentication());
              },
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: FilledButton.styleFrom(
              foregroundColor: context.colorScheme.onError,
              backgroundColor: context.colorScheme.error,
            ),
          );
        },
      ),
    );
  }
}
