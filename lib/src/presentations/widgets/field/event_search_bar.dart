import 'package:backtix_app/src/blocs/events/event_search/event_search_cubit.dart';
import 'package:backtix_app/src/config/routes/route_names.dart';
import 'package:backtix_app/src/data/models/event/event_query.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class EventSearchBar extends StatefulWidget {
  const EventSearchBar({super.key, this.keyword});

  final String? keyword;

  @override
  State<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.keyword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: _controller,
      maxLines: 1,
      decoration: InputDecoration(
        isDense: true,
        labelText: 'Search events',
        hintText: 'Festival lorem ipsum',
        floatingLabelBehavior: FloatingLabelBehavior.never,
        suffixIcon: IconButton(
          onPressed: () async {
            if (_controller.value.text.isEmpty) return;

            final isSearchPage =
                GoRouterState.of(context).name == RouteNames.eventSearch;

            if (isSearchPage) {
              return context.read<EventSearchCubit>().getEvents(
                    EventQuery(
                      page: 0,
                      search: _controller.value.text,
                      ongoingOnly: false,
                    ),
                  );
            }
            context.goNamed(
              RouteNames.eventSearch,
              pathParameters: {'search': _controller.value.text},
            );
          },
          icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
        ),
      ),
    );
  }
}
