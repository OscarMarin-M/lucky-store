import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Height shared by the stepper and the text fields next to it, so a row of
/// "quantity + price" lines up.
const kFieldHeight = 56.0;

/// `[ − | 3 | + ]` in one rounded box that looks like the other fields.
/// Never goes below 1; typing an empty/0 value reports 0 so the caller can
/// flag the line as invalid.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  int get _value => int.tryParse(controller.text) ?? 0;

  void _step(int delta) {
    final next = (_value + delta) < 1 ? 1 : _value + delta;
    controller.text = '$next';
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill =
        theme.inputDecorationTheme.fillColor ??
        theme.colorScheme.surfaceContainerHighest;

    return Container(
      height: kFieldHeight,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Menos',
            icon: const Icon(Icons.remove),
            onPressed: () => _step(-1),
          ),
          SizedBox(
            width: 44,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
              decoration: const InputDecoration.collapsed(hintText: '0')
                  .copyWith(filled: false),
            ),
          ),
          IconButton(
            tooltip: 'Más',
            icon: const Icon(Icons.add),
            onPressed: () => _step(1),
          ),
        ],
      ),
    );
  }
}
