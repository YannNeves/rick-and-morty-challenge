import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../app_destination.dart';

class AnimatedBottomNavigation extends StatelessWidget {
  const AnimatedBottomNavigation({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  static const _height = 126.0;
  static const _waveDiameter = 108.0;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkGray : AppColors.lightSurface;
    final foreground = isDark ? AppColors.white : AppColors.darkGray;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _height + bottomInset,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / AppDestination.values.length;
          final notchCenter = itemWidth * (selectedIndex + 0.5);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(48),
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeInOutCubic,
                top: -44,
                left: notchCenter - (_waveDiameter / 2),
                width: _waveDiameter,
                height: _waveDiameter,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: bottomInset,
                child: Row(
                  children: [
                    for (final entry in AppDestination.values.indexed)
                      Expanded(
                        child: _NavigationItem(
                          destination: entry.$2,
                          selected: entry.$1 == selectedIndex,
                          foreground: foreground,
                          onTap: () => onDestinationSelected(entry.$1),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.destination,
    required this.selected,
    required this.foreground,
    required this.onTap,
  });

  final AppDestination destination;
  final bool selected;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.blue : foreground;

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkResponse(
        onTap: onTap,
        radius: 42,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutBack,
                padding: EdgeInsets.only(top: selected ? 2 : 43),
                child: AnimatedScale(
                  scale: selected ? 1.12 : 1,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutBack,
                  child: _DestinationIcon(
                    destination: destination,
                    color: color,
                    size: selected ? 32 : 28,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 2,
              right: 2,
              bottom: 13,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
                child: Text(
                  destination.label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationIcon extends StatelessWidget {
  const _DestinationIcon({
    required this.destination,
    required this.color,
    required this.size,
  });

  final AppDestination destination;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (destination.isRasterIcon) {
      return ImageIcon(
        AssetImage(destination.iconAsset),
        color: color,
        size: size,
      );
    }

    return SvgPicture.asset(
      destination.iconAsset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
