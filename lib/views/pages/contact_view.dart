import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:bcity_web/controllers/contacts_controller.dart';

@client
class ContactView extends StatefulComponent {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _ctrl = ContactController();

  @override
  void initState() {
    super.initState();
    // Wire notify → setState so every controller mutation triggers a rebuild
    _ctrl.notify = (fn) => setState(fn);
    if (kIsWeb) _ctrl.loadAllContacts();
  }

  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(padding: Padding.all(24.px)),
      [
        //Form section
        div(
          styles: Styles(
            maxWidth: 640.px,
            margin: Spacing.only(bottom: 40.px),
          ),
          [
            h2(
              styles: Styles(
                margin: Spacing.only(bottom: 24.px),
                color: Color.value(0x0F172A),
                fontSize: 20.px,
                fontWeight: FontWeight.w700,
              ),
              [.text('Create Contact')],
            ),

            // Tab bar
            div(
              styles: Styles(
                display: Display.flex,
                margin: Spacing.only(bottom: 24.px),
                border: Border.only(
                  bottom: BorderSide(
                    style: BorderStyle.solid,
                    width: 1.px,
                    color: Color.value(0xE2E8F0),
                  ),
                ),
              ),
              [
                _tabButton('General', 0),
                _tabButton('Client(s)', 1),
              ],
            ),

            if (_ctrl.activeTab == 0) _buildGeneralTab(),
            if (_ctrl.activeTab == 1) _buildClientsTab(),
          ],
        ),

        //All contacts list below the form
        _buildContactsList(),
      ],
    );
  }

  //Tab button

  Component _tabButton(String label, int index) {
    final isActive = _ctrl.activeTab == index;
    return button(
      onClick: () => _ctrl.onTabChanged(index),
      styles: Styles(
        padding: Padding.symmetric(vertical: 10.px, horizontal: 20.px),
        border: isActive
            ? Border.only(
                bottom: BorderSide(
                  style: BorderStyle.solid,
                  width: 2.px,
                  color: Color.value(0x6366F1),
                ),
              )
            : Border.unset,
        cursor: Cursor.pointer,
        color: isActive ? Color.value(0x6366F1) : Color.value(0x64748B),
        fontSize: 14.px,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        backgroundColor: Colors.transparent,
      ),
      [.text(label)],
    );
  }

  //General tab

  Component _buildGeneralTab() => div([
    // Name
    _field(
      label: 'Name *',
      child: input(
        type: InputType.text,
        value: _ctrl.name,
        attributes: {'placeholder': 'e.g. John'},
        onInput: (v) => _ctrl.onNameChanged(v.toString()),
        styles: _inputStyle(hasError: _ctrl.nameError != null),
      ),
      error: _ctrl.nameError,
    ),

    // Surname
    _field(
      label: 'Surname *',
      child: input(
        type: InputType.text,
        value: _ctrl.surname,
        attributes: {'placeholder': 'e.g. Smith'},
        onInput: (v) => _ctrl.onSurnameChanged(v.toString()),
        styles: _inputStyle(hasError: _ctrl.surnameError != null),
      ),
      error: _ctrl.surnameError,
    ),

    // Email
    _field(
      label: 'Email *',
      child: input(
        type: InputType.email,
        value: _ctrl.email,
        attributes: {'placeholder': 'e.g. john@example.com'},
        onInput: (v) => _ctrl.onEmailChanged(v.toString()),
        styles: _inputStyle(hasError: _ctrl.emailError != null),
      ),
      error: _ctrl.emailError,
    ),

    // Server error banner
    if (_ctrl.serverError != null)
      div(
        styles: Styles(
          padding: Padding.all(12.px),
          margin: Spacing.only(bottom: 16.px),
          border: Border.all(
            style: BorderStyle.solid,
            width: 1.px,
            color: Color.value(0xFECACA),
          ),
          radius: BorderRadius.all(Radius.circular(6.px)),
          color: Color.value(0xDC2626),
          fontSize: 14.px,
          backgroundColor: Color.value(0xFEF2F2),
        ),
        [.text(_ctrl.serverError!)],
      ),

    // Success banner
    if (_ctrl.saved)
      div(
        styles: Styles(
          padding: Padding.all(12.px),
          margin: Spacing.only(bottom: 16.px),
          border: Border.all(
            style: BorderStyle.solid,
            width: 1.px,
            color: Color.value(0xBBF7D0),
          ),
          radius: BorderRadius.all(Radius.circular(6.px)),
          color: Color.value(0x16A34A),
          fontSize: 14.px,
          backgroundColor: Color.value(0xF0FDF4),
        ),
        [.text('✓ Contact created successfully.')],
      ),

    // Buttons row
    div(
      styles: Styles(
        display: Display.flex,
        margin: Spacing.only(top: 4.px),
        gap: Gap.all(12.px),
      ),
      [
        if (!_ctrl.saved)
          button(
            onClick: _ctrl.isLoading ? null : _ctrl.submit,
            styles: Styles(
              padding: Padding.symmetric(vertical: 10.px, horizontal: 24.px),
              border: Border.unset,
              radius: BorderRadius.all(Radius.circular(6.px)),
              cursor: _ctrl.isLoading ? Cursor.notAllowed : Cursor.pointer,
              color: Colors.white,
              fontSize: 14.px,
              fontWeight: FontWeight.w600,
              backgroundColor: _ctrl.isLoading ? Color.value(0x94A3B8) : Color.value(0x6366F1),
            ),
            [.text(_ctrl.isLoading ? 'Saving...' : 'Save Contact')],
          ),

        if (_ctrl.saved)
          button(
            onClick: _ctrl.resetForm,
            styles: Styles(
              padding: Padding.symmetric(vertical: 10.px, horizontal: 24.px),
              border: Border.all(
                style: BorderStyle.solid,
                width: 1.px,
                color: Color.value(0x6366F1),
              ),
              radius: BorderRadius.all(Radius.circular(6.px)),
              cursor: Cursor.pointer,
              color: Color.value(0x6366F1),
              fontSize: 14.px,
              fontWeight: FontWeight.w600,
              backgroundColor: Colors.transparent,
            ),
            [.text('+ Create another')],
          ),
      ],
    ),
  ]);

  //Client(s) tab
  Component _buildClientsTab() {
    if (!_ctrl.saved) {
      return div(
        styles: Styles(
          padding: Padding.all(16.px),
          border: Border.all(
            style: BorderStyle.solid,
            width: 1.px,
            color: Color.value(0xFED7AA),
          ),
          radius: BorderRadius.all(Radius.circular(6.px)),
          color: Color.value(0x92400E),
          fontSize: 14.px,
          backgroundColor: Color.value(0xFFF7ED),
        ),
        [.text('Save the contact first before linking clients.')],
      );
    }

    if (_ctrl.clientsLoading) {
      return p(
        styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
        [.text('Loading...')],
      );
    }

    if (_ctrl.clientsError != null) {
      return p(
        styles: Styles(color: Color.value(0xDC2626), fontSize: 14.px),
        [.text(_ctrl.clientsError!)],
      );
    }

    return div([
      //Linked clients table
      if (_ctrl.linkedClients.isEmpty)
        p(
          styles: Styles(
            margin: Spacing.only(bottom: 24.px),
            color: Color.value(0x64748B),
            fontSize: 14.px,
          ),
          [.text('No contact(s) found.')],
        )
      else
        div(
          styles: Styles(margin: Spacing.only(bottom: 24.px)),
          [
            table(
              styles: Styles(
                width: 100.percent,
                raw: {'border-collapse': 'collapse'},
              ),
              [
                thead([
                  tr(
                    styles: Styles(backgroundColor: Color.value(0xF8FAFC)),
                    [
                      _th('Client name', align: TextAlign.left),
                      _th('Client code', align: TextAlign.left),

                      _th('', align: TextAlign.left),
                    ],
                  ),
                ]),
                tbody([
                  for (final c in _ctrl.linkedClients)
                    tr(
                      styles: Styles(
                        border: Border.only(
                          bottom: BorderSide(
                            style: BorderStyle.solid,
                            width: 1.px,
                            color: Color.value(0xE2E8F0),
                          ),
                        ),
                      ),
                      [
                        td(
                          styles: Styles(
                            padding: Padding.all(12.px),
                            color: Color.value(0x0F172A),
                            fontSize: 14.px,
                          ),
                          [.text(c['name'] as String)],
                        ),
                        td(
                          styles: Styles(
                            padding: Padding.all(12.px),
                            color: Color.value(0x6366F1),
                            fontFamily: FontFamily('monospace'),
                            fontSize: 14.px,
                            fontWeight: FontWeight.w600,
                          ),
                          [.text(c['code'] as String)],
                        ),
                        // Unlink action
                        td(
                          styles: Styles(
                            padding: Padding.all(12.px),
                            textAlign: TextAlign.left,
                          ),
                          [
                            _ctrl.linking
                                ? span(
                                    styles: Styles(
                                      color: Color.value(0x94A3B8),
                                      fontSize: 14.px,
                                    ),
                                    [.text('Unlinking...')],
                                  )
                                : a(
                                    href: '#',
                                    styles: Styles(
                                      cursor: Cursor.pointer,
                                      color: Color.value(0xEF4444),
                                      fontSize: 14.px,
                                      textDecoration: TextDecoration(
                                        line: TextDecorationLine.underline,
                                      ),
                                    ),
                                    events: {
                                      'click': (e) {
                                        e.preventDefault();
                                        _ctrl.unlinkClient(c['id'] as int);
                                      },
                                    },
                                    [.text('Unlink')],
                                  ),
                          ],
                        ),
                      ],
                    ),
                ]),
              ],
            ),
          ],
        ),

      //Link an existing client
      if (_ctrl.availableClients.isNotEmpty) ...[
        p(
          styles: Styles(
            margin: Spacing.only(bottom: 8.px),
            color: Color.value(0x0F172A),
            fontSize: 14.px,
            fontWeight: FontWeight.w600,
          ),
          [.text('Link an existing client')],
        ),
        div(
          styles: Styles(
            display: Display.flex,
            flexWrap: FlexWrap.wrap,
            gap: Gap.all(8.px),
          ),
          [
            for (final c in _ctrl.availableClients)
              button(
                onClick: _ctrl.linking ? null : () => _ctrl.linkClient(c['id'] as int),
                styles: Styles(
                  padding: Padding.symmetric(vertical: 6.px, horizontal: 14.px),
                  border: Border.all(
                    style: BorderStyle.solid,
                    width: 1.px,
                    color: Color.value(0x6366F1),
                  ),
                  radius: BorderRadius.all(Radius.circular(20.px)),
                  cursor: _ctrl.linking ? Cursor.notAllowed : Cursor.pointer,
                  color: Color.value(0x6366F1),
                  fontSize: 13.px,
                  backgroundColor: Colors.transparent,
                ),
                [.text('+ ${c['name']}')],
              ),
          ],
        ),
      ],

      if (_ctrl.availableClients.isEmpty && _ctrl.linkedClients.isNotEmpty)
        p(
          styles: Styles(
            margin: Spacing.only(top: 16.px),
            color: Color.value(0x94A3B8),
            fontSize: 13.px,
          ),
          [.text('All existing clients are already linked.')],
        ),
    ]);
  }

  // ── All contacts list ───────────────────────────────────────────────────────

  Component _buildContactsList() => div(
    styles: Styles(margin: Spacing.only(top: 8.px)),
    [
      h3(
        styles: Styles(
          margin: Spacing.only(bottom: 16.px),
          color: Color.value(0x0F172A),
          fontSize: 16.px,
          fontWeight: FontWeight.w700,
        ),
        [.text('All Contacts')],
      ),

      if (_ctrl.listLoading)
        p(
          styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
          [.text('Loading contacts...')],
        )
      else if (_ctrl.listError != null)
        p(
          styles: Styles(color: Color.value(0xDC2626), fontSize: 14.px),
          [.text(_ctrl.listError!)],
        )
      else if (_ctrl.allContacts.isEmpty)
        p(
          styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
          [.text('No contact(s) found.')],
        )
      else
        table(
          styles: Styles(
            width: 100.percent,
            raw: {'border-collapse': 'collapse'},
          ),
          [
            thead([
              tr(
                styles: Styles(backgroundColor: Color.value(0xF8FAFC)),
                [
                  _th('Name', align: TextAlign.left),
                  _th('Surname', align: TextAlign.left),
                  _th('Email address', align: TextAlign.left),
                  _th('No. of linked clients', align: TextAlign.center),
                ],
              ),
            ]),
            tbody([
              for (final c in _ctrl.allContacts)
                tr(
                  styles: Styles(
                    border: Border.only(
                      bottom: BorderSide(
                        style: BorderStyle.solid,
                        width: 1.px,
                        color: Color.value(0xE2E8F0),
                      ),
                    ),
                  ),
                  [
                    td(
                      styles: Styles(
                        padding: Padding.all(12.px),
                        color: Color.value(0x0F172A),
                        fontSize: 14.px,
                      ),
                      [.text(c['name'] as String)],
                    ),
                    td(
                      styles: Styles(
                        padding: Padding.all(12.px),
                        color: Color.value(0x0F172A),
                        fontSize: 14.px,
                      ),
                      [.text(c['surname'] as String)],
                    ),
                    td(
                      styles: Styles(
                        padding: Padding.all(12.px),
                        color: Color.value(0x64748B),
                        fontSize: 14.px,
                      ),
                      [.text(c['email'] as String)],
                    ),
                    td(
                      styles: Styles(
                        padding: Padding.all(12.px),
                        color: Color.value(0x64748B),
                        textAlign: TextAlign.center,
                        fontSize: 14.px,
                      ),
                      [.text('${c['client_count']}')],
                    ),
                  ],
                ),
            ]),
          ],
        ),
    ],
  );

  //Style helpers

  Styles _inputStyle({bool hasError = false}) => Styles(
    display: Display.block,
    width: 100.percent,
    padding: Padding.all(10.px),
    border: Border.all(
      style: BorderStyle.solid,
      width: 1.px,
      color: hasError ? Color.value(0xEF4444) : Color.value(0xCBD5E1),
    ),
    radius: BorderRadius.all(Radius.circular(6.px)),
    color: Color.value(0x0F172A),
    fontSize: 14.px,
    backgroundColor: Colors.white,
  );

  static Component _th(String label, {TextAlign align = TextAlign.left}) => th(
    styles: Styles(
      padding: Padding.all(12.px),
      border: Border.only(
        bottom: BorderSide(
          style: BorderStyle.solid,
          width: 2.px,
          color: Color.value(0xE2E8F0),
        ),
      ),
      color: Color.value(0x64748B),
      textAlign: align,
      fontSize: 12.px,
      fontWeight: FontWeight.w600,
      textTransform: TextTransform.upperCase,
      letterSpacing: 0.5.px,
    ),
    [.text(label)],
  );

  Component _field({
    required String label,
    required Component child,
    String? error,
  }) => div(
    styles: Styles(margin: Spacing.only(bottom: 20.px)),
    [
      p(
        styles: Styles(
          margin: Spacing.only(bottom: 6.px),
          color: Color.value(0x374151),
          fontSize: 14.px,
          fontWeight: FontWeight.w500,
        ),
        [.text(label)],
      ),
      child,
      if (error != null)
        span(
          styles: Styles(
            display: Display.block,
            margin: Spacing.only(top: 4.px),
            color: Color.value(0xEF4444),
            fontSize: 12.px,
          ),
          [.text(error)],
        ),
    ],
  );
}
