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

/// @docs-example painter-usage-1
Widget _painterUsage1(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 240,
      height: 140,
      child: WiredCanvas(
        painter: WiredRectangleBase(
          fillColor: const Color(0xfff6dfd5),
          borderColor: theme.borderColor,
          strokeWidth: 2,
          leftIndent: 10,
          rightIndent: 10,
        ),
        fillerType: RoughFilter.hachureFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-2
Widget _painterUsage2(ExampleSettings settings) => Builder(
  builder: (context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: WiredCanvas(
        painter: WiredCircleBase(
          diameterRatio: 0.9,
          fillColor: const Color(0xffebc569),
        ),
        fillerType: RoughFilter.solidFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-3
Widget _painterUsage3(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 200,
      height: theme.inkExtent,
      child: WiredCanvas(
        painter: WiredLineBase(
          x1: 0,
          y1: theme.inkExtent / 2,
          x2: 200,
          y2: theme.inkExtent / 2,
          borderColor: theme.borderColor,
        ),
        fillerType: RoughFilter.noFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-4
Widget _painterUsage4(ExampleSettings settings) => Builder(
  builder: (context) {
    return SizedBox(
      width: 240,
      height: 140,
      child: WiredCanvas(
        painter: WiredRoundedRectangleBase(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          fillColor: const Color(0xFFF5F0E1),
        ),
        fillerType: RoughFilter.noFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-5
Widget _painterUsage5(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 16,
      height: 10,
      child: WiredCanvas(
        painter: WiredInvertedTriangleBase(
          borderColor: theme.borderColor,
        ),
        fillerType: RoughFilter.solidFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-6
Widget _painterUsage6(ExampleSettings settings) => Builder(
  builder: (context) {
    return SizedBox(
      width: 200,
      height: 100,
      child: WiredCanvas(
        painter: WiredRectangleBase(),
        fillerType: RoughFilter.hachureFiller,
      ),
    );
  },
);

/// @docs-example painter-usage-7
Widget _painterUsage7(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 240,
      height: 140,
      child: WiredCanvas(
        painter: WiredCircleBase(
          fillColor: const Color(0xffaecfda),
          borderColor: theme.borderColor,
        ),
        fillerType: RoughFilter.zigZagFiller,
        drawConfig: DrawConfig.build(roughness: 2, seed: 42),
        fillerConfig: FillerConfig.build(
          hachureGap: 8,
          hachureAngle: 60,
        ),
        size: const Size(100, 100),
      ),
    );
  },
);

/// @docs-example decoration-usage-1
Widget _decorationUsage1(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.borderColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Standard'),
    );
  },
);

/// @docs-example decoration-usage-2
Widget _decorationUsage2(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Sketchy'),
    );
  },
);

/// @docs-example decoration-usage-3
Widget _decorationUsage3(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 100,
      height: 100,
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.circle,
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xff456c5c),
        ),
      ),
    );
  },
);

/// @docs-example decoration-usage-4
Widget _decorationUsage4(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 160,
      height: 80,
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.ellipse,
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xffb2533d),
        ),
      ),
    );
  },
);

/// @docs-example decoration-usage-5
Widget _decorationUsage5(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      width: 200,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
      ),
      child: const Text('Hello, Skribble!'),
    );
  },
);

/// @docs-example decoration-usage-6
Widget _decorationUsage6(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: const RoughDrawingStyle(
          width: 1.5,
          color: Color(0xff716275),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Card body text goes here.'),
        ],
      ),
    );
  },
);

/// @docs-example decoration-usage-7
Widget _decorationUsage7(ExampleSettings settings) => Builder(
  builder: (context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RoughBoxDecoration(
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xff9b542d),
        ),
        fillStyle: const RoughDrawingStyle(width: 1, color: Color(0xfff6dfd5)),
        filler: HachureFiller(FillerConfig.build(hachureGap: 20)),
        drawConfig: DrawConfig.build(roughness: 1.5, seed: 7),
      ),
      child: const Row(
        children: [
          WiredIcon(
            icon: IconData(0xe33d, fontFamily: 'MaterialIcons'),
            color: Color(0xff9b542d),
          ),
          SizedBox(width: 12),
          Expanded(child: Text('This is an important note.')),
        ],
      ),
    );
  },
);

/// @docs-example decoration-usage-8
Widget _decorationUsage8(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: RoughBoxDecoration(
        drawConfig: theme.drawConfig,
        shape: RoughBoxShape.roundedRectangle,
        borderStyle: const RoughDrawingStyle(
          width: 1,
          color: Color(0xff456c5c),
        ),
        fillStyle: const RoughDrawingStyle(
          width: 0.5,
          color: Color(0xffeef1df),
        ),
        filler: SolidFiller(FillerConfig.defaultConfig),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'flutter',
        style: TextStyle(color: Color(0xff456c5c), fontSize: 12),
      ),
    );
  },
);

/// @docs-example decoration-usage-9
Widget _decorationUsage9(ExampleSettings settings) => Builder(
  builder: (context) {
    return Container(
      width: 200,
      height: 100,
      decoration: RoughBoxDecoration(
        borderStyle: const RoughDrawingStyle(
          width: 2,
          color: Color(0xFF1A2B3C),
        ),
        fillStyle: const RoughDrawingStyle(
          width: 1,
          color: Color(0xFFE8E8E8),
        ),
        drawConfig: DrawConfig.build(roughness: 1.5),
        filler: HachureFiller(),
      ),
      child: const Center(child: Text('Sketchy box')),
    );
  },
);

/// @docs-example theme-drawing-1
Widget _themeDrawing1(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return SizedBox(
      width: 240,
      height: 140,
      child: WiredCanvas(
        painter: WiredRectangleBase(
          fillColor: theme.fillColor,
          borderColor: theme.borderColor,
        ),
        fillerType: RoughFilter.hachureFiller,
        drawConfig: DrawConfig.build(roughness: 4, bowing: 3, seed: 42),
      ),
    );
  },
);

/// @docs-example theme-drawing-2
Widget _themeDrawing2(ExampleSettings settings) => Builder(
  builder: (context) {
    final theme = WiredTheme.of(context);
    return Container(
      decoration: RoughBoxDecoration(
        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),
        drawConfig: DrawConfig.build(roughness: 0.3), // very smooth
      ),
      child: const Text('Barely rough'),
    );
  },
);
