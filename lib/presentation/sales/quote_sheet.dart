import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:url_launcher/url_launcher.dart';

import '../format/quote_text.dart';
import 'sale_draft.dart';

/// wa.me without a number opens WhatsApp with the text typed in and lets
/// the owner pick the chat. Spaces go as %20: WhatsApp shows a `+` literally.
Uri whatsAppShareUri(String text) =>
    Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

/// An ordinary link opened by the system: no permission needed.
Future<bool> _openWhatsApp(String text) async {
  try {
    return await launchUrl(
      whatsAppShareUri(text),
      mode: LaunchMode.externalApplication,
    );
  } on Exception {
    return false;
  }
}

/// Shows the customer's quote for the current cart and copies it to paste
/// in the chat. The cart stays as is, so if the customer accepts the same
/// order is charged with "Cobrar".
Future<void> showQuoteSheet(BuildContext context, SaleDraftState draft) {
  final text = quoteText(draft, date: draft.date ?? DateTime.now());
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Cotización', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Así lo verá el cliente. No se registra ninguna venta ni '
                  'cambia el stock; los costos que paga la tienda no aparecen.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(text),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('Enviar por WhatsApp'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(sheetContext);
                    final opened = await _openWhatsApp(text);
                    navigator.pop();
                    if (opened) return;
                    // No WhatsApp (or it refused the link): copy so the
                    // quote is not lost and can be pasted anywhere.
                    await Clipboard.setData(ClipboardData(text: text));
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No se pudo abrir WhatsApp; la cotización quedó '
                            'copiada para pegarla en el chat',
                          ),
                        ),
                      );
                  },
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar texto'),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(sheetContext);
                    await Clipboard.setData(ClipboardData(text: text));
                    navigator.pop();
                    messenger
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cotización copiada: pégala en el chat del cliente',
                          ),
                        ),
                      );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
