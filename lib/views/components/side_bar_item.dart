import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class SideBarItem extends StatelessComponent {
  const SideBarItem({
    super.key,
    required this.isExpanded,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  final bool     isExpanded;
  final String   label;
  final String   icon;
  final void Function() onTap;
  final bool     isActive;

  // Design tokens (matching home.dart)
  static const _activeBg   = Color.value(0x1E293B);
  static const _activeText = Color.value(0x6366F1);
  static const _idleText   = Color.value(0x94A3B8);
  static const _hoverBg    = Color.value(0x1E293B);

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        padding: Padding.symmetric(
          vertical: 12.px,
          horizontal: isExpanded ? 16.px : 0.px,
        ),
        margin: Spacing.symmetric(horizontal: 8.px, vertical: 2.px),
        border: isActive
            ? Border.only(
                left: BorderSide(
                  style: BorderStyle.solid,
                  width: 3.px,
                  color: _activeText,
                ),
              )
            : Border.unset,
        radius: BorderRadius.all(Radius.circular(6.px)),
        cursor: Cursor.pointer,
        justifyContent: isExpanded ? JustifyContent.start : JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap.all(12.px),
        backgroundColor: isActive ? _activeBg : Colors.transparent,
      ),
      events: {
        'click': (_) => onTap(),
      },
      [
        img(
          src: icon,
          width: 22,
          height: 22,
          styles: Styles(
            // Tint the icon colour to match active/idle state via CSS filter
            filter: isActive
                ? Filter.brightness(
                //    'brightness(0) saturate(100%) invert(48%) sepia(79%) '
                //     'saturate(2476%) hue-rotate(218deg) brightness(102%) contrast(98%)'
                // : 'brightness(0) invert(60%)'
                10
                ): Filter.revert
          ),
        ),
        if (isExpanded)
          span(
            styles: Styles(
              color: isActive ? _activeText : _idleText,
              fontSize: 14.px,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              whiteSpace: WhiteSpace.noWrap,
            ),
            [.text(label)],
          ),
      ],
    );
  }
}