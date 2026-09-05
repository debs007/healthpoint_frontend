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
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.banners.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final banner = widget.banners[i];
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
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.border,
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
