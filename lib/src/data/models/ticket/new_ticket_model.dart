// ignore_for_file: invalid_annotation_target

import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_ticket_model.freezed.dart';
part 'new_ticket_model.g.dart';

typedef NewTicketWithImage = ({File? file, NewTicketModel ticket});

@freezed
class NewTicketModel with _$NewTicketModel {
  const NewTicketModel._();

  const factory NewTicketModel({
    @JsonKey(includeFromJson: false, includeToJson: false) File? imageFile,
    required String name,
    required num price,
    required int stock,
    @Default(false) bool hasImage,
    required DateTime salesOpenDate,
    DateTime? purchaseDeadline,
  }) = _NewTicketModel;

  factory NewTicketModel.fromJson(Map<String, dynamic> json) =>
      _$NewTicketModelFromJson(json);
}
