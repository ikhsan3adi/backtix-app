import 'dart:io';

import 'package:backtix_app/src/data/models/ticket/new_ticket_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_event_model.freezed.dart';

@freezed
class NewEventModel with _$NewEventModel {
  const NewEventModel._();

  const factory NewEventModel({
    required String name,
    required String description,
    required DateTime date,
    DateTime? endDate,
    required String location,
    double? latitude,
    double? longitude,
    @Default([]) List<String> categories,
    @Default([]) List<String> imageDescriptions,
    @Default([]) List<NewTicketModel> tickets,
    @Default([]) List<File> eventImageFiles,
    @Default([]) List<File> ticketImageFiles,
  }) = _NewEventModel;

  static List<String> initialCategories = [
    'Music',
    'Sport',
    'Education',
    'Business',
    'Tech',
    'Culinary',
  ];
}
