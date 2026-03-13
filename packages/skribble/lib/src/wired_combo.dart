import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'canvas/wired_canvas.dart';
import 'rough/skribble_rough.dart';
import 'wired_base.dart';
import 'wired_theme.dart';

class WiredCombo<T> extends HookWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final bool? Function(T?)? onChanged;

  const WiredCombo({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = WiredTheme.of(context);
    final internalValue = useState<T?>(value);
    final height = useRef(60.0);

    useEffect(() {
      internalValue.value = value;
      return null;
    }, [value]);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      height: height.value,
      child: Stack(
        children: [
          Positioned(
            right: 10.0,
            top: 20.0,
            child: WiredCanvas(
              painter: WiredInvertedTriangleBase(
                borderColor: theme.borderColor,
              ),
              fillerType: RoughFilter.hachureFiller,
              fillerConfig: FillerConfig.build(hachureGap: 2),
              size: Size(18.0, 18.0),
            ),
          ),
          SizedBox(
            height: height.value,
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                itemHeight: height.value,
                isExpanded: true,
                elevation: 0,
                icon: Visibility(
                  visible: false,
                  child: Icon(Icons.arrow_downward),
                ),
                value: internalValue.value,
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item.value,
                    child: Stack(
                      children: [
                        WiredCanvas(
                          painter: WiredRectangleBase(
                            fillColor: theme.fillColor,
                            borderColor: theme.borderColor,
                          ),
                          fillerType: RoughFilter.noFiller,
                          size: Size(double.infinity, height.value),
                        ),
                        Positioned(top: 20.0, child: item.child),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (changedValue) {
                  final isControlled = onChanged?.call(changedValue) ?? false;

                  if (isControlled) {
                    return;
                  }

                  internalValue.value = changedValue;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
