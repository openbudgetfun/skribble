part of 'catalog.dart';

/// @docs-example icon
Widget _wiredIcon(ExampleSettings settings) => const Wrap(
  spacing: 24,
  children: [
    WiredIcon(
      icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Home',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Favourite',
      size: 48,
    ),
    WiredIcon(
      icon: IconData(0xe047, fontFamily: 'MaterialIcons'),
      semanticLabel: 'Add',
      size: 48,
    ),
  ],
);

/// @docs-example svg-icon
Widget _svgIcon(ExampleSettings settings) => WiredSvgIcon(
  data: lookupMaterialRoughIconByIdentifier('favorite')!,
  size: 64,
  color: settings.color,
  fillStyle: settings.iconFill,
  semanticLabel: 'Favourite',
);

/// @docs-example svg-icon-data
Widget _svgIconData(ExampleSettings settings) => const WiredSvgIcon(
  data: WiredSvgIconData(
    width: 24,
    height: 24,
    primitives: [
      WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),
      WiredSvgPrimitive.circle(cx: 12, cy: 16, radius: 2),
    ],
  ),
  size: 64,
  semanticLabel: 'Triangle with a circular detail',
);

/// @docs-example custom-icons
Widget _customIcons(ExampleSettings settings) => Wrap(
  spacing: 24,
  runSpacing: 20,
  children: [
    SkribbleIcon(
      data: kSkribbleCustomIconsRough[0xf001]!,
      semanticLabel: 'Home',
      size: 48,
    ),
    SkribbleIcon(
      data: kSkribbleCustomIconsRough[0xf005]!,
      semanticLabel: 'Heart',
      size: 48,
    ),
    SkribbleIcon(
      data: kSkribbleCustomIconsRough[0xf003]!,
      semanticLabel: 'Settings',
      size: 48,
    ),
  ],
);

/// @docs-example brand-icons
Widget _brandIcons(ExampleSettings settings) => Wrap(
  spacing: 24,
  runSpacing: 20,
  children: [
    for (final brand in WiredBrandIcon.values)
      WiredSvgIcon(
        data: brand.data,
        size: 48,
        color: settings.color,
        fillStyle: settings.iconFill,
        semanticLabel: brand.name,
      ),
  ],
);
