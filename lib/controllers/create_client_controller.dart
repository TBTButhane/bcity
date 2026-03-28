import 'dart:convert';
import 'package:universal_web/web.dart' as web;
import 'package:universal_web/js_interop.dart';


class CreateClientController {

  late void Function(void Function()) notify;

  // General tab state 

  String  name          = '';
  String? nameError;
  String? serverError;
  bool    isLoading     = false;
  bool    saved         = false;
  String? generatedCode;
  int?    savedClientId;
  int     activeTab     = 0;

  // All-clients list (shown below the form)

  List<Map<String, dynamic>> allClients   = [];
  bool    listLoading = true;
  String? listError;

  // Contacts tab state 

  List<Map<String, dynamic>> linkedContacts   = [];
  List<Map<String, dynamic>> availableClients = [];
  bool    contactsLoading = false;
  String? contactsError;
  bool    linking = false;

  // Validation

  String? validateName(String v) {
    if (v.trim().isEmpty)      return 'Name is required.';
    if (v.trim().length > 100) return 'Name must be 100 characters or less.';
    return null;
  }

  bool get formValid => nameError == null && name.isNotEmpty;

  // HTTP helpers

  Future<dynamic> _rawFetch(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = web.Headers();
    headers.append('Content-Type', 'application/json');

    final resp = await web.window
        .fetch(
          path.toJS,
          web.RequestInit(
            method: method,
            headers: headers,
            body: body != null ? jsonEncode(body).toJS : null,
          ),
        )
        .toDart;

    final jsText  = await resp.text().toDart;
    final decoded = jsonDecode(jsText.toDart);

    if (!resp.ok) {
      final err = decoded is Map ? decoded['error'] : 'Request failed';
      throw err ?? 'Request failed';
    }
    return decoded;
  }

  Future<Map<String, dynamic>> fetchMap(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final data = await _rawFetch(method, path, body: body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> fetchList(
    String method,
    String path,
  ) async {
    final data = await _rawFetch(method, path);
    return (data as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }


  /// Loads the full client list shown in the table below the form.
  Future<void> loadAllClients() async {
    notify(() { listLoading = true; listError = null; });
    try {
      final list = await fetchList('GET', '/api/clients');
      notify(() { allClients = list; listLoading = false; });
    } catch (e) {
      notify(() { listError = e.toString(); listLoading = false; });
    }
  }

  /// Loads linked contacts and available clients for the Contacts tab.
  Future<void> loadContacts() async {
    if (savedClientId == null) return;
    notify(() { contactsLoading = true; contactsError = null; });

    try {
      final id        = savedClientId!;
      final linked    = await fetchList('GET', '/api/clients/$id/contacts');
      final available = await fetchList('GET', '/api/clients/$id/available');

      notify(() {
        linkedContacts   = linked;
        availableClients = available;
        contactsLoading  = false;
        linking          = false;
      });
    } catch (e) {
      notify(() {
        contactsError   = e.toString();
        contactsLoading = false;
        linking         = false;
      });
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Validates and submits the create-client form.
  Future<void> submit() async {
    final err = validateName(name);
    notify(() { nameError = err; serverError = null; });
    if (err != null) return;

    notify(() => isLoading = true);

    try {
      final data = await fetchMap('POST', '/api/clients',
          body: {'name': name.trim()});

      notify(() {
        generatedCode = data['code'] as String;
        savedClientId = data['id']   as int?;
        saved         = true;
        isLoading     = false;
      });

      // Refresh the list below the form immediately after saving
      await loadAllClients();
    } catch (e) {
      notify(() { serverError = e.toString(); isLoading = false; });
    }
  }

  /// Resets the form so the user can create another client.
  void resetForm() {
    notify(() {
      name             = '';
      nameError        = null;
      serverError      = null;
      generatedCode    = null;
      savedClientId    = null;
      saved            = false;
      activeTab        = 0;
      linkedContacts   = [];
      availableClients = [];
    });
  }

  /// Updates the name field and re-validates live.
  void onNameChanged(String v) {
    notify(() { name = v; nameError = validateName(v); });
  }

  /// Switches the active tab; triggers a contacts load when switching to tab 1.
  void onTabChanged(int index) {
    notify(() => activeTab = index);
    if (index == 1 && saved) loadContacts();
  }

  /// Method to links an existing client as a contact.
  Future<void> linkContact(int contactId) async {
    if (savedClientId == null) return;
    notify(() => linking = true);
    try {
      await fetchMap('POST', '/api/clients/$savedClientId/contacts',
          body: {'contact_id': contactId});
      await loadContacts();
      await loadAllClients();
    } catch (e) {
      notify(() { contactsError = e.toString(); linking = false; });
    }
  }

  /// Method to unlinks a contact.
  Future<void> unlinkContact(int contactId) async {
    if (savedClientId == null) return;
    notify(() => linking = true);
    try {
      await fetchMap('DELETE',
          '/api/clients/$savedClientId/contacts/$contactId');
      await loadContacts();
      await loadAllClients();
    } catch (e) {
      notify(() { contactsError = e.toString(); linking = false; });
    }
  }
}