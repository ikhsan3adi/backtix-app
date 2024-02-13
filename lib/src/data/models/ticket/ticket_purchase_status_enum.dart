import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum TicketPurchaseStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELLED')
  cancelled;

  @override
  String toString() => name
      .split('')
      .mapWithIndex((e, index) => index == 0 ? e.toUpperCase() : e)
      .join();
}

@JsonEnum()
enum TicketPurchaseRefundStatus {
  @JsonValue('REFUNDING')
  refunding,
  @JsonValue('REFUNDED')
  refunded,
  @JsonValue('DENIED')
  denied;

  @override
  String toString() => name
      .split('')
      .mapWithIndex((e, index) => index == 0 ? e.toUpperCase() : e)
      .join();
}
