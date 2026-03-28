import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class Welcome extends StatelessComponent {
  const Welcome({super.key});

  @override
  Component build(BuildContext context) {
    return section(
      styles: Styles(
        display: Display.flex,
        width: 100.vw,
        height: 100.vh,
        padding: Padding.symmetric(horizontal: 24.px),
        boxSizing: BoxSizing.borderBox,
        overflow: Overflow.hidden,
        // Deep navy background matching the sidebar
        flexDirection: FlexDirection.column,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.center,
        gap: Gap.column(20.px),
        textAlign: TextAlign.center,
        backgroundColor: Color.value(0x0F172A),
      ),
      [
        // Logo mark
        div(
          styles: Styles(
            display: Display.flex,
            width: 64.px,
            height: 64.px,
            margin: Spacing.only(bottom: 8.px), // indigo accent
            radius: BorderRadius.all(Radius.circular(16.px)),
            justifyContent: JustifyContent.center,
            alignItems: AlignItems.center,
            color: Colors.white,
            fontSize: 28.px,
            fontWeight: FontWeight.bold,
            backgroundColor: Color.value(0x6366F1),
          ),
          [.text('B')],
        ),

        h1(
          styles: Styles(
            margin: Spacing.zero,
            color: Colors.white,
            fontSize: 2.5.rem,
            fontWeight: FontWeight.w700,
            letterSpacing: (-0.5).px,
          ),
          [.text('Welcome to BCity')],
        ),

        p(
          styles: Styles(
            maxWidth: 380.px,
            margin: Spacing.zero,
            color: Color.value(0x94A3B8), // slate-400
            fontSize: 1.rem,
          ),
          [.text('Manage your clients and contacts from one clean dashboard.')],
        ),

        // CTA button
        a(
          href: '/home',
          styles: Styles(
            display: Display.inlineBlock,
            padding: Padding.symmetric(vertical: 14.px, horizontal: 32.px),
            margin: Spacing.only(top: 8.px),
            border: Border.unset,
            radius: BorderRadius.all(Radius.circular(10.px)),
            color: Colors.white,
            fontSize: 1.rem,
            fontWeight: FontWeight.w600,
            textDecoration: TextDecoration.none,
            backgroundColor: Color.value(0x6366F1), // indigo
          ),
          [.text('Go to Dashboard →')],
        ),
      ],
    );
  }
}