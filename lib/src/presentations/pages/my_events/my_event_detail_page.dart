import 'package:backtix_app/src/presentations/pages/published_events/event_detail_page.dart';

class MyEventDetailPage extends EventDetailPage {
  const MyEventDetailPage({
    super.key,
    required String id,
    String? name,
    Object? heroImageTag,
    String? heroImageUrl,
  }) : super(
          id: id,
          name: name,
          heroImageTag: heroImageTag,
          heroImageUrl: heroImageUrl,
          isPublishedEvent: false,
        );
}
