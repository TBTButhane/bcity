import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:bcity_web/controllers/create_client_controller.dart';

@client
class CreateClientView extends StatefulComponent {
  const CreateClientView({super.key});

  @override
  State<CreateClientView> createState() => _CreateClientViewState();
}

class _CreateClientViewState extends State<CreateClientView> {

  final _ctrl = CreateClientController();

  @override
  void initState() {
    super.initState();

    _ctrl.notify = (fn) => setState(fn);

    // Kick off the initial data load
    if (kIsWeb) _ctrl.loadAllClients();
  }



  @override
  Component build(BuildContext context) {
    return div(
      styles: Styles(padding: Padding.all(24.px)),
      [
        // Form section 
        div(
          styles: Styles(maxWidth: 640.px, margin: Spacing.only(bottom: 40.px)),
          [
            h2(
              styles: Styles(
                margin: Spacing.only(bottom: 24.px),
                color: Color.value(0x0F172A),
                fontSize: 20.px,
                fontWeight: FontWeight.w700,
              ),
              [.text('Create Client')],
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
                _tabButton('General',    0),
                _tabButton('Contact(s)', 1),
              ],
            ),

            if (_ctrl.activeTab == 0) _buildGeneralTab(),
            if (_ctrl.activeTab == 1) _buildContactsTab(),
          ],
        ),

        // All-clients list below the form 
        _buildClientsList(),
      ],
    );
  }

  // Tab button 

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

  // General tab

  Component _buildGeneralTab() => div([
    _field(
      label: 'Name *',
      child: input(
        type: InputType.text,
        value: _ctrl.name,
        attributes: {'placeholder': 'e.g. First National Bank'},
        onInput: (v) => _ctrl.onNameChanged(v.toString()),
        styles: _inputStyle(hasError: _ctrl.nameError != null),
      ),
      error: _ctrl.nameError,
    ),

    // Client code — only shown after save
    if (_ctrl.generatedCode != null)
      _field(
        label: 'Client code',
        child: input(
          type: InputType.text,
          value: _ctrl.generatedCode!,
          attributes: {'readonly': 'readonly'},
          styles: Styles(
            display: Display.block,
            width: 100.percent,
            padding: Padding.all(10.px),
            border: Border.all(
              style: BorderStyle.solid,
              width: 1.px,
              color: Color.value(0xCBD5E1),
            ),
            radius: BorderRadius.all(Radius.circular(6.px)),
            color: Color.value(0x6366F1),
            fontFamily: FontFamily('monospace'),
            fontSize: 14.px,
            fontWeight: FontWeight.w600,
            backgroundColor: Color.value(0xF8FAFC),
          ),
        ),
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
        [.text('✓ Client created — code: ${_ctrl.generatedCode}')],
      ),

    // Buttons
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
              backgroundColor: _ctrl.isLoading
                  ? Color.value(0x94A3B8)
                  : Color.value(0x6366F1),
            ),
            [.text(_ctrl.isLoading ? 'Saving...' : 'Save Client')],
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

  // Contacts tab 
  Component _buildContactsTab() {
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
        [.text('Save the client first before linking contacts.')],
      );
    }

    if (_ctrl.contactsLoading) {
      return p(
        styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
        [.text('Loading...')],
      );
    }

    if (_ctrl.contactsError != null) {
      return p(
        styles: Styles(color: Color.value(0xDC2626), fontSize: 14.px),
        [.text(_ctrl.contactsError!)],
      );
    }

    return div([
      // Linked contacts table
      if (_ctrl.linkedContacts.isEmpty)
        p(
          styles: Styles(
            margin: Spacing.only(bottom: 24.px),
            color: Color.value(0x64748B),
            fontSize: 14.px,
          ),
          [.text('No contacts found.')],
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
                     
                      _th('Full Name',      align: TextAlign.left),
                      _th('Email address',  align: TextAlign.left),
                      _th('',               align: TextAlign.left),
                    ],
                  ),
                ]),
                tbody([
                  for (final c in _ctrl.linkedContacts)
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
                          [.text('${c['surname']} ${c['name']}')],
                        ),
                        td(
                          styles: Styles(
                            padding: Padding.all(12.px),
                            color: Color.value(0x64748B),
                            fontSize: 14.px,
                          ),
                          [.text(c['email'] as String)],
                        ),

                        // Unlink
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
                                        _ctrl.unlinkContact(c['id'] as int);
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

      // Link an existing contact
      if (_ctrl.availableClients.isNotEmpty) ...[
        p(
          styles: Styles(
            margin: Spacing.only(bottom: 8.px),
            color: Color.value(0x0F172A),
            fontSize: 14.px,
            fontWeight: FontWeight.w600,
          ),
          [.text('Link an existing contact')],
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
                onClick: _ctrl.linking
                    ? null
                    : () => _ctrl.linkContact(c['id'] as int),
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
              
                [.text('+ ${c['surname']} ${c['name']}')],
              ),
          ],
        ),
      ],

      if (_ctrl.availableClients.isEmpty && _ctrl.linkedContacts.isNotEmpty)
        p(
          styles: Styles(
            margin: Spacing.only(top: 16.px),
            color: Color.value(0x94A3B8),
            fontSize: 13.px,
          ),
          [.text('All existing contacts are already linked.')],
        ),
    ]);
  }

  //All-clients list

  Component _buildClientsList() => div(
    styles: Styles(margin: Spacing.only(top: 8.px)),
    [
      h3(
        styles: Styles(
          margin: Spacing.only(bottom: 16.px),
          color: Color.value(0x0F172A),
          fontSize: 16.px,
          fontWeight: FontWeight.w700,
        ),
        [.text('All Clients')],
      ),

      if (_ctrl.listLoading)
        p(
          styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
          [.text('Loading clients...')],
        )
      else if (_ctrl.listError != null)
        p(
          styles: Styles(color: Color.value(0xDC2626), fontSize: 14.px),
          [.text(_ctrl.listError!)],
        )
      else if (_ctrl.allClients.isEmpty)
        p(
          styles: Styles(color: Color.value(0x64748B), fontSize: 14.px),
          [.text('No client(s) found.')],
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
                  _th('Name',        align: TextAlign.left),
                  _th('Client code', align: TextAlign.left),
                  _th('Contacts',    align: TextAlign.center),
                ],
              ),
            ]),
            tbody([
              for (final c in _ctrl.allClients)
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
                    td(
                      styles: Styles(
                        padding: Padding.all(12.px),
                        color: Color.value(0x64748B),
                        textAlign: TextAlign.center,
                        fontSize: 14.px,
                      ),
                      [.text('${c['contact_count']}')],
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
      color: hasError
          ? Color.value(0xEF4444)
          : Color.value(0xCBD5E1),
    ),
    radius: BorderRadius.all(Radius.circular(6.px)),
    color: Color.value(0x0F172A),
    fontSize: 14.px,
    backgroundColor: Colors.white,
  );

  static Component _th(String label, {TextAlign align = TextAlign.left}) =>
      th(
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
  }) =>
      div(
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