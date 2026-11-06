import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../format/quote_text.dart';
import 'sale_draft.dart';

/// Talks to MainActivity.kt: the quote goes straight to the app the owner
/// taps, not to whichever one Android opens wa.me links with.
const shareChannel = MethodChannel('lucky_store/share');

/// The WhatsApp apps offered, in button order.
const whatsAppApps = {
  'com.whatsapp': 'WhatsApp',
  'com.whatsapp.w4b': 'WhatsApp Business',
};

/// Packages of [whatsAppApps] installed on this phone; none if the channel
/// is missing (tests, other platforms).
Future<List<String>> installedWhatsApps() async {
  try {
    final found = await shareChannel.invokeListMethod<String>('installedApps', {
      'packages': whatsAppApps.keys.toList(),
    });
    return found ?? const [];
  } on Exception {
    return const [];
  }
}

Future<bool> _sendTo(String package, String text) async {
  try {
    return await shareChannel.invokeMethod<bool>('sendText', {
          'package': package,
          'text': text,
        }) ??
        false;
  } on Exception {
    return false;
  }
}

/// Shows the customer's quote for the current cart, with a button per
/// WhatsApp installed and one to copy it. The cart stays as is, so if the
/// customer accepts the same order is charged with "Cobrar".
Future<void> showQuoteSheet(BuildContext context, SaleDraftState draft) async {
  final text = quoteText(draft, date: draft.date ?? DateTime.now());
  final apps = await installedWhatsApps();
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);

  void notify(String message) => messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final navigator = Navigator.of(sheetContext);
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
                for (final package in apps) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(whatsAppApps[package]!),
                    onPressed: () async {
                      final sent = await _sendTo(package, text);
                      navigator.pop();
                      if (sent) return;
                      // WhatsApp refused it: copy so the quote is not lost.
                      await Clipboard.setData(ClipboardData(text: text));
                      notify(
                        'No se pudo abrir ${whatsAppApps[package]}; la '
                        'cotización quedó copiada para pegarla en el chat',
                      );
                    },
                  ),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar texto'),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: text));
                    navigator.pop();
                    notify('Cotización copiada: pégala en el chat del cliente');
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
