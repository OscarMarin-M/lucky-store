import 'package:flutter/material.dart';

/// The round Lucky Store logo (bear with candy), transparent outside the
/// circle so it sits on any background.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});

  final double size;

  static const asset = 'assets/branding/logo.png';

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    width: size,
    height: size,
    // Decoded at the drawn size, not at 512 px, to keep memory low.
    cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
    semanticLabel: 'Lucky Store',
  );
}

/// What a screen shows while its data loads: the logo inside a spinner ring
/// and "Cargando…". [compact] is for sheets and small areas.
class BrandLoading extends StatelessWidget {
  const BrandLoading({super.key, this.compact = false, this.message});

  final bool compact;

  /// Replaces "Cargando…" (e.g. "Abriendo sesión…").
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logo = compact ? 56.0 : 120.0;
    final ring = logo + (compact ? 14 : 22);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: ring,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.square(
                  dimension: ring,
                  child: CircularProgressIndicator(
                    strokeWidth: compact ? 3 : 4,
                  ),
                ),
                BrandLogo(size: logo),
              ],
            ),
          ),
          SizedBox(height: compact ? 8 : 16),
          Text(
            message ?? 'Cargando…',
            style:
                (compact
                        ? theme.textTheme.bodyMedium
                        : theme.textTheme.titleMedium)
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
