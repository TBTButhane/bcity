import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
import 'package:bcity_web/views/pages/welcome_view.dart';
import 'package:bcity_web/views/pages/home_view.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      Router(
        routes: [
          Route(
            path: '/',
            title: 'Welcome',
            builder: (context, state) => const Welcome(),
          ),
          Route(
            path: '/home',
            title: 'Home',
            builder: (context, state) => const HomeView(),
          ),
        ],
      ),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('html, body').styles(
      width: 100.percent,
      height: 100.percent,
      padding: Spacing.zero,
      margin: Spacing.zero,
      fontFamily: const FontFamily.list([FontFamily('Inter'), FontFamilies.sansSerif]),
    ),
    css('*, *::before, *::after').styles(
      boxSizing: BoxSizing.borderBox,
    ),
    css('button, input').styles(
      fontFamily: const FontFamily.list([FontFamily('Inter'), FontFamilies.sansSerif]),
    ),
  ];
}