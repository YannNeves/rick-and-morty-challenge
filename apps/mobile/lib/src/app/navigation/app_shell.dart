import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_destination.dart';
import 'app_shell_view_model.dart';
import 'widgets/app_header.dart';
import 'widgets/animated_bottom_navigation.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.viewModel, super.key});

  final AppShellViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final destination = AppDestination.values[viewModel.selectedIndex];

    return Scaffold(
      appBar: kIsWeb ? null : AppHeader(onToggleTheme: viewModel.toggleTheme),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: Center(
          key: ValueKey(destination),
          child: Text(
            destination.routeLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      bottomNavigationBar:
          kIsWeb
              ? null
              : AnimatedBottomNavigation(
                selectedIndex: viewModel.selectedIndex,
                onDestinationSelected: viewModel.selectDestination,
              ),
    );
  }
}
