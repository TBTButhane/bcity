import 'package:sqlite3/sqlite3.dart';
//The database class
class AppDatabase {
  static Database? _database;

  static Database get database {
    _database ??= _init();
    return _database!;
  }

  static Database _init() {
    final db = sqlite3.open('bcity.db');

    // Clients table
    db.execute('''
      CREATE TABLE IF NOT EXISTS clients (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL,
        code       TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      );
    ''');

    // Contacts table (separate from clients) 
    db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT NOT NULL,
        surname    TEXT NOT NULL,
        email      TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL
      );
    ''');

    // ── Junction: contact linked to many clients 
    // contact_id → the contact
    // client_id  → one of the clients linked to that contact
    db.execute('''
      CREATE TABLE IF NOT EXISTS contact_clients (
        contact_id INTEGER NOT NULL,
        client_id  INTEGER NOT NULL,
        PRIMARY KEY (contact_id, client_id),
        FOREIGN KEY (contact_id) REFERENCES contacts(id),
        FOREIGN KEY (client_id)  REFERENCES clients(id)
      );
    ''');

    // Junction: client linked to many contacts (kept for create_client) 
    db.execute('''
      CREATE TABLE IF NOT EXISTS client_contacts (
        client_id  INTEGER NOT NULL,
        contact_id INTEGER NOT NULL,
        PRIMARY KEY (client_id, contact_id),
        FOREIGN KEY (client_id)  REFERENCES clients(id),
        FOREIGN KEY (contact_id) REFERENCES contacts(id)
      );
    ''');

    return db;
  }


  // CLIENTS
  
  static int insertClient(String name, String code) {
    database.execute(
      'INSERT INTO clients (name, code, created_at) VALUES (?, ?, ?)',
      [name, code, DateTime.now().toIso8601String()],
    );
    return database.lastInsertRowId;
  }

  static List<Map<String, dynamic>> getAllClients() {
    final result = database.select('''
      SELECT
        c.id,
        c.name,
        c.code,
        COUNT(cc.contact_id) AS contact_count
      FROM clients c
      LEFT JOIN client_contacts cc ON c.id = cc.client_id
      GROUP BY c.id
      ORDER BY c.name ASC
    ''');

    return result.map((row) => {
      'id':            row['id'],
      'name':          row['name'],
      'code':          row['code'],
      'contact_count': (row['contact_count'] as int?) ?? 0,
    }).toList();
  }

  static bool codeExists(String code) {
    final result = database.select(
      'SELECT 1 FROM clients WHERE code = ?', [code],
    );
    return result.isNotEmpty;
  }

  // Returns clients NOT yet linked to a given contact (for the link picker)
  static List<Map<String, dynamic>> getClientsNotLinkedToContact(int contactId) {
    final result = database.select('''
      SELECT id, name, code
      FROM clients
      WHERE id NOT IN (
        SELECT client_id FROM contact_clients WHERE contact_id = ?
      )
      ORDER BY name ASC
    ''', [contactId]);

    return result.map((row) => {
      'id':   row['id'],
      'name': row['name'],
      'code': row['code'],
    }).toList();
  }

  // Returns clients already linked to a given contact
  static List<Map<String, dynamic>> getClientsLinkedToContact(int contactId) {
    final result = database.select('''
      SELECT cl.id, cl.name, cl.code
      FROM clients cl
      INNER JOIN contact_clients cc ON cl.id = cc.client_id
      WHERE cc.contact_id = ?
      ORDER BY cl.name ASC
    ''', [contactId]);

    return result.map((row) => {
      'id':   row['id'],
      'name': row['name'],
      'code': row['code'],
    }).toList();
  }

  // Link / unlink on the client side (used by create_client)
  static void linkClientContact(int clientId, int contactId) {
    database.execute(
      'INSERT OR IGNORE INTO client_contacts (client_id, contact_id) VALUES (?, ?)',
      [clientId, contactId],
    );
  }

  static void unlinkClientContact(int clientId, int contactId) {
    database.execute(
      'DELETE FROM client_contacts WHERE client_id = ? AND contact_id = ?',
      [clientId, contactId],
    );
  }


  // CONTACTS

  // Returns the new row id
  static int insertContact(String name, String surname, String email) {
    database.execute(
      '''INSERT INTO contacts (name, surname, email, created_at)
         VALUES (?, ?, ?, ?)''',
      [name, surname, email, DateTime.now().toIso8601String()],
    );
    return database.lastInsertRowId;
  }

  // All contacts ordered by surname then name ascending (full name sort)
  static List<Map<String, dynamic>> getAllContacts() {
    final result = database.select('''
      SELECT
        c.id,
        c.name,
        c.surname,
        c.email,
        COUNT(cc.client_id) AS client_count
      FROM contacts c
      LEFT JOIN contact_clients cc ON c.id = cc.contact_id
      GROUP BY c.id
      ORDER BY c.surname ASC, c.name ASC
    ''');

    return result.map((row) => {
      'id':           row['id'],
      'name':         row['name'],
      'surname':      row['surname'],
      'email':        row['email'],
      'client_count': (row['client_count'] as int?) ?? 0,
    }).toList();
  }

  static bool contactEmailExists(String email) {
    final result = database.select(
      'SELECT 1 FROM contacts WHERE email = ?', [email],
    );
    return result.isNotEmpty;
  }

  // Link a client to a contact
  static void linkContactClient(int contactId, int clientId) {
    database.execute(
      'INSERT OR IGNORE INTO contact_clients (contact_id, client_id) VALUES (?, ?)',
      [contactId, clientId],
    );
  }

  // Unlink a client from a contact
  static void unlinkContactClient(int contactId, int clientId) {
    database.execute(
      'DELETE FROM contact_clients WHERE contact_id = ? AND client_id = ?',
      [contactId, clientId],
    );
  }
}