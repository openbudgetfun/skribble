// GENERATED CODE - DO NOT MODIFY BY HAND.
part of 'catalog.dart';

/// Executable examples, indexed by their stable Markdown IDs.
final Map<String, ExampleDefinition> examples = {
  'button': ExampleDefinition(
    builder: _button,
    source: "WiredButton(\n  borderRadius: BorderRadius.circular(settings.radius),\n  onPressed: () {},\n  inkInteraction: settings.interaction,\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(51, 66, ExampleParameter.radius),
      ExampleEdit(107, 127, ExampleParameter.interaction),
      ExampleEdit(143, 157, ExampleParameter.label),
    ],
  ),
  'elevated-button': ExampleDefinition(
    builder: _elevated,
    source: "WiredElevatedButton(\n  borderRadius: BorderRadius.circular(settings.radius),\n  onPressed: settings.enabled ? () {} : null,\n  inkInteraction: settings.interaction,\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(59, 74, ExampleParameter.radius),
      ExampleEdit(90, 106, ExampleParameter.enabled),
      ExampleEdit(141, 161, ExampleParameter.interaction),
      ExampleEdit(177, 191, ExampleParameter.label),
    ],
  ),
  'filled-button': ExampleDefinition(
    builder: _filled,
    source: "WiredFilledButton(\n  borderRadius: BorderRadius.circular(settings.radius),\n  onPressed: settings.enabled ? () {} : null,\n  fillColor: settings.color,\n  inkInteraction: settings.interaction,\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(57, 72, ExampleParameter.radius),
      ExampleEdit(88, 104, ExampleParameter.enabled),
      ExampleEdit(134, 148, ExampleParameter.color),
      ExampleEdit(168, 188, ExampleParameter.interaction),
      ExampleEdit(204, 218, ExampleParameter.label),
    ],
  ),
  'outlined-button': ExampleDefinition(
    builder: _outlined,
    source: "WiredOutlinedButton(\n  borderRadius: BorderRadius.circular(settings.radius),\n  onPressed: settings.enabled ? () {} : null,\n  inkInteraction: settings.interaction,\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(59, 74, ExampleParameter.radius),
      ExampleEdit(90, 106, ExampleParameter.enabled),
      ExampleEdit(141, 161, ExampleParameter.interaction),
      ExampleEdit(177, 191, ExampleParameter.label),
    ],
  ),
  'text-button': ExampleDefinition(
    builder: _text,
    source: "WiredTextButton(\n  onPressed: settings.enabled ? () {} : null,\n  inkInteraction: settings.interaction,\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(30, 46, ExampleParameter.enabled),
      ExampleEdit(81, 101, ExampleParameter.interaction),
      ExampleEdit(117, 131, ExampleParameter.label),
    ],
  ),
  'floating-button': ExampleDefinition(
    builder: _floating,
    source: "WiredFloatingActionButton(\n  icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),\n  semanticLabel: 'Add an idea',\n  onPressed: settings.enabled ? () {} : null,\n)",
    edits: [ExampleEdit(133, 149, ExampleParameter.enabled)],
  ),
  'icon-button': ExampleDefinition(
    builder: _icon,
    source: "WiredIconButton(\n  icon: const IconData(0xe25b, fontFamily: 'MaterialIcons'),\n  semanticLabel: 'Favourite',\n  onPressed: settings.enabled ? () {} : null,\n)",
    edits: [ExampleEdit(121, 137, ExampleParameter.enabled)],
  ),
  'cupertino-button': ExampleDefinition(
    builder: _cupertino,
    source: "WiredCupertinoButton(\n  onPressed: settings.enabled ? () {} : null,\n  color: const Color(0xffe8957d),\n  borderRadius: BorderRadius.circular(settings.radius),\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(35, 51, ExampleParameter.enabled),
      ExampleEdit(140, 155, ExampleParameter.radius),
      ExampleEdit(172, 186, ExampleParameter.label),
    ],
  ),
  'toggle-buttons': ExampleDefinition(
    builder: _toggles,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState([true, false, false]);\n    return WiredToggleButtons(\n      isSelected: selected.value,\n      onPressed: settings.enabled\n          ? (index) {\n              final next = List<bool>.of(selected.value);\n              next[index] = !next[index];\n              selected.value = next;\n            }\n          : null,\n      children: const [Text('B'), Text('I'), Text('U')],\n    );\n  },\n)",
    edits: [ExampleEdit(171, 187, ExampleParameter.enabled)],
  ),
  'segmented-button': ExampleDefinition(
    builder: _segmented,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState({'week'});\n    return WiredSegmentedButton<String>(\n      segments: const [\n        WiredButtonSegment(value: 'day', label: Text('Day')),\n        WiredButtonSegment(value: 'week', label: Text('Week')),\n        WiredButtonSegment(value: 'month', label: Text('Month')),\n      ],\n      selected: selected.value,\n      onSelectionChanged: settings.enabled\n          ? (value) => selected.value = value\n          : null,\n    );\n  },\n)",
    edits: [ExampleEdit(401, 417, ExampleParameter.enabled)],
  ),
  'chart-interactive': ExampleDefinition(
    builder: _chartInteractive,
    source: "HookBuilder(\n  builder: (context) {\n    final controller = useMemoized(() {\n      const closes = [\n        14220,\n        14268,\n        14240,\n        14304,\n        14380,\n        14355,\n        14295,\n        14210,\n        14178,\n        14230,\n        14295,\n        14368,\n        14420,\n        14380,\n        14405,\n        14475,\n        14520,\n        14490,\n        14430,\n        14485,\n        14540,\n        14512,\n        14580,\n        14605,\n      ];\n      final start = DateTime.utc(2026, 9, 10, 12);\n      WiredChartDecimal price(int cents) =>\n          WiredChartDecimal(BigInt.from(cents), 2);\n\n      return WiredChartController(\n        instrument: WiredChartInstrument(id: 'SOL / USDC', volumeDecimals: 0),\n        visibleCount: 24,\n        candles: List.generate(closes.length, (index) {\n          final open = index == 0 ? 14190 : closes[index - 1];\n          final close = closes[index];\n\n          return WiredChartCandle(\n            time: start.add(Duration(minutes: index)),\n            open: price(open),\n            high: price((open > close ? open : close) + 25),\n            low: price((open < close ? open : close) - 18),\n            close: price(close),\n            volume: WiredChartDecimal.fromInt(100 + (close - open).abs() * 8),\n          );\n        }),\n      );\n    });\n    final annotations = useMemoized(WiredChartAnnotations.new);\n    final lines = useState(false);\n    final ink = useState(true);\n    final indicators = useState(true);\n    final tool = useState(WiredChartDrawingTool.none);\n    useEffect(() {\n      return () {\n        controller.dispose();\n        annotations.dispose();\n      };\n    }, [controller, annotations]);\n\n    return Column(\n      crossAxisAlignment: CrossAxisAlignment.stretch,\n      children: [\n        const Text('SOL / USDC · illustrative candles · UTC'),\n        const SizedBox(height: 8),\n        SizedBox(\n          height: 420,\n          child: WiredFinancialChart(\n            key: const ValueKey('docs-financial-chart'),\n            controller: controller,\n            annotations: annotations,\n            series: lines.value\n                ? WiredPriceSeries.line\n                : WiredPriceSeries.candlesticks,\n            overlays: indicators.value ? const [WiredSma(period: 5)] : const [],\n            panes: const [WiredVolumePane()],\n            style: WiredChartStyle(\n              handDrawn: ink.value,\n              roughness: settings.amount / 2,\n            ),\n            tool: tool.value,\n            annotationLabel: 'My level',\n            onAnnotationCreated: (_) => tool.value = WiredChartDrawingTool.none,\n            semanticLabel: 'Illustrative SOL price chart',\n          ),\n        ),\n        Wrap(\n          spacing: 8,\n          runSpacing: 8,\n          children: [\n            WiredButton(\n              onPressed: () => lines.value = !lines.value,\n              child: Text(lines.value ? 'Show candles' : 'Show line'),\n            ),\n            WiredButton(\n              onPressed: () => ink.value = !ink.value,\n              child: Text(ink.value ? 'Crisp strokes' : 'Hand-drawn strokes'),\n            ),\n            WiredButton(\n              onPressed: () => indicators.value = !indicators.value,\n              child: Text(indicators.value ? 'Hide average' : 'Show average'),\n            ),\n            WiredButton(\n              onPressed: () => controller.zoom(1.3),\n              child: const Text('Zoom in'),\n            ),\n            WiredButton(\n              onPressed: controller.scrollToLatest,\n              child: const Text('Latest'),\n            ),\n            WiredButton(\n              onPressed: () =>\n                  tool.value = WiredChartDrawingTool.horizontalLine,\n              child: const Text('Mark a price'),\n            ),\n            WiredButton(\n              onPressed: annotations.undo,\n              child: const Text('Undo drawing'),\n            ),\n          ],\n        ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(2423, 2438, ExampleParameter.amount)],
  ),
  'cupertino-list-tile': ExampleDefinition(
    builder: _cupertinoListTile,
    source: "WiredCupertinoListTile(\n  title: Text(settings.label),\n  subtitle: const Text('Saved for a rainy day'),\n  backgroundColor: const Color(0xffdde4c9),\n  onTap: () {},\n)",
    edits: [ExampleEdit(38, 52, ExampleParameter.label)],
  ),
  'cupertino-list-section': ExampleDefinition(
    builder: _cupertinoListSection,
    source: "WiredCupertinoListSection(\n      header: Text(settings.label),\n      children: const [\n        WiredCupertinoListTile(title: Text('Sketches')),\n        WiredCupertinoListTile(title: Text('Little notes')),\n      ],\n    )",
    edits: [ExampleEdit(46, 60, ExampleParameter.label)],
  ),
  'cupertino-activity-indicator': ExampleDefinition(
    builder: _cupertinoActivity,
    source: "HookBuilder(\n  builder: (context) {\n    final running = useState(false);\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredCupertinoActivityIndicator(animating: running.value, radius: 18),\n        const SizedBox(height: 12),\n        WiredTextButton(\n          onPressed: () => running.value = !running.value,\n          child: Text(running.value ? 'Pause' : 'Animate'),\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'cupertino-search-text-field': ExampleDefinition(
    builder: _cupertinoSearch,
    source: "WiredCupertinoSearchTextField(\n      placeholder: settings.label,\n      enabled: settings.enabled,\n      borderRadius: BorderRadius.circular(settings.radius),\n    )",
    edits: [
      ExampleEdit(50, 64, ExampleParameter.label),
      ExampleEdit(81, 97, ExampleParameter.enabled),
      ExampleEdit(141, 156, ExampleParameter.radius),
    ],
  ),
  'cupertino-timer-picker': ExampleDefinition(
    builder: _timerPicker,
    source: "WiredCupertinoTimerPicker(\n  initialTimerDuration: const Duration(hours: 1, minutes: 15),\n  onTimerDurationChanged: (duration) {},\n)",
    edits: [],
  ),
  'cupertino-form-section': ExampleDefinition(
    builder: _cupertinoForm,
    source: "WiredCupertinoFormSection(\n  header: Text(settings.label),\n  children: const [\n    WiredCupertinoTextField(placeholder: 'Your name'),\n    WiredCupertinoTextField(placeholder: 'Your next idea'),\n  ],\n)",
    edits: [ExampleEdit(42, 56, ExampleParameter.label)],
  ),
  'emoji': ExampleDefinition(
    builder: _emoji,
    source: "Wrap(\n  spacing: 20,\n  runSpacing: 20,\n  children: [\n    WiredEmoji.fromName('grinning_face', size: 56),\n    WiredEmoji.fromSequence(\n      '👩🏽‍💻',\n      size: 56,\n      semanticLabel: 'Developer',\n    ),\n    WiredEmoji.fromSequence(\n      '🇬🇧',\n      size: 56,\n      semanticLabel: 'United Kingdom',\n    ),\n  ],\n)",
    edits: [],
  ),
  'emoji-sequences': ExampleDefinition(
    builder: _emojiSequences,
    source: "Wrap(\n  spacing: 20,\n  runSpacing: 20,\n  children: [\n    WiredEmoji.fromSequence(\n      '👩🏽‍💻',\n      size: 64,\n      semanticLabel: 'Developer',\n    ),\n    PrecomputedEmoji.fromSequence(\n      '🇬🇧',\n      size: 64,\n      semanticLabel: 'United Kingdom',\n    ),\n  ],\n)",
    edits: [],
  ),
  'circular-progress': ExampleDefinition(
    builder: _progress,
    source: "WiredCircularProgress(value: settings.amount)",
    edits: [ExampleEdit(29, 44, ExampleParameter.amount)],
  ),
  'badge': ExampleDefinition(
    builder: _badge,
    source: "WiredBadge(\n  label: '3',\n  isVisible: settings.enabled,\n  child: const Padding(padding: EdgeInsets.all(16), child: Text('New ideas')),\n)",
    edits: [ExampleEdit(39, 55, ExampleParameter.enabled)],
  ),
  'tooltip': ExampleDefinition(
    builder: _tooltip,
    source: "WiredTooltip(\n  message: settings.label,\n  child: const Padding(\n    padding: EdgeInsets.all(16),\n    child: Text('Hover or long press here'),\n  ),\n)",
    edits: [ExampleEdit(25, 39, ExampleParameter.label)],
  ),
  'snack-bar-content': ExampleDefinition(
    builder: _snackBar,
    source: "WiredSnackBarContent(\n  action: WiredTextButton(onPressed: () {}, child: const Text('Undo')),\n  child: Text(settings.label),\n)",
    edits: [ExampleEdit(108, 122, ExampleParameter.label)],
  ),
  'bottom-sheet': ExampleDefinition(
    builder: _bottomSheet,
    source: "Builder(\n  builder: (context) => WiredButton(\n    onPressed: () => showWiredBottomSheet<void>(\n      context: context,\n      builder: (context) => Padding(\n        padding: const EdgeInsets.all(24),\n        child: Column(\n          mainAxisSize: MainAxisSize.min,\n          children: [\n            Text(settings.label),\n            WiredTextButton(\n              onPressed: () => Navigator.of(context).pop(),\n              child: const Text('Done'),\n            ),\n          ],\n        ),\n      ),\n    ),\n    child: const Text('Open the sheet'),\n  ),\n)",
    edits: [ExampleEdit(303, 317, ExampleParameter.label)],
  ),
  'about-dialog': ExampleDefinition(
    builder: _aboutDialog,
    source: "Builder(\n  builder: (context) => WiredButton(\n    onPressed: () => showWiredAboutDialog(\n      context: context,\n      applicationName: settings.label,\n      applicationVersion: '1.0',\n    ),\n    child: const Text('About this sketchbook'),\n  ),\n)",
    edits: [ExampleEdit(136, 150, ExampleParameter.label)],
  ),
  'license-page': ExampleDefinition(
    builder: _licensePage,
    source: "Builder(\n  builder: (context) => WiredButton(\n    onPressed: () =>\n        showWiredLicensePage(context: context, applicationName: settings.label),\n    child: const Text('Read the licenses'),\n  ),\n)",
    edits: [ExampleEdit(131, 145, ExampleParameter.label)],
  ),
  'context-menu': ExampleDefinition(
    builder: _contextMenu,
    source: "WiredContextMenu(\n  actions: [\n    WiredContextMenuAction(label: 'Save', onPressed: () {}),\n    WiredContextMenuAction(label: 'Share', onPressed: () {}),\n  ],\n  child: Padding(\n    padding: const EdgeInsets.all(24),\n    child: Text(settings.label),\n  ),\n)",
    edits: [ExampleEdit(232, 246, ExampleParameter.label)],
  ),
  'material-banner': ExampleDefinition(
    builder: _materialBanner,
    source: "HookBuilder(\n  builder: (context) {\n    final visible = useState(true);\n    return visible.value\n        ? WiredMaterialBanner(\n            content: Text(settings.label),\n            backgroundColor: const Color(0xffdde4c9),\n            actions: [\n              WiredTextButton(\n                onPressed: () => visible.value = false,\n                child: const Text('Got it'),\n              ),\n            ],\n          )\n        : WiredTextButton(\n            onPressed: () => visible.value = true,\n            child: const Text('Show banner'),\n          );\n  },\n)",
    edits: [ExampleEdit(154, 168, ExampleParameter.label)],
  ),
  'dialog': ExampleDefinition(
    builder: _dialog,
    source: "Builder(\n  builder: (context) => WiredButton(\n    child: const Text('Open a little dialog'),\n    onPressed: () => showGeneralDialog<void>(\n      context: context,\n      barrierDismissible: true,\n      barrierLabel: 'Close dialog',\n      pageBuilder: (context, animation, secondaryAnimation) => WiredDialog(\n        child: Column(\n          mainAxisSize: MainAxisSize.min,\n          children: [\n            Text(settings.label),\n            WiredTextButton(\n              onPressed: () => Navigator.of(context).pop(),\n              child: const Text('Lovely'),\n            ),\n          ],\n        ),\n      ),\n    ),\n  ),\n)",
    edits: [ExampleEdit(411, 425, ExampleParameter.label)],
  ),
  'cupertino-alert-dialog': ExampleDefinition(
    builder: _cupertinoAlertDialog,
    source: "Builder(\n  builder: (context) => WiredButton(\n    child: const Text('Show an alert'),\n    onPressed: () => showGeneralDialog<void>(\n      context: context,\n      barrierDismissible: true,\n      barrierLabel: 'Close alert',\n      pageBuilder: (context, animation, secondaryAnimation) =>\n          WiredCupertinoAlertDialog(\n            title: Text(settings.label),\n            content: const Text('Your sketch is ready to keep.'),\n            actions: [\n              WiredCupertinoDialogAction(\n                onPressed: () => Navigator.of(context).pop(),\n                child: const Text('Keep it'),\n              ),\n            ],\n          ),\n    ),\n  ),\n)",
    edits: [ExampleEdit(347, 361, ExampleParameter.label)],
  ),
  'cupertino-action-sheet': ExampleDefinition(
    builder: _cupertinoActionSheet,
    source: "Builder(\n  builder: (context) => WiredButton(\n    child: const Text('Choose what happens next'),\n    onPressed: () => showGeneralDialog<void>(\n      context: context,\n      barrierDismissible: true,\n      barrierLabel: 'Close actions',\n      pageBuilder: (context, animation, secondaryAnimation) => Align(\n        alignment: Alignment.bottomCenter,\n        child: WiredCupertinoActionSheet(\n          title: Text(settings.label),\n          actions: [\n            WiredCupertinoActionSheetAction(\n              onPressed: () => Navigator.of(context).pop(),\n              child: const Text('Save the sketch'),\n            ),\n          ],\n          cancelButton: WiredCupertinoActionSheetAction(\n            onPressed: () => Navigator.of(context).pop(),\n            child: const Text('Cancel'),\n          ),\n        ),\n      ),\n    ),\n  ),\n)",
    edits: [ExampleEdit(413, 427, ExampleParameter.label)],
  ),
  'progress': ExampleDefinition(
    builder: _linearProgress,
    source: "HookBuilder(\n  builder: (context) {\n    final controller = useAnimationController(\n      duration: const Duration(milliseconds: 600),\n      initialValue: 1,\n    );\n    return WiredProgress(controller: controller, value: settings.amount);\n  },\n)",
    edits: [ExampleEdit(220, 235, ExampleParameter.amount)],
  ),
  'animated-icon': ExampleDefinition(
    builder: _animatedIcon,
    source: "HookBuilder(\n  builder: (context) {\n    final controller = useAnimationController(\n      duration: const Duration(milliseconds: 350),\n    );\n    final open = useState(false);\n    return WiredButton(\n      onPressed: () {\n        open.value = !open.value;\n        if (MediaQuery.disableAnimationsOf(context)) {\n          controller.value = open.value ? 1 : 0;\n        } else if (open.value) {\n          controller.forward();\n        } else {\n          controller.reverse();\n        }\n      },\n      child: WiredAnimatedIcon.menuClose(\n        progress: controller,\n        semanticLabel: open.value ? 'Close' : 'Open menu',\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'icon': ExampleDefinition(
    builder: _wiredIcon,
    source: "const Wrap(\n  spacing: 24,\n  children: [\n    WiredIcon(\n      icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n      semanticLabel: 'Home',\n      size: 48,\n    ),\n    WiredIcon(\n      icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n      semanticLabel: 'Favourite',\n      size: 48,\n    ),\n    WiredIcon(\n      icon: IconData(0xe047, fontFamily: 'MaterialIcons'),\n      semanticLabel: 'Add',\n      size: 48,\n    ),\n  ],\n)",
    edits: [],
  ),
  'svg-icon': ExampleDefinition(
    builder: _svgIcon,
    source: "WiredSvgIcon(\n  data: lookupMaterialRoughIconByIdentifier('favorite')!,\n  size: 64,\n  color: settings.color,\n  fillStyle: settings.iconFill,\n  semanticLabel: 'Favourite',\n)",
    edits: [
      ExampleEdit(93, 107, ExampleParameter.color),
      ExampleEdit(122, 139, ExampleParameter.iconFill),
    ],
  ),
  'svg-icon-data': ExampleDefinition(
    builder: _svgIconData,
    source: "const WiredSvgIcon(\n  data: WiredSvgIconData(\n    width: 24,\n    height: 24,\n    primitives: [\n      WiredSvgPrimitive.path('M12 2L2 22h20L12 2z'),\n      WiredSvgPrimitive.circle(cx: 12, cy: 16, radius: 2),\n    ],\n  ),\n  size: 64,\n  semanticLabel: 'Triangle with a circular detail',\n)",
    edits: [],
  ),
  'custom-icons': ExampleDefinition(
    builder: _customIcons,
    source: "Wrap(\n  spacing: 24,\n  runSpacing: 20,\n  children: [\n    SkribbleIcon(\n      data: kSkribbleCustomIconsRough[0xf001]!,\n      semanticLabel: 'Home',\n      size: 48,\n    ),\n    SkribbleIcon(\n      data: kSkribbleCustomIconsRough[0xf005]!,\n      semanticLabel: 'Heart',\n      size: 48,\n    ),\n    SkribbleIcon(\n      data: kSkribbleCustomIconsRough[0xf003]!,\n      semanticLabel: 'Settings',\n      size: 48,\n    ),\n  ],\n)",
    edits: [],
  ),
  'brand-icons': ExampleDefinition(
    builder: _brandIcons,
    source: "Wrap(\n  spacing: 24,\n  runSpacing: 20,\n  children: [\n    for (final brand in WiredBrandIcon.values)\n      WiredSvgIcon(\n        data: brand.data,\n        size: 48,\n        color: settings.color,\n        fillStyle: settings.iconFill,\n        semanticLabel: brand.name,\n      ),\n  ],\n)",
    edits: [
      ExampleEdit(179, 193, ExampleParameter.color),
      ExampleEdit(214, 231, ExampleParameter.iconFill),
    ],
  ),
  'checkbox': ExampleDefinition(
    builder: _checkbox,
    source: "HookBuilder(\n  builder: (context) {\n    final checked = useState(false);\n    return Row(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredCheckbox(\n          value: checked.value,\n          onChanged: (value) => checked.value = value ?? false,\n          semanticLabel: 'Keep this idea',\n        ),\n        const SizedBox(width: 12),\n        Flexible(child: Text(settings.label)),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(382, 396, ExampleParameter.label)],
  ),
  'switch': ExampleDefinition(
    builder: _switch,
    source: "HookBuilder(\n  builder: (context) {\n    final enabled = useState(true);\n    return WiredSwitch(\n      value: enabled.value,\n      onChanged: (value) {\n        enabled.value = value;\n      },\n    );\n  },\n)",
    edits: [],
  ),
  'slider': ExampleDefinition(
    builder: _slider,
    source: "WiredSlider(\n  value: settings.amount,\n  divisions: 10,\n  semanticLabel: 'Amount',\n  onChanged: settings.enabled ? (value) => true : null,\n)",
    edits: [
      ExampleEdit(22, 37, ExampleParameter.amount),
      ExampleEdit(96, 112, ExampleParameter.enabled),
    ],
  ),
  'input': ExampleDefinition(
    builder: _input,
    source: "WiredInput(\n  labelText: settings.label,\n  hintText: 'A tiny spark of an idea…',\n)",
    edits: [ExampleEdit(25, 39, ExampleParameter.label)],
  ),
  'text-area': ExampleDefinition(
    builder: _textArea,
    source: "WiredTextArea(\n  hintText: settings.label,\n)",
    edits: [ExampleEdit(27, 41, ExampleParameter.label)],
  ),
  'search-bar': ExampleDefinition(
    builder: _searchBar,
    source: "WiredSearchBar(hintText: settings.label)",
    edits: [ExampleEdit(25, 39, ExampleParameter.label)],
  ),
  'checkbox-list-tile': ExampleDefinition(
    builder: _checkboxListTile,
    source: "HookBuilder(\n  builder: (context) {\n    final checked = useState(true);\n    return WiredCheckboxListTile(\n      value: checked.value,\n      onChanged: (value) => checked.value = value ?? false,\n      title: Text(settings.label),\n      showDivider: false,\n    );\n  },\n)",
    edits: [ExampleEdit(212, 226, ExampleParameter.label)],
  ),
  'radio': ExampleDefinition(
    builder: _radio,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('paper');\n    return Wrap(\n      children: [\n        for (final value in ['paper', 'ink'])\n          WiredRadio<String>(\n            value: value,\n            groupValue: selected.value,\n            semanticLabel: value,\n            onChanged: settings.enabled\n                ? (value) {\n                    selected.value = value!;\n                    return true;\n                  }\n                : null,\n          ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(310, 326, ExampleParameter.enabled)],
  ),
  'radio-list-tile': ExampleDefinition(
    builder: _radioListTile,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('paper');\n    return Column(\n      children: [\n        for (final value in ['paper', 'ink'])\n          WiredRadioListTile<String>(\n            title: Text(value),\n            value: value,\n            groupValue: selected.value,\n            showDivider: false,\n            onChanged: settings.enabled\n                ? (value) {\n                    selected.value = value!;\n                    return true;\n                  }\n                : null,\n          ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(350, 366, ExampleParameter.enabled)],
  ),
  'switch-list-tile': ExampleDefinition(
    builder: _switchListTile,
    source: "HookBuilder(\n  builder: (context) {\n    final enabled = useState(true);\n    return WiredSwitchListTile(\n      value: enabled.value,\n      onChanged: (value) => enabled.value = value,\n      title: Text(settings.label),\n      showDivider: false,\n    );\n  },\n)",
    edits: [ExampleEdit(201, 215, ExampleParameter.label)],
  ),
  'toggle': ExampleDefinition(
    builder: _toggle,
    source: "HookBuilder(\n  builder: (context) {\n    final enabled = useState(false);\n    return WiredToggle(\n      value: enabled.value,\n      semanticLabel: 'Ink enabled',\n      onChange: (value) {\n        enabled.value = value;\n        return true;\n      },\n    );\n  },\n)",
    edits: [],
  ),
  'autocomplete': ExampleDefinition(
    builder: _autocomplete,
    source: "WiredAutocomplete<String>(\n  options: const ['Apple', 'Apricot', 'Banana', 'Cherry'],\n  displayStringForOption: (value) => value,\n  hintText: settings.label,\n  optionsWidth: 260,\n)",
    edits: [ExampleEdit(142, 156, ExampleParameter.label)],
  ),
  'cupertino-text-field': ExampleDefinition(
    builder: _cupertinoTextField,
    source: "WiredCupertinoTextField(\n  placeholder: settings.label,\n  enabled: settings.enabled,\n  borderRadius: BorderRadius.circular(settings.radius),\n)",
    edits: [
      ExampleEdit(40, 54, ExampleParameter.label),
      ExampleEdit(67, 83, ExampleParameter.enabled),
      ExampleEdit(123, 138, ExampleParameter.radius),
    ],
  ),
  'cupertino-slider': ExampleDefinition(
    builder: _cupertinoSlider,
    source: "HookBuilder(\n  builder: (context) {\n    final value = useState(.6);\n    return WiredCupertinoSlider(\n      value: value.value,\n      onChanged: settings.enabled ? (next) => value.value = next : null,\n    );\n  },\n)",
    edits: [ExampleEdit(144, 160, ExampleParameter.enabled)],
  ),
  'cupertino-switch': ExampleDefinition(
    builder: _cupertinoSwitch,
    source: "HookBuilder(\n  builder: (context) {\n    final value = useState(true);\n    return WiredCupertinoSwitch(\n      value: value.value,\n      onChanged: settings.enabled ? (next) => value.value = next : null,\n    );\n  },\n)",
    edits: [ExampleEdit(146, 162, ExampleParameter.enabled)],
  ),
  'form': ExampleDefinition(
    builder: _form,
    source: "WiredForm(\n  borderRadius: BorderRadius.circular(settings.radius),\n  child: WiredInput(labelText: settings.label, hintText: 'Your next idea'),\n)",
    edits: [
      ExampleEdit(49, 64, ExampleParameter.radius),
      ExampleEdit(98, 112, ExampleParameter.label),
    ],
  ),
  'range-slider': ExampleDefinition(
    builder: _rangeSlider,
    source: "HookBuilder(\n  builder: (context) {\n    final range = useState((start: .2, end: .8));\n    return WiredRangeSlider.between(\n      start: range.value.start,\n      end: range.value.end,\n      divisions: 10,\n      onChanged: settings.enabled\n          ? (start, end) {\n              range.value = (start: start, end: end);\n              return true;\n            }\n          : null,\n    );\n  },\n)",
    edits: [ExampleEdit(221, 237, ExampleParameter.enabled)],
  ),
  'search-anchor': ExampleDefinition(
    builder: _searchAnchor,
    source: "WiredSearchAnchor(\n  builder: (context, controller) => WiredSearchBar(\n    controller: controller,\n    hintText: settings.label,\n    onTap: controller.openView,\n  ),\n  suggestionsBuilder: (context, controller) => [\n    for (final option in ['Paper', 'Ink', 'Possibility'].where(\n      (option) => option.toLowerCase().contains(controller.text.toLowerCase()),\n    ))\n      WiredListTile(\n        title: Text(option),\n        showDivider: false,\n        onTap: () => controller.closeView(option),\n      ),\n  ],\n)",
    edits: [ExampleEdit(113, 127, ExampleParameter.label)],
  ),
  'card': ExampleDefinition(
    builder: _card,
    source: "WiredCard(\n  fill: settings.enabled,\n  child: Center(child: Text(settings.label)),\n)",
    edits: [
      ExampleEdit(19, 35, ExampleParameter.enabled),
      ExampleEdit(65, 79, ExampleParameter.label),
    ],
  ),
  'list-tile': ExampleDefinition(
    builder: _listTile,
    source: "WiredListTile(\n  title: Text(settings.label),\n  subtitle: const Text('A little note for later'),\n  showDivider: false,\n  onTap: settings.enabled ? () {} : null,\n)",
    edits: [
      ExampleEdit(29, 43, ExampleParameter.label),
      ExampleEdit(128, 144, ExampleParameter.enabled),
    ],
  ),
  'expansion-tile': ExampleDefinition(
    builder: _expansionTile,
    source: "WiredExpansionTile(\n  title: Text(settings.label),\n  children: const [\n    Padding(\n      padding: EdgeInsets.all(20),\n      child: Text('A small surprise tucked inside.'),\n    ),\n  ],\n)",
    edits: [ExampleEdit(34, 48, ExampleParameter.label)],
  ),
  'divider': ExampleDefinition(
    builder: _divider,
    source: "const WiredDivider()",
    edits: [],
  ),
  'avatar': ExampleDefinition(
    builder: _avatar,
    source: "const WiredAvatar(\n  radius: 32,\n  backgroundColor: Color(0xffe8b59e),\n  child: Text('SK'),\n)",
    edits: [],
  ),
  'grid-tile': ExampleDefinition(
    builder: _gridTile,
    source: "SizedBox(\n  height: 180,\n  child: WiredGridTile(\n    footer: WiredGridTileBar(title: Text(settings.label)),\n    onTap: () {},\n    child: const ColoredBox(color: Color(0xffdde4c9)),\n  ),\n)",
    edits: [ExampleEdit(90, 104, ExampleParameter.label)],
  ),
  'selectable-text': ExampleDefinition(
    builder: _selectableText,
    source: "WiredSelectableText(settings.label)",
    edits: [ExampleEdit(20, 34, ExampleParameter.label)],
  ),
  'carousel-view': ExampleDefinition(
    builder: _carousel,
    source: "WiredCarouselView(\n  borderRadius: BorderRadius.circular(settings.radius),\n  children: [\n    for (final label in ['Little plans', 'Bright ideas', 'Happy accidents'])\n      Center(child: Text(label)),\n  ],\n)",
    edits: [ExampleEdit(57, 72, ExampleParameter.radius)],
  ),
  'data-table': ExampleDefinition(
    builder: _dataTable,
    source: "const WiredDataTable(\n  columns: [\n    WiredDataColumn(label: Text('Sketch')),\n    WiredDataColumn(label: Text('Status')),\n  ],\n  rows: [\n    WiredDataRow(cells: [Text('Paper boats'), Text('Ready')]),\n    WiredDataRow(cells: [Text('Tiny gardens'), Text('Growing')]),\n  ],\n)",
    edits: [],
  ),
  'stepper': ExampleDefinition(
    builder: _stepper,
    source: "HookBuilder(\n  builder: (context) {\n    final current = useState(0);\n    return WiredStepper(\n      currentStep: current.value,\n      onStepTapped: (index) => current.value = index,\n      steps: const [\n        WiredStep(\n          title: Text('Imagine'),\n          content: Text('Start with a small idea.'),\n        ),\n        WiredStep(title: Text('Make'), content: Text('Give it a little ink.')),\n        WiredStep(title: Text('Share'), content: Text('Let someone try it.')),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'calendar': ExampleDefinition(
    builder: _calendar,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('2026-09-09');\n    return SizedBox(\n      height: 360,\n      child: WiredCalendar(\n        selected: selected.value,\n        onSelected: (date) => selected.value = date,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'scrollbar': ExampleDefinition(
    builder: _scrollbar,
    source: "HookBuilder(\n  builder: (context) {\n    final controller = useScrollController();\n    return SizedBox(\n      height: 180,\n      child: WiredScrollbar(\n        controller: controller,\n        thumbVisibility: true,\n        child: ListView(\n          controller: controller,\n          children: [\n            for (var index = 0; index < 15; index++)\n              Padding(\n                padding: const EdgeInsets.all(16),\n                child: Text('Little idea \${index + 1}'),\n              ),\n          ],\n        ),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'scaffold': ExampleDefinition(
    builder: _scaffold,
    source: "SizedBox(\n  height: 240,\n  child: WiredScaffold(\n    backgroundColor: const Color(0xffeef1df),\n    appBar: const WiredAppBar(title: Text('A little sketchbook')),\n    body: Center(child: Text(settings.label)),\n  ),\n)",
    edits: [ExampleEdit(191, 205, ExampleParameter.label)],
  ),
  'reorderable-list-view': ExampleDefinition(
    builder: _reorderable,
    source: "HookBuilder(\n  builder: (context) {\n    final items = useState(['Paper', 'Ink', 'Possibility']);\n    return SizedBox(\n      height: 220,\n      child: WiredReorderableListView(\n        onReorder: (from, to) {\n          final next = List<String>.of(items.value);\n          next.insert(to > from ? to - 1 : to, next.removeAt(from));\n          items.value = next;\n        },\n        children: [\n          for (final item in items.value) Text(item, key: ValueKey(item)),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'dismissible': ExampleDefinition(
    builder: _dismissible,
    source: "HookBuilder(\n  builder: (context) {\n    final visible = useState(true);\n    return visible.value\n        ? WiredDismissible(\n            dismissKey: const ValueKey('sketch'),\n            onDismissed: (direction) => visible.value = false,\n            child: WiredListTile(\n              title: Text(settings.label),\n              subtitle: const Text('Swipe to put this away'),\n              showDivider: false,\n            ),\n          )\n        : WiredTextButton(\n            onPressed: () => visible.value = true,\n            child: const Text('Bring it back'),\n          );\n  },\n)",
    edits: [ExampleEdit(298, 312, ExampleParameter.label)],
  ),
  'drawer-header': ExampleDefinition(
    builder: _drawerHeader,
    source: "SizedBox(\n  height: 180,\n  child: WiredDrawerHeader(child: Text(settings.label)),\n)",
    edits: [ExampleEdit(64, 78, ExampleParameter.label)],
  ),
  'user-accounts-drawer-header': ExampleDefinition(
    builder: _userAccounts,
    source: "WiredUserAccountsDrawerHeader(\n  accountName: Text(settings.label),\n  accountEmail: const Text('hello@example.com'),\n  currentAccountPicture: const WiredAvatar(child: Text('SK')),\n)",
    edits: [ExampleEdit(51, 65, ExampleParameter.label)],
  ),
  'grid-tile-bar': ExampleDefinition(
    builder: _gridTileBar,
    source: "WiredGridTileBar(\n  title: Text(settings.label),\n  subtitle: const Text('A small caption'),\n)",
    edits: [ExampleEdit(32, 46, ExampleParameter.label)],
  ),
  'mergeable-material': ExampleDefinition(
    builder: _mergeable,
    source: "HookBuilder(\n  builder: (context) {\n    final open = useState(false);\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredButton(\n          onPressed: () => open.value = !open.value,\n          child: const Text('Separate the notes'),\n        ),\n        const SizedBox(height: 12),\n        WiredMergeableMaterial(\n          children: [\n            const WiredMaterialSlice(\n              key: ValueKey('first'),\n              child: Padding(\n                padding: EdgeInsets.all(16),\n                child: Text('A bright idea'),\n              ),\n            ),\n            if (open.value) const WiredMaterialGap(key: ValueKey('gap')),\n            const WiredMaterialSlice(\n              key: ValueKey('second'),\n              child: Padding(\n                padding: EdgeInsets.all(16),\n                child: Text('A happy accident'),\n              ),\n            ),\n          ],\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'page-scaffold': ExampleDefinition(
    builder: _pageScaffold,
    source: "SizedBox(\n  height: 240,\n  child: WiredPageScaffold(\n    navigationBar: const WiredCupertinoNavigationBar(\n      middle: Text('Little notes'),\n    ),\n    child: Center(child: Text(settings.label)),\n  ),\n)",
    edits: [ExampleEdit(180, 194, ExampleParameter.label)],
  ),
  'tab-scaffold': ExampleDefinition(
    builder: _tabScaffold,
    source: "SizedBox(\n  height: 240,\n  child: WiredTabScaffold(\n    tabs: const [\n      WiredTabItem(\n        icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n        label: 'Home',\n      ),\n      WiredTabItem(\n        icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n        label: 'Saved',\n      ),\n    ],\n    tabBuilder: (context, index) => Center(\n      child: Text(index == 0 ? 'A fresh page' : 'Your favourite sketches'),\n    ),\n  ),\n)",
    edits: [],
  ),
  'map-online': ExampleDefinition(
    builder: _mapOnline,
    source: "HookBuilder(\n  builder: (context) {\n    final online = useState(false);\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredButton(\n          key: const ValueKey('docs-map-online-toggle'),\n          onPressed: () => online.value = !online.value,\n          child: Text(online.value ? 'Close the map' : 'Load OpenFreeMap'),\n        ),\n        if (online.value) ...[\n          const SizedBox(height: 16),\n          const SizedBox(\n            height: 300,\n            child: WiredMap(\n              key: ValueKey('docs-online-map'),\n              initialCenter: LatLng(51.5074, -0.1278),\n              initialZoom: 13,\n              gestureRecognizers: {\n                Factory<OneSequenceGestureRecognizer>(\n                  EagerGestureRecognizer.new,\n                ),\n              },\n            ),\n          ),\n        ],\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'map-features': ExampleDefinition(
    builder: _mapFeatures,
    source: "HookBuilder(\n  builder: (context) {\n    final online = useState(false);\n    final selected = useState('Choose a pin, then explore the walking route.');\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        Wrap(\n          spacing: 24,\n          runSpacing: 12,\n          children: [\n            WiredMapPin(\n              key: const ValueKey('docs-map-pin-coffee'),\n              icon: WiredMapPinIcon.coffee,\n              semanticLabel: 'Favourite café',\n              onTap: () => selected.value = 'Selected: Favourite café',\n              onLongPress: () => selected.value = 'Selected: Favourite café',\n            ),\n            WiredMapPin(\n              key: const ValueKey('docs-map-pin-market'),\n              icon: WiredMapPinIcon.market,\n              semanticLabel: 'Weekend market',\n              onTap: () => selected.value = 'Selected: Weekend market',\n              onLongPress: () => selected.value = 'Selected: Weekend market',\n            ),\n            WiredMapPin(\n              key: const ValueKey('docs-map-pin-gallery'),\n              icon: WiredMapPinIcon.gallery,\n              semanticLabel: 'Local gallery',\n              onTap: () => selected.value = 'Selected: Local gallery',\n              onLongPress: () => selected.value = 'Selected: Local gallery',\n            ),\n          ],\n        ),\n        const SizedBox(height: 12),\n        Semantics(\n          liveRegion: true,\n          child: Text(\n            selected.value,\n            key: const ValueKey('docs-map-selection'),\n          ),\n        ),\n        const SizedBox(height: 16),\n        WiredButton(\n          onPressed: () => online.value = !online.value,\n          child: Text(\n            online.value ? 'Close the route' : 'Show the route on a map',\n          ),\n        ),\n        if (online.value) ...[\n          const SizedBox(height: 16),\n          SizedBox(\n            height: 300,\n            child: WiredMap(\n              initialCenter: const LatLng(51.5242, -0.0778),\n              initialZoom: 14,\n              gestureRecognizers: const {\n                Factory<OneSequenceGestureRecognizer>(\n                  EagerGestureRecognizer.new,\n                ),\n              },\n              semanticLabel: 'Shoreditch walking route',\n              children: [\n                const WiredMapFeatureLayer(\n                  semanticLabel: 'Walking route',\n                  features: [\n                    WiredMapPolygon(\n                      points: [\n                        LatLng(51.5256, -0.0798),\n                        LatLng(51.5258, -0.0769),\n                        LatLng(51.5245, -0.0765),\n                        LatLng(51.5242, -0.0792),\n                      ],\n                    ),\n                    WiredMapPolyline(\n                      points: [\n                        LatLng(51.5228, -0.0810),\n                        LatLng(51.5242, -0.0778),\n                        LatLng(51.5260, -0.0740),\n                      ],\n                      color: Color(0xffb2533d),\n                      strokeWidth: 4,\n                    ),\n                  ],\n                ),\n                WiredMapMarkerLayer(\n                  markers: [\n                    WiredMapMarker(\n                      point: const LatLng(51.5242, -0.0778),\n                      semanticLabel: 'Favourite café',\n                      onTap: () => selected.value = 'Selected: Favourite café',\n                      onLongPress: () =>\n                          selected.value = 'Selected: Favourite café',\n                      child: const WiredMapPin(icon: WiredMapPinIcon.coffee),\n                    ),\n                  ],\n                ),\n              ],\n            ),\n          ),\n        ],\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'ink-reveal': ExampleDefinition(
    builder: _inkReveal,
    source: "HookBuilder(\n  builder: (context) {\n    final replay = useState(0);\n    return Column(\n      children: [\n        WiredDraw(\n          key: ValueKey(replay.value),\n          child: WiredCard(child: Text(settings.label)),\n        ),\n        const SizedBox(height: 16),\n        WiredOutlinedButton(\n          onPressed: () => replay.value++,\n          child: const Text('Draw again'),\n        ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(202, 216, ExampleParameter.label)],
  ),
  'ink-progress': ExampleDefinition(
    builder: _inkProgress,
    source: "WiredDrawTransition(\n  progress: AlwaysStoppedAnimation(settings.amount),\n  child: WiredCard(child: Text(settings.label)),\n)",
    edits: [
      ExampleEdit(56, 71, ExampleParameter.amount),
      ExampleEdit(105, 119, ExampleParameter.label),
    ],
  ),
  'ink-basic': ExampleDefinition(
    builder: _inkBasic,
    source: "WiredDraw(child: WiredCard(child: Text(settings.label)))",
    edits: [ExampleEdit(39, 53, ExampleParameter.label)],
  ),
  'redraw-button': ExampleDefinition(
    builder: _redrawButton,
    source: "WiredFilledButton(\n  inkInteraction: WiredInkInteraction.redraw,\n  fillColor: settings.color,\n  borderRadius: BorderRadius.circular(settings.radius),\n  onPressed: () {},\n  child: Text(settings.label),\n)",
    edits: [
      ExampleEdit(78, 92, ExampleParameter.color),
      ExampleEdit(132, 147, ExampleParameter.radius),
      ExampleEdit(184, 198, ExampleParameter.label),
    ],
  ),
  'app-bar': ExampleDefinition(
    builder: _appBar,
    source: "WiredAppBar(title: Text(settings.label))",
    edits: [ExampleEdit(24, 38, ExampleParameter.label)],
  ),
  'navigation-bar': ExampleDefinition(
    builder: _navigationBar,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return WiredNavigationBar(\n      selectedIndex: selected.value,\n      onDestinationSelected: (index) => selected.value = index,\n      destinations: const [\n        WiredNavigationDestination(\n          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n          label: 'Home',\n        ),\n        WiredNavigationDestination(\n          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n          label: 'Saved',\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'navigation-rail': ExampleDefinition(
    builder: _navigationRail,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return SizedBox(\n      height: 240,\n      child: WiredNavigationRail(\n        selectedIndex: selected.value,\n        onDestinationSelected: (index) => selected.value = index,\n        destinations: const [\n          WiredNavigationRailDestination(\n            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n            label: 'Home',\n          ),\n          WiredNavigationRailDestination(\n            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n            label: 'Saved',\n          ),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'navigation-drawer': ExampleDefinition(
    builder: _navigationDrawer,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return SizedBox(\n      height: 220,\n      child: WiredNavigationDrawer(\n        selectedIndex: selected.value,\n        onDestinationSelected: (index) => selected.value = index,\n        destinations: const [\n          WiredNavigationDrawerDestination(\n            icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n            label: 'Home',\n          ),\n          WiredNavigationDrawerDestination(\n            icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n            label: 'Saved',\n          ),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'tab-bar': ExampleDefinition(
    builder: _tabBar,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return WiredTabBar(\n      tabs: const ['Ideas', 'Sketches', 'Notes'],\n      selectedIndex: selected.value,\n      onTap: (index) => selected.value = index,\n    );\n  },\n)",
    edits: [],
  ),
  'drawer': ExampleDefinition(
    builder: _drawer,
    source: "SizedBox(\n  height: 180,\n  child: WiredDrawer(\n    child: Padding(\n      padding: const EdgeInsets.all(20),\n      child: Text(settings.label),\n    ),\n  ),\n)",
    edits: [ExampleEdit(126, 140, ExampleParameter.label)],
  ),
  'popup-menu-button': ExampleDefinition(
    builder: _popupMenu,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('Choose an action');\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredPopupMenuButton<String>(\n          items: const [\n            WiredPopupMenuItem(value: 'Saved', child: Text('Save')),\n            WiredPopupMenuItem(value: 'Shared', child: Text('Share')),\n          ],\n          onSelected: (value) => selected.value = value,\n        ),\n        Text(selected.value),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'menu-bar': ExampleDefinition(
    builder: _menuBar,
    source: "WiredMenuBar(\n  children: [\n    WiredSubmenuButton(\n      menuChildren: [\n        WiredMenuItemButton(onPressed: () {}, child: const Text('New sketch')),\n        WiredMenuItemButton(onPressed: () {}, child: const Text('Save sketch')),\n      ],\n      child: Text(settings.label),\n    ),\n  ],\n)",
    edits: [ExampleEdit(262, 276, ExampleParameter.label)],
  ),
  'bottom-app-bar': ExampleDefinition(
    builder: _bottomAppBar,
    source: "WiredBottomAppBar(child: Text(settings.label))",
    edits: [ExampleEdit(30, 44, ExampleParameter.label)],
  ),
  'sliver-app-bar': ExampleDefinition(
    builder: _sliverAppBar,
    source: "SizedBox(\n  height: 240,\n  child: CustomScrollView(\n    slivers: [\n      WiredSliverAppBar(\n        title: Text(settings.label),\n        expandedHeight: 120,\n        pinned: true,\n      ),\n      SliverList.list(\n        children: [\n          for (var index = 0; index < 8; index++)\n            Padding(\n              padding: const EdgeInsets.all(16),\n              child: Text('Sketch \${index + 1}'),\n            ),\n        ],\n      ),\n    ],\n  ),\n)",
    edits: [ExampleEdit(112, 126, ExampleParameter.label)],
  ),
  'cupertino-navigation-bar': ExampleDefinition(
    builder: _cupertinoNavigationBar,
    source: "WiredCupertinoNavigationBar(middle: Text(settings.label))",
    edits: [ExampleEdit(41, 55, ExampleParameter.label)],
  ),
  'checkbox-menu-button': ExampleDefinition(
    builder: _checkboxMenuButton,
    source: "HookBuilder(\n  builder: (context) {\n    final checked = useState(true);\n    return WiredMenuBar(\n      children: [\n        WiredSubmenuButton(\n          menuChildren: [\n            WiredCheckboxMenuButton(\n              value: checked.value,\n              onChanged: (value) => checked.value = value ?? false,\n              child: Text(settings.label),\n            ),\n          ],\n          child: const Text('Options'),\n        ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(336, 350, ExampleParameter.label)],
  ),
  'radio-menu-button': ExampleDefinition(
    builder: _radioMenuButton,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('paper');\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        for (final value in ['paper', 'ink'])\n          WiredRadioMenuButton<String>(\n            value: value,\n            groupValue: selected.value,\n            onChanged: (value) => selected.value = value!,\n            child: Text(value),\n          ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'about-list-tile': ExampleDefinition(
    builder: _aboutListTile,
    source: "WiredAboutListTile(\n  applicationName: 'A little sketchbook',\n  applicationVersion: '1.0',\n  child: Text(settings.label),\n)",
    edits: [ExampleEdit(105, 119, ExampleParameter.label)],
  ),
  'bottom-navigation-bar': ExampleDefinition(
    builder: _bottomNavigationBar,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return WiredBottomNavigationBar(\n      currentIndex: selected.value,\n      onTap: (index) => selected.value = index,\n      items: const [\n        WiredBottomNavItem(\n          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n          label: 'Home',\n        ),\n        WiredBottomNavItem(\n          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n          label: 'Saved',\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'cupertino-tab-bar': ExampleDefinition(
    builder: _cupertinoTabBar,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(0);\n    return WiredCupertinoTabBar.destinations(\n      currentIndex: selected.value,\n      onTap: (index) => selected.value = index,\n      items: const [\n        WiredBottomNavItem(\n          icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n          label: 'Home',\n        ),\n        WiredBottomNavItem(\n          icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n          label: 'Saved',\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'app-pattern': ExampleDefinition(
    builder: _appPattern,
    source: "HookBuilder(\n  builder: (context) {\n    final tab = useState(0);\n    return SizedBox(\n      height: 320,\n      child: WiredScaffold(\n        appBar: const WiredAppBar(title: Text('My sketchbook')),\n        body: Center(\n          child: Text(tab.value == 0 ? 'A fresh page' : 'Your saved ideas'),\n        ),\n        bottomNavigationBar: WiredBottomNavigationBar(\n          currentIndex: tab.value,\n          onTap: (value) => tab.value = value,\n          items: const [\n            WiredBottomNavItem(\n              icon: IconData(0xe318, fontFamily: 'MaterialIcons'),\n              label: 'Home',\n            ),\n            WiredBottomNavItem(\n              icon: IconData(0xe25b, fontFamily: 'MaterialIcons'),\n              label: 'Saved',\n            ),\n          ],\n        ),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'validated-form': ExampleDefinition(
    builder: _validatedForm,
    source: "HookBuilder(\n  builder: (context) {\n    final key = useMemoized(GlobalKey<FormState>.new);\n    final accepted = useState(false);\n    return WiredForm(\n      formKey: key,\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.stretch,\n        children: [\n          FormField<String>(\n            validator: (value) => value != null && value.contains('@')\n                ? null\n                : 'Enter an email address.',\n            builder: (field) => Column(\n              crossAxisAlignment: CrossAxisAlignment.stretch,\n              children: [\n                WiredInput(labelText: 'Email', onChanged: field.didChange),\n                if (field.errorText case final String error)\n                  Semantics(liveRegion: true, child: Text(error)),\n              ],\n            ),\n          ),\n          const SizedBox(height: 16),\n          WiredFilledButton(\n            onPressed: () => accepted.value = key.currentState!.validate(),\n            child: const Text('Check the form'),\n          ),\n          if (accepted.value)\n            const Text('The sample form is valid. Nothing was sent.'),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'task-list-pattern': ExampleDefinition(
    builder: _taskListPattern,
    source: "HookBuilder(\n  builder: (context) {\n    const initial = [\n      (title: 'Buy paper', done: false),\n      (title: 'Walk the dog', done: true),\n      (title: 'Sketch an idea', done: false),\n    ];\n    final tasks = useState(initial);\n    return Column(\n      children: [\n        for (final task in tasks.value)\n          WiredDismissible(\n            dismissKey: ValueKey(task.title),\n            onDismissed: (_) => tasks.value = tasks.value\n                .where((item) => item.title != task.title)\n                .toList(),\n            child: WiredCheckboxListTile(\n              title: Text(task.title),\n              value: task.done,\n              showDivider: false,\n              onChanged: (value) => tasks.value = [\n                for (final item in tasks.value)\n                  if (item.title == task.title)\n                    (title: item.title, done: value ?? false)\n                  else\n                    item,\n              ],\n            ),\n          ),\n        WiredOutlinedButton(\n          onPressed: () => tasks.value = initial,\n          child: const Text('Reset the sample list'),\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'settings-pattern': ExampleDefinition(
    builder: _settingsPattern,
    source: "HookBuilder(\n  builder: (context) {\n    final notifications = useState(true);\n    final language = useState('English');\n    return Column(\n      crossAxisAlignment: CrossAxisAlignment.stretch,\n      children: [\n        WiredSwitchListTile(\n          title: const Text('Notifications'),\n          value: notifications.value,\n          onChanged: (value) => notifications.value = value,\n          showDivider: false,\n        ),\n        const SizedBox(height: 16),\n        const Text('Language'),\n        for (final option in ['English', 'Spanish', 'French'])\n          WiredRadioListTile<String>(\n            title: Text(option),\n            value: option,\n            groupValue: language.value,\n            onChanged: (value) {\n              language.value = value!;\n              return true;\n            },\n            showDivider: false,\n          ),\n        Text(\n          'Sample preferences: \${language.value}, notifications \${notifications.value ? 'on' : 'off'}.',\n        ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'loading-pattern': ExampleDefinition(
    builder: _loadingPattern,
    source: "HookBuilder(\n  builder: (context) {\n    final request = useState<Future<List<String>>?>(null);\n    final result = useFuture(request.value);\n    return Column(\n      children: [\n        WiredOutlinedButton(\n          onPressed: result.connectionState == ConnectionState.waiting\n              ? null\n              : () {\n                  request.value = Future.delayed(\n                    const Duration(milliseconds: 350),\n                    () => ['Paper', 'Ink', 'Possibility'],\n                  );\n                },\n          child: const Text('Load sample notes'),\n        ),\n        const SizedBox(height: 16),\n        if (result.connectionState == ConnectionState.waiting)\n          const WiredCircularProgress()\n        else if (result.hasError)\n          const Text('The sample could not load. Try again.')\n        else if (result.data case final List<String> notes)\n          for (final note in notes)\n            WiredListTile(title: Text(note), showDivider: false),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'search-pattern': ExampleDefinition(
    builder: _searchPattern,
    source: "HookBuilder(\n  builder: (context) {\n    final query = useState('');\n    final category = useState('All');\n    const items = [\n      (title: 'Write a proposal', category: 'Work'),\n      (title: 'Buy sketchbooks', category: 'Shopping'),\n      (title: 'Draw with friends', category: 'Personal'),\n    ];\n    final filtered = items\n        .where(\n          (item) =>\n              item.title.toLowerCase().contains(query.value.toLowerCase()) &&\n              (category.value == 'All' || item.category == category.value),\n        )\n        .toList();\n    return Column(\n      crossAxisAlignment: CrossAxisAlignment.stretch,\n      children: [\n        WiredInput(\n          labelText: 'Search sample tasks',\n          onChanged: (value) => query.value = value,\n        ),\n        const SizedBox(height: 16),\n        Wrap(\n          spacing: 8,\n          runSpacing: 8,\n          children: [\n            for (final option in ['All', 'Work', 'Shopping', 'Personal'])\n              WiredChoiceChip(\n                label: Text(option),\n                selected: category.value == option,\n                onSelected: (selected) {\n                  if (selected) category.value = option;\n                },\n              ),\n          ],\n        ),\n        const SizedBox(height: 16),\n        if (filtered.isEmpty) const Text('No matching sample tasks.'),\n        for (final item in filtered)\n          WiredListTile(\n            title: Text(item.title),\n            subtitle: Text(item.category),\n            showDivider: false,\n          ),\n      ],\n    );\n  },\n)",
    edits: [],
  ),
  'responsive-pattern': ExampleDefinition(
    builder: _responsivePattern,
    source: "LayoutBuilder(\n  builder: (context, constraints) {\n    final cards = [\n      for (final title in ['Ideas', 'In progress', 'Finished'])\n        WiredCard(\n          child: Padding(padding: const EdgeInsets.all(16), child: Text(title)),\n        ),\n    ];\n    return constraints.maxWidth < 600\n        ? Column(\n            crossAxisAlignment: CrossAxisAlignment.stretch,\n            children: cards,\n          )\n        : Row(children: [for (final card in cards) Expanded(child: card)]);\n  },\n)",
    edits: [],
  ),
  'snackbar-pattern': ExampleDefinition(
    builder: _snackbarPattern,
    source: "Builder(\n  builder: (context) => WiredOutlinedButton(\n    onPressed: () => showWiredSnackBar(\n      context,\n      content: const WiredSnackBarContent(\n        child: Text('The sample could not save. Please try again.'),\n      ),\n      duration: const Duration(seconds: 3),\n    ),\n    child: const Text('Show a sample error'),\n  ),\n)",
    edits: [],
  ),
  'signup-pattern': ExampleDefinition(
    builder: _signupPattern,
    source: "HookBuilder(\n  builder: (context) {\n    final name = useTextEditingController();\n    final email = useTextEditingController();\n    final agreed = useState(false);\n    final status = useState<String?>(null);\n    return WiredCard(\n      height: null,\n      child: Padding(\n        padding: const EdgeInsets.all(16),\n        child: Column(\n          crossAxisAlignment: CrossAxisAlignment.stretch,\n          children: [\n            WiredInput(controller: name, labelText: 'Name'),\n            const SizedBox(height: 16),\n            WiredInput(controller: email, labelText: 'Email'),\n            const SizedBox(height: 16),\n            WiredCheckboxListTile(\n              value: agreed.value,\n              onChanged: (value) => agreed.value = value ?? false,\n              title: const Text('I agree to the sample terms'),\n              showDivider: false,\n            ),\n            const SizedBox(height: 16),\n            WiredButton(\n              onPressed: () {\n                status.value =\n                    name.text.trim().isEmpty || !email.text.contains('@')\n                    ? 'Enter your name and email.'\n                    : !agreed.value\n                    ? 'Please agree to the sample terms.'\n                    : 'Your sample is ready. Nothing was sent.';\n              },\n              child: const Text('Check the details'),\n            ),\n            if (status.value case final String message)\n              Semantics(liveRegion: true, child: Text(message)),\n          ],\n        ),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'selection-pattern': ExampleDefinition(
    builder: _selectionPattern,
    source: "const WiredSelectionArea(\n  child: Column(\n    crossAxisAlignment: CrossAxisAlignment.start,\n    children: [\n      Text('A small beginning.\\n'),\n      Text.rich(\n        TextSpan(\n          children: [\n            TextSpan(text: 'Make something '),\n            TextSpan(\n              text: 'delightful.',\n              style: TextStyle(fontWeight: FontWeight.bold),\n            ),\n          ],\n        ),\n      ),\n    ],\n  ),\n)",
    edits: [],
  ),
  'lettering-pattern': ExampleDefinition(
    builder: _letteringPattern,
    source: "Text(\n  settings.label,\n  style: const TextStyle(\n    fontFamily: skribbleFontFamily,\n    package: 'skribble',\n    fontSize: 24,\n  ),\n)",
    edits: [ExampleEdit(8, 22, ExampleParameter.label)],
  ),
  'accessible-inputs': ExampleDefinition(
    builder: _accessibleInputs,
    source: "HookBuilder(\n  builder: (context) {\n    final checked = useState(false);\n    return Column(\n      children: [\n        WiredCheckbox(\n          value: checked.value,\n          onChanged: (value) => checked.value = value ?? false,\n          semanticLabel: 'Accept terms and conditions',\n        ),\n        const SizedBox(height: 16),\n        WiredSlider(\n          value: settings.amount,\n          onChanged: (value) => true,\n          semanticLabel: 'Volume control',\n        ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(370, 385, ExampleParameter.amount)],
  ),
  'expanding-decoration': ExampleDefinition(
    builder: _expandingDecoration,
    source: "HookBuilder(\n  builder: (context) {\n    final expanded = useState(false);\n    return Column(\n      children: [\n        WiredButton(\n          onPressed: () => expanded.value = !expanded.value,\n          child: Text(expanded.value ? 'Make it smaller' : 'Make room'),\n        ),\n        const SizedBox(height: 16),\n        AnimatedContainer(\n          duration:\n              MediaQuery.disableAnimationsOf(context) ||\n                  !WiredTheme.of(context).motionEnabled\n              ? Duration.zero\n              : const Duration(milliseconds: 300),\n          width: expanded.value ? 260 : 150,\n          height: expanded.value ? 180 : 100,\n          alignment: Alignment.center,\n          decoration: RoughBoxDecoration(\n            shape: RoughBoxShape.roundedRectangle,\n            drawConfig: WiredTheme.of(context).drawConfig,\n            borderStyle: RoughDrawingStyle(\n              width: 2.4,\n              color: WiredTheme.of(context).borderColor,\n            ),\n            borderRadius: BorderRadius.circular(settings.radius),\n          ),\n          child: const Text('Room for ideas'),\n        ),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(1026, 1041, ExampleParameter.radius)],
  ),
  'chip': ExampleDefinition(
    builder: _chip,
    source: "WiredChip(label: Text(settings.label))",
    edits: [ExampleEdit(22, 36, ExampleParameter.label)],
  ),
  'choice-chip': ExampleDefinition(
    builder: _choiceChip,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(false);\n    return WiredChoiceChip(\n      label: Text(settings.label),\n      selected: selected.value,\n      onSelected: (value) => selected.value = value,\n    );\n  },\n)",
    edits: [ExampleEdit(120, 134, ExampleParameter.label)],
  ),
  'filter-chip': ExampleDefinition(
    builder: _filterChip,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(true);\n    return WiredFilterChip(\n      label: Text(settings.label),\n      selected: selected.value,\n      onSelected: (value) => selected.value = value,\n    );\n  },\n)",
    edits: [ExampleEdit(119, 133, ExampleParameter.label)],
  ),
  'input-chip': ExampleDefinition(
    builder: _inputChip,
    source: "HookBuilder(\n  builder: (context) {\n    final visible = useState(true);\n    return visible.value\n        ? WiredInputChip(\n            label: Text(settings.label),\n            onDeleted: () => visible.value = false,\n          )\n        : WiredTextButton(\n            onPressed: () => visible.value = true,\n            child: const Text('Restore tag'),\n          );\n  },\n)",
    edits: [ExampleEdit(147, 161, ExampleParameter.label)],
  ),
  'action-chip': ExampleDefinition(
    builder: _actionChip,
    source: "HookBuilder(\n  builder: (context) {\n    final count = useState(0);\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredActionChip(\n          label: Text(settings.label),\n          onPressed: () => count.value++,\n        ),\n        Text('Pressed \${count.value} times'),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(189, 203, ExampleParameter.label)],
  ),
  'date-picker': ExampleDefinition(
    builder: _datePicker,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState<DateTime?>(null);\n    return Column(\n      mainAxisSize: MainAxisSize.min,\n      children: [\n        WiredButton(\n          onPressed: () async {\n            selected.value = await showWiredDatePicker(\n              context: context,\n              initialDate: DateTime(2026, 9, 9),\n            );\n          },\n          child: Text(settings.label),\n        ),\n        if (selected.value case final DateTime date)\n          Text('\${date.day}/\${date.month}/\${date.year}'),\n      ],\n    );\n  },\n)",
    edits: [ExampleEdit(399, 413, ExampleParameter.label)],
  ),
  'date-range-picker': ExampleDefinition(
    builder: _dateRangePicker,
    source: "Builder(\n  builder: (context) => WiredButton(\n    onPressed: () => showWiredDateRangePicker(\n      context: context,\n      firstDate: DateTime(2026),\n      lastDate: DateTime(2027),\n    ),\n    child: Text(settings.label),\n  ),\n)",
    edits: [ExampleEdit(205, 219, ExampleParameter.label)],
  ),
  'time-picker': ExampleDefinition(
    builder: _timePicker,
    source: "Builder(\n  builder: (context) => WiredButton(\n    onPressed: () => showWiredTimePicker(context: context),\n    child: Text(settings.label),\n  ),\n)",
    edits: [ExampleEdit(122, 136, ExampleParameter.label)],
  ),
  'calendar-date-picker': ExampleDefinition(
    builder: _calendarDatePicker,
    source: "WiredCalendarDatePicker(\n  initialDate: DateTime(2026, 9, 9),\n  firstDate: DateTime(2026),\n  lastDate: DateTime(2027),\n  onDateChanged: (date) {},\n)",
    edits: [],
  ),
  'color-picker': ExampleDefinition(
    builder: _colorPicker,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState(const Color(0xffe8957d));\n    return WiredColorPicker(\n      selectedColor: selected.value,\n      onColorChanged: (color) => selected.value = color,\n    );\n  },\n)",
    edits: [],
  ),
  'cupertino-picker': ExampleDefinition(
    builder: _cupertinoPicker,
    source: "SizedBox(\n  height: 160,\n  child: WiredCupertinoPicker(\n    onSelectedItemChanged: (index) {},\n    children: const [Text('Paper'), Text('Ink'), Text('Possibility')],\n  ),\n)",
    edits: [],
  ),
  'cupertino-date-picker': ExampleDefinition(
    builder: _cupertinoDatePicker,
    source: "SizedBox(\n  height: 180,\n  child: WiredCupertinoDatePicker(\n    initialDateTime: DateTime(2026, 9, 9, 12),\n    onDateTimeChanged: (date) {},\n  ),\n)",
    edits: [],
  ),
  'cupertino-segmented-control': ExampleDefinition(
    builder: _cupertinoSegmentedControl,
    source: "HookBuilder(\n  builder: (context) {\n    final selected = useState('paper');\n    return WiredCupertinoSegmentedControl<String>(\n      children: const {'paper': Text('Paper'), 'ink': Text('Ink')},\n      groupValue: selected.value,\n      onValueChanged: (value) => selected.value = value,\n    );\n  },\n)",
    edits: [],
  ),
  'combo': ExampleDefinition(
    builder: _combo,
    source: "WiredCombo<String>.options(\n  options: const {\n    'paper': Text('Paper'),\n    'ink': Text('Ink'),\n    'ideas': Text('Ideas'),\n  },\n  value: 'paper',\n)",
    edits: [],
  ),
  'cupertino-filled-button': ExampleDefinition(
    builder: _cupertinoFilled,
    source: "WiredCupertinoButton.filled(\n      onPressed: settings.enabled ? () {} : null,\n      borderRadius: BorderRadius.circular(settings.radius),\n      child: Text(settings.label),\n    )",
    edits: [
      ExampleEdit(46, 62, ExampleParameter.enabled),
      ExampleEdit(121, 136, ExampleParameter.radius),
      ExampleEdit(157, 171, ExampleParameter.label),
    ],
  ),
  'rounded-canvas': ExampleDefinition(
    builder: _roundedCanvas,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 260,\n      height: 140,\n      child: WiredCanvas(\n        painter: WiredRoundedRectangleBase(\n          borderRadius: BorderRadius.circular(settings.radius),\n          borderColor: theme.borderColor,\n          fillColor: const Color(0xffde987d),\n          strokeWidth: theme.strokeWidth,\n        ),\n        fillerType: settings.fill,\n      ),\n    );\n  },\n)",
    edits: [
      ExampleEdit(248, 263, ExampleParameter.radius),
      ExampleEdit(427, 440, ExampleParameter.fill),
    ],
  ),
  'circle-canvas': ExampleDefinition(
    builder: _circleCanvas,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 160,\n      height: 160,\n      child: WiredCanvas(\n        painter: WiredCircleBase(\n          borderColor: theme.borderColor,\n          fillColor: settings.color,\n          strokeWidth: theme.strokeWidth,\n        ),\n        fillerType: settings.fill,\n      ),\n    );\n  },\n)",
    edits: [
      ExampleEdit(255, 269, ExampleParameter.color),
      ExampleEdit(344, 357, ExampleParameter.fill),
    ],
  ),
  'painter-usage-1': ExampleDefinition(
    builder: _painterUsage1,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 240,\n      height: 140,\n      child: WiredCanvas(\n        painter: WiredRectangleBase(\n          fillColor: const Color(0xfff6dfd5),\n          borderColor: theme.borderColor,\n          strokeWidth: 2,\n          leftIndent: 10,\n          rightIndent: 10,\n        ),\n        fillerType: RoughFilter.hachureFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-2': ExampleDefinition(
    builder: _painterUsage2,
    source: "Builder(\n  builder: (context) {\n    return SizedBox(\n      width: 80,\n      height: 80,\n      child: WiredCanvas(\n        painter: WiredCircleBase(\n          diameterRatio: 0.9,\n          fillColor: const Color(0xffebc569),\n        ),\n        fillerType: RoughFilter.solidFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-3': ExampleDefinition(
    builder: _painterUsage3,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 200,\n      height: theme.inkExtent,\n      child: WiredCanvas(\n        painter: WiredLineBase(\n          x1: 0,\n          y1: theme.inkExtent / 2,\n          x2: 200,\n          y2: theme.inkExtent / 2,\n          borderColor: theme.borderColor,\n        ),\n        fillerType: RoughFilter.noFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-4': ExampleDefinition(
    builder: _painterUsage4,
    source: "Builder(\n  builder: (context) {\n    return SizedBox(\n      width: 240,\n      height: 140,\n      child: WiredCanvas(\n        painter: WiredRoundedRectangleBase(\n          borderRadius: const BorderRadius.only(\n            topLeft: Radius.circular(20),\n            bottomRight: Radius.circular(20),\n          ),\n          fillColor: const Color(0xFFF5F0E1),\n        ),\n        fillerType: RoughFilter.noFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-5': ExampleDefinition(
    builder: _painterUsage5,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 16,\n      height: 10,\n      child: WiredCanvas(\n        painter: WiredInvertedTriangleBase(\n          borderColor: theme.borderColor,\n        ),\n        fillerType: RoughFilter.solidFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-6': ExampleDefinition(
    builder: _painterUsage6,
    source: "Builder(\n  builder: (context) {\n    return SizedBox(\n      width: 200,\n      height: 100,\n      child: WiredCanvas(\n        painter: WiredRectangleBase(),\n        fillerType: RoughFilter.hachureFiller,\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'painter-usage-7': ExampleDefinition(
    builder: _painterUsage7,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 240,\n      height: 140,\n      child: WiredCanvas(\n        painter: WiredCircleBase(\n          fillColor: const Color(0xffaecfda),\n          borderColor: theme.borderColor,\n        ),\n        fillerType: RoughFilter.zigZagFiller,\n        drawConfig: DrawConfig.build(roughness: 2, seed: 42),\n        fillerConfig: FillerConfig.build(\n          hachureGap: 8,\n          hachureAngle: 60,\n        ),\n        size: const Size(100, 100),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-1': ExampleDefinition(
    builder: _decorationUsage1,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      decoration: BoxDecoration(\n        border: Border.all(color: theme.borderColor, width: 2),\n        borderRadius: BorderRadius.circular(8),\n      ),\n      child: const Text('Standard'),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-2': ExampleDefinition(
    builder: _decorationUsage2,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        shape: RoughBoxShape.roundedRectangle,\n        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),\n        borderRadius: BorderRadius.circular(8),\n      ),\n      child: const Text('Sketchy'),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-3': ExampleDefinition(
    builder: _decorationUsage3,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      width: 100,\n      height: 100,\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        shape: RoughBoxShape.circle,\n        borderStyle: const RoughDrawingStyle(\n          width: 2,\n          color: Color(0xff456c5c),\n        ),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-4': ExampleDefinition(
    builder: _decorationUsage4,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      width: 160,\n      height: 80,\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        shape: RoughBoxShape.ellipse,\n        borderStyle: const RoughDrawingStyle(\n          width: 2,\n          color: Color(0xffb2533d),\n        ),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-5': ExampleDefinition(
    builder: _decorationUsage5,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      width: 200,\n      height: 100,\n      padding: const EdgeInsets.all(16),\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),\n      ),\n      child: const Text('Hello, Skribble!'),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-6': ExampleDefinition(
    builder: _decorationUsage6,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      padding: const EdgeInsets.all(16),\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        shape: RoughBoxShape.roundedRectangle,\n        borderStyle: const RoughDrawingStyle(\n          width: 1.5,\n          color: Color(0xff716275),\n        ),\n        borderRadius: BorderRadius.circular(12),\n      ),\n      child: const Column(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: [\n          Text('Card Title', style: TextStyle(fontWeight: FontWeight.bold)),\n          SizedBox(height: 8),\n          Text('Card body text goes here.'),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-7': ExampleDefinition(
    builder: _decorationUsage7,
    source: "Builder(\n  builder: (context) {\n    return Container(\n      padding: const EdgeInsets.all(16),\n      decoration: RoughBoxDecoration(\n        borderStyle: const RoughDrawingStyle(\n          width: 2,\n          color: Color(0xff9b542d),\n        ),\n        fillStyle: const RoughDrawingStyle(width: 1, color: Color(0xfff6dfd5)),\n        filler: HachureFiller(FillerConfig.build(hachureGap: 20)),\n        drawConfig: DrawConfig.build(roughness: 1.5, seed: 7),\n      ),\n      child: const Row(\n        children: [\n          WiredIcon(\n            icon: IconData(0xe33d, fontFamily: 'MaterialIcons'),\n            color: Color(0xff9b542d),\n          ),\n          SizedBox(width: 12),\n          Expanded(child: Text('This is an important note.')),\n        ],\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-8': ExampleDefinition(
    builder: _decorationUsage8,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),\n      decoration: RoughBoxDecoration(\n        drawConfig: theme.drawConfig,\n        shape: RoughBoxShape.roundedRectangle,\n        borderStyle: const RoughDrawingStyle(\n          width: 1,\n          color: Color(0xff456c5c),\n        ),\n        fillStyle: const RoughDrawingStyle(\n          width: 0.5,\n          color: Color(0xffeef1df),\n        ),\n        filler: SolidFiller(FillerConfig.defaultConfig),\n        borderRadius: BorderRadius.circular(20),\n      ),\n      child: const Text(\n        'flutter',\n        style: TextStyle(color: Color(0xff456c5c), fontSize: 12),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'decoration-usage-9': ExampleDefinition(
    builder: _decorationUsage9,
    source: "Builder(\n  builder: (context) {\n    return Container(\n      width: 200,\n      height: 100,\n      decoration: RoughBoxDecoration(\n        borderStyle: const RoughDrawingStyle(\n          width: 2,\n          color: Color(0xFF1A2B3C),\n        ),\n        fillStyle: const RoughDrawingStyle(\n          width: 1,\n          color: Color(0xFFE8E8E8),\n        ),\n        drawConfig: DrawConfig.build(roughness: 1.5),\n        filler: HachureFiller(),\n      ),\n      child: const Center(child: Text('Sketchy box')),\n    );\n  },\n)",
    edits: [],
  ),
  'theme-drawing-1': ExampleDefinition(
    builder: _themeDrawing1,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return SizedBox(\n      width: 240,\n      height: 140,\n      child: WiredCanvas(\n        painter: WiredRectangleBase(\n          fillColor: theme.fillColor,\n          borderColor: theme.borderColor,\n        ),\n        fillerType: RoughFilter.hachureFiller,\n        drawConfig: DrawConfig.build(roughness: 4, bowing: 3, seed: 42),\n      ),\n    );\n  },\n)",
    edits: [],
  ),
  'theme-drawing-2': ExampleDefinition(
    builder: _themeDrawing2,
    source: "Builder(\n  builder: (context) {\n    final theme = WiredTheme.of(context);\n    return Container(\n      decoration: RoughBoxDecoration(\n        borderStyle: RoughDrawingStyle(width: 2, color: theme.borderColor),\n        drawConfig: DrawConfig.build(roughness: 0.3), // very smooth\n      ),\n      child: const Text('Barely rough'),\n    );\n  },\n)",
    edits: [],
  ),
};
