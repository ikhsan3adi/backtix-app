import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_ticket_model.freezed.dart';
part 'new_ticket_model.g.dart';

typedef NewTicketWithImage = ({File? file, NewTicketModel ticket});

@freezed
class NewTicketModel with _$NewTicketModel {
  const NewTicketModel._();

  const factory NewTicketModel({
    required String name,
    required num price,
    required int stock,
    @Default(false) bool hasImage,
    DateTime? salesOpenDate,
    DateTime? purchaseDeadline,
  }) = _NewTicketModel;

  factory NewTicketModel.fromJson(Map<String, dynamic> json) =>
      _$NewTicketModelFromJson(json);
}
