import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/menu_constants.dart';

class SideMenuHeader extends StatelessWidget {
  /// Menu header widget. Automatically adapts to menu state changes.
  const SideMenuHeader({
    super.key,
    required this.isOpen,
    this.decoration,
    this.padding = const EdgeInsets.all(8),
    this.margin = const EdgeInsets.only(bottom: 8),
    this.horizontalSpacing = 5,
    this.duration = MenuConstants.duration,
    this.animationCurve = Curves.linear,
    this.leading,
    this.child,
    this.trailing,
    this.onTap,
    // this.height = MenuConstants.headerHeight,
  }) : assert(leading != null || trailing != null, 'At least one of leading or trailing must be provided');

  /// Whether menu is collapsed or not.
  final bool isOpen;

  /// The height of the header.
  ///
  /// Defaults to [MenuConstants.headerHeight] if not set.
  // final double height;

  /// Decoration for the main drawer header [Container]; useful for applying backgrounds.
  ///
  /// If this is changed, it will be animated according to [duration] and [animationCurve].
  final Decoration? decoration;

  /// The padding by which to inset [leading], [child] and [trailing].
  final EdgeInsetsGeometry padding;

  /// The margin around the menu header.
  final EdgeInsetsGeometry? margin;

  /// The horizontal spacing between [leading], [child] and [trailing].
  final double horizontalSpacing;

  /// The duration for animations of the [decoration].
  ///
  /// Defaults to [MenuConstants.duration] if not provided.
  ///
  /// If null default menu duration will be applied.
  final Duration duration;

  /// The curve for animations of the [decoration].
  ///
  /// Defaults to [Curves.linear] if not provided.
  final Curve animationCurve;

  /// The widget to be placed at the start of the menu header.
  ///
  /// If not null, will still be visible when the menu is collapsed.
  final Widget? leading;

  /// A widget to be placed inside the menu header.
  ///
  /// It will be hidden when the menu is collapsed.
  ///
  /// This widget will be sized to 3/5 of the header's width if both [leading] and [trailing] are set
  /// and to 3/4 if only one of them is set.
  final Widget? child;

  /// The widget to be placed at the end of the menu header.
  ///
  /// Will still be visible if [leading is null and menu is collapsed.
  final Widget? trailing;

  /// Called when the user taps this widget.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: AnimatedContainer(
          duration: duration,
          curve: animationCurve,
          child: Row(
            spacing: horizontalSpacing,
            children: [
              if (leading != null) Expanded(child: leading!),
              //
              if (isOpen) ...[
                if (child != null) Expanded(flex: 3, child: child!),
                if (trailing != null) Expanded(child: trailing!),
              ],
              //
              if (!isOpen && leading == null) Expanded(child: trailing!),
            ],
          ),
        ),
      ),
    );
  }

  // coverage:ignore-start
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(FlagProperty('isOpen', value: isOpen, ifTrue: 'open', ifFalse: 'collapsed'))
      ..add(DiagnosticsProperty<Decoration>('decoration', decoration, defaultValue: null))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('padding', padding))
      ..add(DiagnosticsProperty<EdgeInsetsGeometry>('margin', margin, defaultValue: null))
      ..add(DoubleProperty('horizontalSpacing', horizontalSpacing))
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(DiagnosticsProperty<Curve>('animationCurve', animationCurve))
      ..add(FlagProperty('hasLeading', value: leading != null, ifTrue: 'has leading', ifFalse: 'no leading'))
      ..add(FlagProperty('hasChild', value: child != null, ifTrue: 'has child', ifFalse: 'no child'))
      ..add(FlagProperty('hasTrailing', value: trailing != null, ifTrue: 'has trailing', ifFalse: 'no trailing'))
      ..add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }

  // coverage:ignore-end
}
