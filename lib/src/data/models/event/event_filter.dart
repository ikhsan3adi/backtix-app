enum EventFilterType { location, category, keyword }

class EventFilter {
  final EventFilterType type;
  final String filter;

  const EventFilter(this.type, this.filter);

  static const List<EventFilter> filters = [
    EventFilter(EventFilterType.location, 'Bandung'),
    EventFilter(EventFilterType.location, 'Jakarta'),
    EventFilter(EventFilterType.category, 'Music'),
    EventFilter(EventFilterType.category, 'Sport'),
    EventFilter(EventFilterType.category, 'Education'),
    EventFilter(EventFilterType.keyword, 'Viral'),
  ];
}
