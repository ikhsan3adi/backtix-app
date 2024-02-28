import 'package:backtix_app/src/presentations/pages/published_events/event_detail_page.dart';

class MyEventDetailPage extends EventDetailPage {
  const MyEventDetailPage({
    super.key,
    required super.id,
    super.name,
    super.heroImageTag,
    super.heroImageUrl,
  }) : super(isPublishedEvent: false);
}
