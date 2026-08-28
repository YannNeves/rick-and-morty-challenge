import 'package:flutter/material.dart';

import 'web_home_logo.dart';

class WebDetailHeader extends StatelessWidget implements PreferredSizeWidget {
  const WebDetailHeader({
    required this.title,
    required this.onBack,
    required this.onHome,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onHome;

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1288),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: preferredSize.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      child: IconButton.outlined(
                        tooltip: 'Voltar',
                        onPressed: onBack,
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 190),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: WebHomeLogo(onTap: onHome, width: 150),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
