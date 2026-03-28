// THIS FILE IS SERVER-ONLY.
// It imports database.dart (which uses sqlite3 / dart:ffi).

// Usage: add a route in app.dart that renders ClientsLoader, which in turn
// renders ClientsPage with the data already fetched.

import 'package:jaspr/server.dart';
import 'package:bcity_web/db/database.dart';
import 'package:bcity_web/models/client.dart';
import 'package:bcity_web/views/pages/client_page.dart';

class ClientsLoader extends StatelessComponent {
  const ClientsLoader({super.key});

  @override
  Component build(BuildContext context) {
    final clients = AppDatabase.getAllClients()
        .map(Client.fromMap)
        .toList();

    return ClientsPage(clients: clients);
  }
}