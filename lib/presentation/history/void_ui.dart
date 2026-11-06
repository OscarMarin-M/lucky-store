import 'package:flutter/material.dart';

import '../../core/errors/domain_exception.dart';
import '../format/date_format.dart';
import '../theme/app_theme.dart';

/// What voiding does to each kind of document, told before confirming.
enum VoidKind {
  sale(
    'venta',
    'Sus productos vuelven al stock y deja de contar en ventas y ganancias.',
  ),
  purchase(
    'compra',
    'Sus unidades salen del stock y el costo promedio se recalcula sin ella.',
  ),
  writeOff('baja', 'Las unidades vuelven al stock y la pérdida deja de contar.');

  const VoidKind(this.noun, this.effect);

  final String noun;
  final String effect;
}

/// Asks to confirm voiding (with an optional reason and any [warnings]),
/// runs [onVoid] and tells how it went. Returns true when it was voided, so
/// the caller can close the detail.
Future<bool> confirmAndVoid(
  BuildContext context, {
  required VoidKind kind,
  List<String> warnings = const [],
  required Future<void> Function(String reason) onVoid,
}) async {
  final reason = await showDialog<String>(
    context: context,
    builder: (_) => _VoidDialog(kind: kind, warnings: warnings),
  );
  if (reason == null || !context.mounted) return false;
  final messenger = ScaffoldMessenger.of(context);
  try {
    await onVoid(reason);
  } on DomainException catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
    return false;
  }
  messenger.showSnackBar(
    SnackBar(content: Text('${_capitalized(kind.noun)} anulada')),
  );
  return true;
}

String _capitalized(String s) => s[0].toUpperCase() + s.substring(1);

/// Pops the typed reason ('' when left blank) or null when cancelled.
class _VoidDialog extends StatefulWidget {
  const _VoidDialog({required this.kind, required this.warnings});

  final VoidKind kind;
  final List<String> warnings;

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AlertDialog(
      title: Text('¿Anular esta ${widget.kind.noun}?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.kind.effect),
            const SizedBox(height: 6),
            Text(
              'Queda en el Historial, tachada, con quién la anuló.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            for (final w in widget.warnings) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, color: scheme.loss),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(w, style: TextStyle(color: scheme.loss)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _reason,
              autofocus: false,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                hintText: 'Ej: precio mal cargado',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(_reason.text),
          child: const Text('Anular'),
        ),
      ],
    );
  }
}

/// Top of a voided document's detail: when, by whom and why.
class VoidedBanner extends StatelessWidget {
  const VoidedBanner({
    super.key,
    required this.voidedAt,
    this.voidedBy,
    this.reason,
  });

  final DateTime voidedAt;
  final String? voidedBy;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.block, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anulada · no cuenta en stock ni ganancias',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    '${formatDate(voidedAt)} ${formatTime(voidedAt)}',
                    if (voidedBy != null) 'por $voidedBy',
                  ].join(' · '),
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
                if (reason != null)
                  Text(
                    'Motivo: $reason',
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
