import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:bcity_web/models/client.dart';

class ClientsPage extends StatelessComponent {
  final List<Client> clients;

  const ClientsPage({super.key, required this.clients});

  @override
  Component build(BuildContext context) {

    return div(
      styles: Styles(padding: Padding.all(24.px)),
      [
        // Header row
        div(
          styles: Styles(
            display: Display.flex,
            margin: Spacing.only(bottom: 24.px),
            justifyContent: JustifyContent.spaceBetween,
            alignItems: AlignItems.center,
          ),
          [
            h2(
              styles: Styles(
                margin: Spacing.zero,
                color: Color.value(0x0F172A),
                fontSize: 20.px,
                fontWeight: FontWeight.w700,
              ),
              [.text('Clients')],
            ),
          ],
        ),

        // Empty state — per spec: no column headings when list is empty
        if (clients.isEmpty)
          p(
            styles: Styles(color: Color.value(0x64748B)),
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
                  styles: Styles(
                    backgroundColor: Color.value(0xF8FAFC),
                  ),
                  [
                    _th('Name',        align: TextAlign.left),
                    _th('Client code', align: TextAlign.left),
                    _th('Contacts',    align: TextAlign.center),
                  ],
                ),
              ]),
              tbody([
                for (final c in clients)
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
                        styles: Styles(padding: Padding.all(12.px), color: Color.value(0x0F172A)),
                        [.text(c.name)],
                      ),
                      td(
                        styles: Styles(
                          padding: Padding.all(12.px),
                          color: Color.value(0x6366F1),
                          fontFamily: FontFamily('monospace'),
                          fontWeight: FontWeight.w600,
                        ),
                        [.text(c.code)],
                      ),
                      td(
                        styles: Styles(
                          padding: Padding.all(12.px),
                          color: Color.value(0x64748B),
                          textAlign: TextAlign.center,
                        ),
                        [.text('${c.contactCount}')],
                      ),
                    ],
                  ),
              ]),
            ],
          ),
      ],
    );
  }


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
}