import 'package:backtix_app/src/blocs/tickets/my_ticket_purchases/my_ticket_purchases_bloc.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_query.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class MyTicketsHistoryPage extends StatelessWidget {
  const MyTicketsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsivePadding(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('History'),
        ),
        body: BlocProvider(
          create: (_) => GetIt.I<MyTicketPurchasesBloc>()
            ..add(const MyTicketPurchasesEvent.getMyTicketPurchases(
              TicketPurchaseQuery(used: true),
            )),
          child: const TicketPurchaseList(),
        ),
      ),
    );
  }
}
