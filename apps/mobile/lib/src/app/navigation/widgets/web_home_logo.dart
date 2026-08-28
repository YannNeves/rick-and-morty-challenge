import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WebHomeLogo extends StatelessWidget {
  const WebHomeLogo({required this.onTap, this.width = 190, super.key});

  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ir para a Home',
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SvgPicture.asset(
            'assets/branding/logo_a.svg',
            width: width,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
