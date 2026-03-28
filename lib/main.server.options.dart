// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/server.dart';
import 'package:bcity_web/views/pages/contact_view.dart' as _contact_view;
import 'package:bcity_web/views/pages/create_client_view.dart'
    as _create_client_view;
import 'package:bcity_web/views/pages/home_view.dart' as _home_view;
import 'package:bcity_web/app.dart' as _app;

/// Default [ServerOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.server.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultServerOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ServerOptions get defaultServerOptions => ServerOptions(
  clientId: 'main.client.dart.js',
  clients: {
    _contact_view.ContactView: ClientTarget<_contact_view.ContactView>(
      'contact_view',
    ),
    _create_client_view.CreateClientView:
        ClientTarget<_create_client_view.CreateClientView>(
          'create_client_view',
        ),
    _home_view.HomeView: ClientTarget<_home_view.HomeView>('home_view'),
  },
  styles: () => [..._app.App.styles],
);
