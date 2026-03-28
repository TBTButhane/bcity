import 'dart:convert';
import 'package:universal_web/web.dart' as web;
import 'package:universal_web/js_interop.dart';

class ContactController {

  late void Function(void Function()) notify;

  //General tab — form fields

  String  name     = '';
  String  surname  = '';
  String  email    = '';

  String? nameError;
  String? surnameError;
  String? emailError;
  String? serverError;

  bool    isLoading    = false;
  bool    saved        = false;
  int?    savedContactId;
  int     activeTab    = 0;

  //All contacts list

  List<Map<String, dynamic>> allContacts  = [];
  bool    listLoading = true;
  String? listError;

  //Client(s) tab state 

  List<Map<String, dynamic>> linkedClients    = [];
  List<Map<String, dynamic>> availableClients = [];
  bool    clientsLoading = false;
  String? clientsError;
  bool    linking = false;

  //Validation
  String? validateName(String v) {
    if (v.trim().isEmpty)      return 'Name is required.';
    if (v.trim().length > 100) return 'Name must be 100 characters or less.';
    return null;
  }

  String? validateSurname(String v) {
    if (v.trim().isEmpty)      return 'Surname is required.';
    if (v.trim().length > 100) return 'Surname must be 100 characters or less.';
    return null;
  }

  String? validateEmail(String v) {
    if (v.trim().isEmpty) return 'Email is required.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    if (!ok) return 'Please enter a valid email address.';
    return null;
  }

  bool get formValid =>
      nameError    == null &&
      surnameError == null &&
      emailError   == null &&
      name.isNotEmpty &&
      surname.isNotEmpty &&
      email.isNotEmpty;

  //HTTP helpers

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


  /// Loads the full contacts list shown below the form.
  Future<void> loadAllContacts() async {
    notify(() { listLoading = true; listError = null; });
    try {
      final list = await fetchList('GET', '/api/contacts');
      notify(() { allContacts = list; listLoading = false; });
    } catch (e) {
      notify(() { listError = e.toString(); listLoading = false; });
    }
  }

  /// Loads linked clients and available clients for the Client(s) tab.
  Future<void> loadClients() async {
    if (savedContactId == null) return;
    notify(() { clientsLoading = true; clientsError = null; });

    try {
      final id        = savedContactId!;
      final linked    = await fetchList('GET', '/api/contacts/$id/clients');
      final available = await fetchList('GET', '/api/contacts/$id/available');

      notify(() {
        linkedClients    = linked;
        availableClients = available;
        clientsLoading   = false;
        linking          = false;
      });
    } catch (e) {
      notify(() {
        clientsError   = e.toString();
        clientsLoading = false;
        linking        = false;
      });
    }
  }


  /// Validates and submits the create-contact form.
  Future<void> submit() async {
    notify(() {
      nameError    = validateName(name);
      surnameError = validateSurname(surname);
      emailError   = validateEmail(email);
      serverError  = null;
    });
    if (!formValid) return;

    notify(() => isLoading = true);

    try {
      final data = await fetchMap('POST', '/api/contacts', body: {
        'name':    name.trim(),
        'surname': surname.trim(),
        'email':   email.trim(),
      });

      notify(() {
        savedContactId = data['id'] as int?;
        saved          = true;
        isLoading      = false;
      });

      // Refresh the list below the form immediately
      await loadAllContacts();
    } catch (e) {
      notify(() { serverError = e.toString(); isLoading = false; });
    }
  }

  /// Resets the form so the user can create another contact.
  void resetForm() {
    notify(() {
      name             = '';
      surname          = '';
      email            = '';
      nameError        = null;
      surnameError     = null;
      emailError       = null;
      serverError      = null;
      savedContactId   = null;
      saved            = false;
      activeTab        = 0;
      linkedClients    = [];
      availableClients = [];
    });
  }

  /// Live-update handlers — called from onInput in the view.
  void onNameChanged(String v) =>
      notify(() { name = v; nameError = validateName(v); });

  void onSurnameChanged(String v) =>
      notify(() { surname = v; surnameError = validateSurname(v); });

  void onEmailChanged(String v) =>
      notify(() { email = v; emailError = validateEmail(v); });

  /// Switches tab; triggers a clients load when switching to tab 1.
  void onTabChanged(int index) {
    notify(() => activeTab = index);
    if (index == 1 && saved) loadClients();
  }

  /// Links a client to this contact.
  Future<void> linkClient(int clientId) async {
    if (savedContactId == null) return;
    notify(() => linking = true);
    try {
      await fetchMap('POST', '/api/contacts/$savedContactId/clients',
          body: {'client_id': clientId});
      await loadClients();
      await loadAllContacts();
    } catch (e) {
      notify(() { clientsError = e.toString(); linking = false; });
    }
  }

  /// Unlinks a client from this contact.
  Future<void> unlinkClient(int clientId) async {
    if (savedContactId == null) return;
    notify(() => linking = true);
    try {
      await fetchMap('DELETE',
          '/api/contacts/$savedContactId/clients/$clientId');
      await loadClients();
      await loadAllContacts();
    } catch (e) {
      notify(() { clientsError = e.toString(); linking = false; });
    }
  }
}