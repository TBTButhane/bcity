import 'dart:convert';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:bcity_web/views/components/side_bar_item.dart';
import 'package:bcity_web/models/client.dart';
import 'package:bcity_web/views/pages/client_page.dart';
import 'package:bcity_web/views/pages/create_client_view.dart';
import 'package:bcity_web/views/pages/contact_view.dart';
import 'package:universal_web/web.dart' as web;
import 'package:universal_web/js_interop.dart';

enum _Page { dashboard, clients, createClient, contacts }

@client
class HomeView extends StatefulComponent {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool  _isExpanded = true;
  _Page _activePage = _Page.dashboard;

  void _toggle()              => setState(() => _isExpanded = !_isExpanded);
  void _navigate(_Page page)  => setState(() => _activePage = page);

  String get _pageTitle => switch (_activePage) {
    _Page.dashboard    => 'Dashboard',
    _Page.clients      => 'Clients',
    _Page.createClient => 'Create Client',
    _Page.contacts     => 'Contacts',
  };

  static const _sidebarBg   = Color.value(0x0F172A);
  static const _accent      = Color.value(0x6366F1);
  static const _headerBg    = Color.value(0xFFFFFF);
  static const _mainBg      = Color.value(0xF1F5F9);
  static const _headerBorder = Color.value(0xE2E8F0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(
        display: Display.flex,
        width: 100.vw,
        height: 100.vh,
        overflow: Overflow.hidden,
        fontFamily: FontFamily('Inter, system-ui, sans-serif'),
      ),
      [
        //Sidebar 
        aside(
          styles: Styles(
            display: Display.flex,
            width: _isExpanded ? 240.px : 64.px,
            overflow: Overflow.hidden,
            transition: Transition('width', duration: Duration(milliseconds: 300)),
            flexDirection: FlexDirection.column,
            backgroundColor: _sidebarBg,
          ),
          [
            // Logo
            div(
              styles: Styles(
                display: Display.flex,
                padding: Padding.symmetric(
                    vertical: 24.px,
                    horizontal: _isExpanded ? 20.px : 0.px),
                justifyContent: _isExpanded
                    ? JustifyContent.start
                    : JustifyContent.center,
                alignItems: AlignItems.center,
                gap: Gap.all(10.px),
              ),
              [
                div(
                  styles: Styles(
                    display: Display.flex,
                    width: 32.px,
                    height: 32.px,
                    radius: BorderRadius.all(Radius.circular(8.px)),
                    justifyContent: JustifyContent.center,
                    alignItems: AlignItems.center,
                    color: Colors.white,
                    fontSize: 16.px,
                    fontWeight: FontWeight.bold,
                    backgroundColor: _accent,
                  ),
                  [.text('B')],
                ),
                if (_isExpanded)
                  span(
                    styles: Styles(
                      color: Colors.white,
                      fontSize: 18.px,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5.px,
                    ),
                    [.text('BCity')],
                  ),
              ],
            ),

            // Divider
            div(
              styles: Styles(
                height: 1.px,
                margin: Spacing.symmetric(horizontal: 12.px, vertical: 4.px),
                backgroundColor: Color.value(0x1E293B),
              ),
              [],
            ),

            // Nav items
            SideBarItem(
              isExpanded: _isExpanded,
              label: 'Clients',
              icon: 'images/user-avatar.png',
              isActive: _activePage == _Page.createClient,
              onTap: () => _navigate(_Page.createClient),
            ),
            // SideBarItem(
            //   isExpanded: _isExpanded,
            //   label: 'Clients',
            //   icon: 'images/user.png',
            //   isActive: _activePage == _Page.clients,
            //   onTap: () => _navigate(_Page.clients),
            // ),
            SideBarItem(
              isExpanded: _isExpanded,
              label: 'Contacts',
              icon: 'images/user.png',
              isActive: _activePage == _Page.contacts,
              onTap: () => _navigate(_Page.contacts),
            ),
          ],
        ),

        // Main column
        div(
          styles: Styles(
            display: Display.flex,
            overflow: Overflow.hidden,
            flexDirection: FlexDirection.column,
            flex: Flex(grow: 1),
          ),
          [
            // Header
            header(
              styles: Styles(
                display: Display.flex,
                height: 60.px,
                padding: Padding.symmetric(horizontal: 16.px),
                border: Border.only(
                  bottom: BorderSide(
                    style: BorderStyle.solid,
                    width: 1.px,
                    color: _headerBorder,
                  ),
                ),
                alignItems: AlignItems.center,
                backgroundColor: _headerBg,
              ),
              [
                button(
                  onClick: _toggle,
                  styles: Styles(
                    display: Display.flex,
                    width: 36.px,
                    height: 36.px,
                    border: Border.unset,
                    radius: BorderRadius.all(Radius.circular(6.px)),
                    cursor: Cursor.pointer,
                    justifyContent: JustifyContent.center,
                    alignItems: AlignItems.center,
                    fontSize: 18.px,
                    backgroundColor: Color.value(0xF1F5F9),
                  ),
                  [.text('☰')],
                ),
                span(
                  styles: Styles(
                    margin: Spacing.only(left: 16.px),
                    color: Color.value(0x0F172A),
                    fontSize: 16.px,
                    fontWeight: FontWeight.w600,
                  ),
                  [.text(_pageTitle)],
                ),
              ],
            ),

            // Page content
            main_(
              styles: Styles(
                overflow: Overflow.auto,
                flex: Flex(grow: 1),
                backgroundColor: _mainBg,
              ),
              [_buildPageContent()],
            ),
          ],
        ),
      ],
    );
  }

  Component _buildPageContent() => switch (_activePage) {
    _Page.dashboard    => _buildDashboard(),
    _Page.clients      => const _ClientsView(),
    _Page.createClient => const CreateClientView(),
    _Page.contacts     => const ContactView(),
  };

  Component _buildDashboard() => div(
    styles: Styles(
      display: Display.flex,
      padding: Padding.all(32.px),
      flexDirection: FlexDirection.column,
      gap: Gap.all(24.px),
    ),
    [
      h2(
        styles: Styles(
          margin: Spacing.zero,
          color: Color.value(0x0F172A),
          fontSize: 24.px,
          fontWeight: FontWeight.w700,
        ),
        [.text('Welcome back 👋')],
      ),
      p(
        styles: Styles(
          margin: Spacing.zero,
          color: Color.value(0x64748B),
          fontSize: 15.px,
        ),
        [.text('Select an option from the sidebar to get started.')],
      ),
      div(
        styles: Styles(
          display: Display.flex,
          flexWrap: FlexWrap.wrap,
          gap: Gap.all(16.px),
        ),
        [
          // _card(
          //   title: 'Clients',
          //   subtitle: 'View and manage all clients',
          //   emoji: '🏢',
          //   onTap: () => _navigate(_Page.clients),
          // ),
          _card(
            title: 'Clients',
            subtitle: 'Register a new client',
            emoji: '➕',
            onTap: () => _navigate(_Page.createClient),
          ),
          _card(
            title: 'Contacts',
            subtitle: 'Manage all contacts',
            emoji: '👤',
            onTap: () => _navigate(_Page.contacts),
          ),
        ],
      ),
    ],
  );

  Component _card({
    required String title,
    required String subtitle,
    required String emoji,
    required void Function() onTap,
  }) =>
      div(
        styles: Styles(
          display: Display.flex,
          width: 200.px,
          padding: Padding.all(20.px),
          border: Border.all(
            style: BorderStyle.solid,
            width: 1.px,
            color: Color.value(0xE2E8F0),
          ),
          radius: BorderRadius.all(Radius.circular(12.px)),
          cursor: Cursor.pointer,
          flexDirection: FlexDirection.column,
          gap: Gap.all(8.px),
          backgroundColor: Colors.white,
        ),
        events: {'click': (e) => onTap()},
        [
          span(styles: Styles(fontSize: 28.px), [.text(emoji)]),
          span(
            styles: Styles(
              color: Color.value(0x0F172A),
              fontSize: 15.px,
              fontWeight: FontWeight.w600,
            ),
            [.text(title)],
          ),
          span(
            styles: Styles(color: Color.value(0x64748B), fontSize: 13.px),
            [.text(subtitle)],
          ),
        ],
      );
}

// Clients list panel — fetches via API (no DB import in @client scope)
class _ClientsView extends StatefulComponent {
  const _ClientsView();

  @override
  State<_ClientsView> createState() => _ClientsViewState();
}

class _ClientsViewState extends State<_ClientsView> {
  List<Client> _clients = [];
  bool    _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _fetchClients();
  }

  Future<void> _fetchClients() async {
    try {
      final resp    = await web.window.fetch('/api/clients'.toJS).toDart;
      final jsText  = await resp.text().toDart;
      final list    = jsonDecode(jsText.toDart) as List<dynamic>;
      setState(() {
        _clients = list
            .map((e) => Client.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load clients.'; _loading = false; });
    }
  }

  @override
  Component build(BuildContext context) {
    if (_loading) {
      return div(
        styles: Styles(padding: Padding.all(24.px), color: Color.value(0x64748B)),
        [.text('Loading clients...')],
      );
    }
    if (_error != null) {
      return div(
        styles: Styles(padding: Padding.all(24.px), color: Color.value(0xEF4444)),
        [.text(_error!)],
      );
    }
    return ClientsPage(clients: _clients);
  }
}