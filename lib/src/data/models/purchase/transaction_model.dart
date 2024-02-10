// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

enum TransactionStatus { paid, pending }

@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required TransactionStatus status,
    String? token,
    @JsonKey(name: 'redirect_url') String? redirectUrl,
    @JsonKey(name: 'error_messages') List<String>? errorMessages,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
