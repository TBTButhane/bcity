/// The entrypoint for the server environment.
library;

import 'dart:convert';
import 'dart:io';

import 'package:jaspr/server.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'package:bcity_web/components/client_code_gen.dart';
import 'package:bcity_web/db/database.dart';

import 'app.dart';
import 'main.server.options.dart';

void main() async {
  AppDatabase.database;

  Jaspr.initializeApp(options: defaultServerOptions);

  final router = Router();


  // CLIENT ROUTES

  // POST /api/clients  { "name": "Acme" }
  router.post('/api/clients', (Request req) async {
    final body = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final name = (body['name'] as String? ?? '').trim();

    if (name.isEmpty)       return _json(400, {'error': 'Name is required.'});
    if (name.length > 100)  return _json(400, {'error': 'Name must be 100 characters or less.'});

    try {
      final code = ClientCodeGenerator.generate(name);
      final id   = AppDatabase.insertClient(name, code);
      return _json(200, {'code': code, 'id': id});
    } catch (e) {
      return _json(500, {'error': e.toString()});
    }
  });

  // GET /api/clients
  router.get('/api/clients', (Request req) {
    return _json(200, AppDatabase.getAllClients());
  });

  // GET /api/clients/:id/contacts  — contacts linked to a client
  router.get('/api/clients/<id>/contacts', (Request req, String id) {
    final clientId = int.tryParse(id);
    if (clientId == null) return _json(400, {'error': 'Invalid id.'});
    // Reuse getClientsLinkedToContact but from the client side:
    // we need contacts linked to this client, not clients linked to a contact.
    // These are stored in client_contacts (client_id → contact_id).
    final result = AppDatabase.database.select('''
      SELECT c.id, c.name, c.surname, c.email
      FROM contacts c
      INNER JOIN client_contacts cc ON c.id = cc.contact_id
      WHERE cc.client_id = ?
      ORDER BY c.surname ASC, c.name ASC
    ''', [clientId]);
    return _json(200, result.map((r) => {
      'id':      r['id'],
      'name':    r['name'],
      'surname': r['surname'],
      'email':   r['email'],
    }).toList());
  });

  // GET /api/clients/:id/available  — contacts NOT yet linked to a client
  router.get('/api/clients/<id>/available', (Request req, String id) {
    final clientId = int.tryParse(id);
    if (clientId == null) return _json(400, {'error': 'Invalid id.'});
    final result = AppDatabase.database.select('''
      SELECT id, name, surname, email
      FROM contacts
      WHERE id NOT IN (
        SELECT contact_id FROM client_contacts WHERE client_id = ?
      )
      ORDER BY surname ASC, name ASC
    ''', [clientId]);
    return _json(200, result.map((r) => {
      'id':      r['id'],
      'name':    r['name'],
      'surname': r['surname'],
      'email':   r['email'],
    }).toList());
  });

  // POST /api/clients/:id/contacts  { "contact_id": 3 }
  router.post('/api/clients/<id>/contacts', (Request req, String id) async {
    final clientId = int.tryParse(id);
    if (clientId == null) return _json(400, {'error': 'Invalid id.'});
    final body      = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final contactId = body['contact_id'] as int?;
    if (contactId == null) return _json(400, {'error': 'contact_id is required.'});
    AppDatabase.linkClientContact(clientId, contactId);
    return _json(200, {'success': true});
  });

  // DELETE /api/clients/:id/contacts/:contactId
  router.delete(
    '/api/clients/<id>/contacts/<contactId>',
    (Request req, String id, String contactId) {
      final clientId = int.tryParse(id);
      final cId      = int.tryParse(contactId);
      if (clientId == null || cId == null) return _json(400, {'error': 'Invalid id.'});
      AppDatabase.unlinkClientContact(clientId, cId);
      return _json(200, {'success': true});
    },
  );


  // CONTACT ROUTES

  // POST /api/contacts  { "name": "John", "surname": "Smith", "email": "j@s.com" }
  // Response: { "id": 1 }
  router.post('/api/contacts', (Request req) async {
    final body    = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final name    = (body['name']    as String? ?? '').trim();
    final surname = (body['surname'] as String? ?? '').trim();
    final email   = (body['email']   as String? ?? '').trim();

    if (name.isEmpty)    return _json(400, {'error': 'Name is required.'});
    if (surname.isEmpty) return _json(400, {'error': 'Surname is required.'});
    if (email.isEmpty)   return _json(400, {'error': 'Email is required.'});
    if (!_validEmail(email)) {
      return _json(400, {'error': 'Please enter a valid email address.'});
    }
    if (AppDatabase.contactEmailExists(email)) {
      return _json(400, {'error': 'A contact with this email already exists.'});
    }

    try {
      final id = AppDatabase.insertContact(name, surname, email);
      return _json(200, {'id': id});
    } catch (e) {
      return _json(500, {'error': e.toString()});
    }
  });

  // GET /api/contacts  — all contacts ordered by surname name
  router.get('/api/contacts', (Request req) {
    return _json(200, AppDatabase.getAllContacts());
  });

  // GET /api/contacts/:id/clients  — clients linked to this contact
  router.get('/api/contacts/<id>/clients', (Request req, String id) {
    final contactId = int.tryParse(id);
    if (contactId == null) return _json(400, {'error': 'Invalid id.'});
    return _json(200, AppDatabase.getClientsLinkedToContact(contactId));
  });

  // GET /api/contacts/:id/available  — clients NOT yet linked to this contact
  router.get('/api/contacts/<id>/available', (Request req, String id) {
    final contactId = int.tryParse(id);
    if (contactId == null) return _json(400, {'error': 'Invalid id.'});
    return _json(200, AppDatabase.getClientsNotLinkedToContact(contactId));
  });

  // POST /api/contacts/:id/clients  { "client_id": 2 }
  router.post('/api/contacts/<id>/clients', (Request req, String id) async {
    final contactId = int.tryParse(id);
    if (contactId == null) return _json(400, {'error': 'Invalid id.'});
    final body     = jsonDecode(await req.readAsString()) as Map<String, dynamic>;
    final clientId = body['client_id'] as int?;
    if (clientId == null) return _json(400, {'error': 'client_id is required.'});
    AppDatabase.linkContactClient(contactId, clientId);
    return _json(200, {'success': true});
  });

  // DELETE /api/contacts/:id/clients/:clientId
  router.delete(
    '/api/contacts/<id>/clients/<clientId>',
    (Request req, String id, String clientId) {
      final contactId = int.tryParse(id);
      final cId       = int.tryParse(clientId);
      if (contactId == null || cId == null) return _json(400, {'error': 'Invalid id.'});
      AppDatabase.unlinkContactClient(contactId, cId);
      return _json(200, {'success': true});
    },
  );

  // ── Jaspr SSR + combine ───────────────────────────────────────────────────
  final jasprHandler = serveApp((request, render) => render(const App()));
  final combined     = Cascade().add(router).add(jasprHandler).handler;
  final reloadLock   = activeReloadLock = Object();

  final server = await shelf_io.serve(
    const Pipeline().addMiddleware(logRequests()).addHandler(combined),
    InternetAddress.anyIPv4,
    8080,
    shared: true,
  );

  if (reloadLock != activeReloadLock) { await server.close(); return; }
  activeServer?.close();
  activeServer = server;
  print('Serving at http://${server.address.host}:${server.port}');
}

bool _validEmail(String e) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e);

Response _json(int status, Object body) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json'},
);

HttpServer? activeServer;
Object? activeReloadLock;