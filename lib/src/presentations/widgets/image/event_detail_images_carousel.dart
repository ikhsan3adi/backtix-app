import 'package:backtix_app/src/blocs/events/published_event_detail/published_event_detail_cubit.dart';
import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventDetailImagesCarousel extends StatefulWidget {
  const EventDetailImagesCarousel({
    super.key,
    this.heroImageTag,
    this.heroImageUrl,
    this.height = 450.0,
  });

  final Object? heroImageTag;
  final String? heroImageUrl;
  final double height;

  @override
  State<EventDetailImagesCarousel> createState() =>
      _EventDetailImagesCarouselState();
}

class _EventDetailImagesCarouselState extends State<EventDetailImagesCarousel> {
  final _indexNotifier = ValueNotifier(0);

  @override
  void dispose() {
    _indexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: BlocBuilder<PublishedEventDetailCubit, PublishedEventDetailState>(
        builder: (context, state) {
          return state.maybeMap(
            orElse: () =>
                widget.heroImageUrl != null && widget.heroImageTag != null
                    ? SizedBox(
                        height: widget.height,
                        width: context.width,
                        child: Hero(
                          tag: widget.heroImageTag!,
                          child: CustomNetworkImage(src: widget.heroImageUrl!),
                        ),
                      )
                    : const Shimmer(),
            loaded: (state) {
              final images = state.event.images;

              if (images.isEmpty) {
                return const Center(
                  child: ImageErrorWidget(text: 'Image not found'),
                );
              }

              final viewerImageProviders = images
                  .asMap()
                  .map((index, e) => MapEntry(
                        index,
                        index < 5
                            ? CachedNetworkImageProvider(e.image)
                            : NetworkImage(e.image) as ImageProvider,
                      ))
                  .values
                  .toList();

              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: widget.height + 72,
                      enableInfiniteScroll: false,
                      padEnds: false,
                      viewportFraction: 1,
                      onPageChanged: (index, _) => _indexNotifier.value = index,
                    ),
                    items: List.generate(
                      images.length,
                      (index) {
                        return GestureDetector(
                          onTap: () => showImageViewerPager(
                            context,
                            MultiImageProvider(
                              viewerImageProviders,
                              initialIndex: index,
                            ),
                            doubleTapZoomable: true,
                            swipeDismissible: true,
                          ),
                          child: AspectRatio(
                            aspectRatio: 2,
                            child: CustomNetworkImage(
                              src: images[index].image,
                              cached: index < 5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _indexNotifier,
                          builder: (_, index, __) {
                            if (images[index].description.trim().isEmpty) {
                              return const SizedBox();
                            }
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.all(8),
                              child: ConstrainedBox(
                                constraints: BoxConstraints.loose(
                                  Size.fromWidth(context.width * .72),
                                ),
                                child: MarqueeWidget(
                                  pauseDuration: const Duration(seconds: 2),
                                  child: Text(
                                    images[index].description.trim(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black38,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.all(8),
                          child: ValueListenableBuilder(
                            valueListenable: _indexNotifier,
                            builder: (_, index, __) {
                              return Text(
                                '${index + 1}/${images.length}',
                                style: const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
