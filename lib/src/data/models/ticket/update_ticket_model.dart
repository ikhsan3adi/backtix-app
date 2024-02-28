import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_ticket_model.freezed.dart';

@freezed
class UpdateTicketModel with _$UpdateTicketModel {
  const factory UpdateTicketModel({
    File? newImageFile,
    String? name,
    num? price,
    int? additionalStock,
    DateTime? salesOpenDate,
    DateTime? purchaseDeadline,
    @Default(false) bool deleteImage,
  }) = _UpdateTicketModel;
}
