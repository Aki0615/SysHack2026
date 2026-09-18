import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/core/network/network_activity_provider.dart';

class NetworkActivityIndicator extends ConsumerWidget {
  final Widget child;

  const NetworkActivityIndicator({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive =
        ref.watch(networkActivityVisibilityProvider) &&
        ref.watch(networkActivityProvider) > 0;

    return Stack(
      children: [
        child,
        if (isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.grey.withValues(alpha: 0.52),
                alignment: Alignment.center,
                child: const _NetworkLoadingContent(),
              ),
            ),
          ),
      ],
    );
  }
}

class _NetworkLoadingContent extends StatelessWidget {
  const _NetworkLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LoadingDots(),
        SizedBox(height: 12),
        Text(
          'Now Loading...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PasslyText.secondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        size: const Size.square(72),
        painter: _LoadingDotsPainter(_controller.value),
      ),
    );
  }
}

class _LoadingDotsPainter extends CustomPainter {
  final double progress;

  const _LoadingDotsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const count = 8;
    const radius = 27.0;
    const dotRadius = 7.0;
    final activeIndex = (progress * count).floor();

    for (var index = 0; index < count; index++) {
      final angle = -math.pi / 2 + (2 * math.pi * index / count);
      final position =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      final distance = (index - activeIndex + count) % count;
      final brightness = distance == 0
          ? 1.0
          : distance == 1
          ? 0.82
          : distance == 2
          ? 0.62
          : 0.38;
      final color = Color.lerp(PasslyText.secondary, Colors.white, brightness)!;
      canvas.drawCircle(position, dotRadius, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LoadingDotsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
