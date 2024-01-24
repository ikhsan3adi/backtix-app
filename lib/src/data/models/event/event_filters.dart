enum EventFilterType { location, category, keyword }

class EventFilters {
  final EventFilterType type;
  final String filter;

  const EventFilters(this.type, this.filter);

  static List<EventFilters> filters = [
    const EventFilters(EventFilterType.location, 'Bandung'),
    const EventFilters(EventFilterType.location, 'Jakarta'),
    const EventFilters(EventFilterType.category, 'Music'),
    const EventFilters(EventFilterType.category, 'Sport'),
    const EventFilters(EventFilterType.category, 'Education'),
    const EventFilters(EventFilterType.keyword, 'Viral'),
  ];
}
