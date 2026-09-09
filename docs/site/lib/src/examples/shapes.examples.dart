part of 'catalog.dart';

/// @docs-example cupertino-filled-button
Widget _cupertinoFilled(ExampleSettings settings) =>
    WiredCupertinoButton.filled(
      onPressed: settings.enabled ? () {} : null,
      borderRadius: BorderRadius.circular(settings.radius),
      child: Text(settings.label),
    );

/// @docs-example rounded-canvas
Widget _roundedCanvas(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 260,
      height: 140,
      child: WiredCanvas(
        painter: WiredRoundedRectangleBase(
          borderRadius: BorderRadius.circular(settings.radius),
          borderColor: theme.borderColor,
          fillColor: const Color(0xffde987d),
          strokeWidth: theme.strokeWidth,
        ),
        fillerType: settings.fill,
      ),
    );
  },
);

/// @docs-example circle-canvas
Widget _circleCanvas(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 160,
      height: 160,
      child: WiredCanvas(
        painter: WiredCircleBase(
          borderColor: theme.borderColor,
          fillColor: settings.color,
          strokeWidth: theme.strokeWidth,
        ),
        fillerType: settings.fill,
      ),
    );
  },
);
