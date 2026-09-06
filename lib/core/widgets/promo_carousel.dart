import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../models/home_banner.dart';
import 'promo_banner.dart';

/// Takes real HomeBanner data directly (each with its own text/image),
/// not a shared-text-across-all-slides approach - the admin can set
/// different text per banner now, so the carousel needs to respect that
/// instead of forcing one caption onto every slide.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({
    super.key,
    required this.banners,
    this.onButtonPressed,
    this.height = 200,
  });

  final List<HomeBanner> banners;
  // Passes the specific banner that was tapped - different slides can
  // link to different coupons (or none), so the caller needs to know
  // which one to decide what happens.
  final void Function(HomeBanner banner)? onButtonPressed;
  final double height;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  // Starts deep into a large virtual page range, not page 0 - combined
  // with unbounded itemCount and modulo indexing below, this makes the
  // carousel loop continuously in one direction forever. There's no
  // real "last page" to hit and jump back from, which is what would
  // otherwise make an auto-scrolling loop look jarring.
  static const _initialPage = 10000;
  late final _controller = PageController(initialPage: _initialPage);
  int _page = _initialPage;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _maybeStartAutoScroll();
  }

  @override
  void didUpdateWidget(PromoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Home/Categories load banners asynchronously via a provider, so
    // this widget commonly starts with an empty list and gets banners a
    // moment later through a rebuild of this same widget - not a fresh
    // one, so initState() alone would miss that transition entirely.
    if (oldWidget.banners.length != widget.banners.length) {
      _autoScrollTimer?.cancel();
      _maybeStartAutoScroll();
    }
  }

  void _maybeStartAutoScroll() {
    if (widget.banners.length <= 1) return; // nothing to scroll to
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final activeDot = ((_page % widget.banners.length) + widget.banners.length) % widget.banners.length;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            // null = unbounded in both directions - a real, continuous
            // infinite scroll, not a fixed range with an eventual edge.
            itemCount: null,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final index = ((i % widget.banners.length) + widget.banners.length) % widget.banners.length;
              final banner = widget.banners[index];
              return PromoBanner(
                image: banner.imageUrl,
                badgeText: banner.badgeText,
                headline: banner.headline,
                subtitle: banner.subtitle,
                buttonText: banner.buttonText,
                height: widget.height,
                onButtonPressed: widget.onButtonPressed != null ? () => widget.onButtonPressed!(banner) : null,
              );
            },
          ),
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == activeDot ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == activeDot ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
