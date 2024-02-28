import 'package:flutter/material.dart';

/// Used for overflowing text
class MarqueeWidget extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final Duration animationDuration, backDuration, pauseDuration;

  const MarqueeWidget({
    super.key,
    required this.child,
    this.direction = Axis.horizontal,
    this.animationDuration = const Duration(milliseconds: 2500),
    this.backDuration = const Duration(milliseconds: 1000),
    this.pauseDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<MarqueeWidget> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(scroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: widget.direction,
      controller: _controller,
      child: widget.child,
    );
  }

  void scroll(_) async {
    while (_controller.hasClients && _controller.position.maxScrollExtent > 0) {
      await Future.delayed(widget.pauseDuration);
      if (_controller.hasClients) {
        await _controller.animateTo(
          _controller.position.maxScrollExtent,
          duration: widget.animationDuration,
          curve: Curves.linear,
        );
      }
      await Future.delayed(widget.pauseDuration);
      if (_controller.hasClients) {
        await _controller.animateTo(
          0.0,
          duration: widget.backDuration,
          curve: Curves.ease,
        );
      }
    }
  }
}
