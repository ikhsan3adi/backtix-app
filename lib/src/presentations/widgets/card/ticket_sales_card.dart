import 'package:backtix_app/src/blocs/tickets/ticket_sales/ticket_sales_cubit.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_model.dart';
import 'package:backtix_app/src/data/models/ticket/ticket_purchase_status_enum.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TicketSalesCard extends StatelessWidget {
  const TicketSalesCard({
    super.key,
    required this.purchase,
    required this.ticket,
    this.onTap,
  });

  final TicketPurchaseModel purchase;
  final TicketModel ticket;
  final Function(TicketPurchaseModel)? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: InkWelledStack(
        onTap: onTap != null ? () => onTap!(purchase) : null,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              Expanded(
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            constraints: BoxConstraints.loose(Size.infinite),
                            child: MarqueeWidget(
                              child: Row(
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.user,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '@${purchase.user?.username ?? 'Unknown'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              _ApplicableBadge(purchase: purchase),
                              const SizedBox(width: 4),
                              _StatusBadge(purchase: purchase),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('Purchase Date'),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat('dd/MM/y HH:mm:ss')
                                  .format(purchase.createdAt.toLocal()),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Order ID'),
                          MarqueeWidget(
                            child: Text(
                              purchase.orderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.theme.disabledColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price'),
                          Text(
                            Constant.toCurrency(purchase.price),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.primary,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.purchase});

  final TicketPurchaseModel purchase;

  @override
  Widget build(BuildContext context) {
    final query = context
        .read<TicketSalesCubit>()
        .state
        .mapOrNull(loaded: (s) => s.query);

    final showRefundStatus =
        purchase.refundStatus == TicketPurchaseRefundStatus.refunding ||
            (query?.refundStatus != null ||
                query?.status == TicketPurchaseStatus.cancelled);

    final color = showRefundStatus
        ? switch (purchase.refundStatus) {
            TicketPurchaseRefundStatus.refunding => Colors.orange,
            TicketPurchaseRefundStatus.refunded => Colors.green,
            TicketPurchaseRefundStatus.denied => Colors.red,
            _ => null,
          }
        : switch (purchase.status) {
            TicketPurchaseStatus.pending => context.theme.disabledColor,
            TicketPurchaseStatus.completed => Colors.green,
            TicketPurchaseStatus.cancelled => Colors.red,
          };
    final colorDarkTheme = showRefundStatus
        ? switch (purchase.refundStatus) {
            TicketPurchaseRefundStatus.refunding => Colors.orangeAccent,
            TicketPurchaseRefundStatus.refunded => Colors.greenAccent,
            TicketPurchaseRefundStatus.denied => Colors.redAccent,
            _ => null,
          }
        : switch (purchase.status) {
            TicketPurchaseStatus.pending => context.theme.disabledColor,
            TicketPurchaseStatus.completed => Colors.greenAccent,
            TicketPurchaseStatus.cancelled => Colors.redAccent,
          };

    return CustomBadge(
      borderColor: context.isDark ? colorDarkTheme : color,
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2),
      child: showRefundStatus
          ? _refund(foregroundColor: context.isDark ? colorDarkTheme : color)
          : _upcoming(foregroundColor: context.isDark ? colorDarkTheme : color),
    );
  }

  Widget _upcoming({Color? foregroundColor}) {
    return Text(
      purchase.status.toString(),
      style: TextStyle(
        fontSize: 10,
        color: foregroundColor,
      ),
    );
  }

  Widget _refund({Color? foregroundColor}) {
    return Text(
      purchase.refundStatus.toString(),
      style: TextStyle(
        fontSize: 10,
        color: foregroundColor,
      ),
    );
  }
}

class _ApplicableBadge extends StatelessWidget {
  const _ApplicableBadge({required this.purchase});

  final TicketPurchaseModel purchase;

  @override
  Widget build(BuildContext context) {
    final color = purchase.used ? Colors.red : Colors.green;
    final colorDarkTheme =
        purchase.used ? Colors.redAccent : Colors.greenAccent;

    return CustomBadge(
      borderColor: context.isDark ? colorDarkTheme : color,
      padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2),
      child: Text(
        purchase.used ? 'Used' : 'Valid',
        style: TextStyle(
          fontSize: 10,
          color: context.isDark ? colorDarkTheme : color,
        ),
      ),
    );
  }
}
