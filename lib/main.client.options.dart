// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'package:jaspr/client.dart';

import 'package:bcity_web/views/pages/contact_view.dart'
    deferred as _contact_view;
import 'package:bcity_web/views/pages/create_client_view.dart'
    deferred as _create_client_view;
import 'package:bcity_web/views/pages/home_view.dart' deferred as _home_view;

/// Default [ClientOptions] for use with your Jaspr project.
///
/// Use this to initialize Jaspr **before** calling [runApp].
///
/// Example:
/// ```dart
/// import 'main.client.options.dart';
///
/// void main() {
///   Jaspr.initializeApp(
///     options: defaultClientOptions,
///   );
///
///   runApp(...);
/// }
/// ```
ClientOptions get defaultClientOptions => ClientOptions(
  clients: {
    'contact_view': ClientLoader(
      (p) => _contact_view.ContactView(),
      loader: _contact_view.loadLibrary,
    ),
    'create_client_view': ClientLoader(
      (p) => _create_client_view.CreateClientView(),
      loader: _create_client_view.loadLibrary,
    ),
    'home_view': ClientLoader(
      (p) => _home_view.HomeView(),
      loader: _home_view.loadLibrary,
    ),
  },
);
