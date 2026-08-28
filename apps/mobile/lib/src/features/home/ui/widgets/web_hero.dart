import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/theme/app_colors.dart';

class WebHero extends StatelessWidget {
  const WebHero({required this.onToggleTheme, super.key});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final compact = media.width < 900;
    final heroHeight = compact ? 760.0 : 580.0;

    return Container(
      height: heroHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.black : AppColors.white,
        border: const Border.symmetric(
          horizontal: BorderSide(color: AppColors.blue, width: 2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 24 : 0,
          compact ? 28 : 64,
          compact ? 24 : 0,
          0,
        ),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: _WebHeader(compact: compact),
              ),
            ),
            Expanded(
              child:
                  compact
                      ? _CompactHeroContent(
                        isDark: isDark,
                        onToggleTheme: onToggleTheme,
                      )
                      : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1240),
                          child: _DesktopHeroContent(
                            isDark: isDark,
                            onToggleTheme: onToggleTheme,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebHeader extends StatelessWidget {
  const _WebHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SvgPicture.asset(
        'assets/branding/logo_a.svg',
        width: compact ? 190 : 285,
        semanticsLabel: 'Rick and Morty',
      ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  const _DesktopHeroContent({
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _HeroCopy(isDark: isDark, onToggleTheme: onToggleTheme),
          ),
        ),
        Expanded(
          flex: 6,
          child: Align(
            alignment: isDark ? Alignment.bottomCenter : Alignment.bottomRight,
            child: Image.asset(
              isDark
                  ? 'assets/branding/highlight_dark.jpg'
                  : 'assets/branding/highlight_light.jpg',
              width: isDark ? 774 : 435,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactHeroContent extends StatelessWidget {
  const _CompactHeroContent({
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 54),
        _HeroCopy(isDark: isDark, onToggleTheme: onToggleTheme),
        const Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            isDark
                ? 'assets/branding/highlight_dark.jpg'
                : 'assets/branding/highlight_light.jpg',
            height: 340,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.isDark, required this.onToggleTheme});

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 610),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Saiba tudo em\num só '),
                TextSpan(
                  text: 'lugar.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            style: textTheme.displaySmall?.copyWith(
              height: 1.12,
              fontWeight: FontWeight.w800,
              fontSize: width < 600 ? 44 : (width < 900 ? 48 : 48),
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Personagens, localizações, episódios e muito mais.',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 66),
          Row(
            children: [
              _ThemeButton(
                label: 'Escuro',
                icon: Icons.dark_mode_outlined,
                selected: isDark,
                onPressed: isDark ? () {} : onToggleTheme,
              ),
              const SizedBox(width: 14),
              _ThemeButton(
                label: 'Claro',
                icon: Icons.light_mode_outlined,
                selected: !isDark,
                onPressed: isDark ? onToggleTheme : () {},
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            isDark
                ? 'Aí sim, Por#@%&*'
                : 'Wubba Lubba Dub Dub! Cuidado com os olhos.',
            style: textTheme.titleMedium?.copyWith(color: AppColors.blue),
          ),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.white : colorScheme.onSurface,
        backgroundColor:
            selected ? AppColors.blue : colorScheme.surfaceContainerHighest,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
