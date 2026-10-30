/// `29/10/2026`
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// `14:05`
String formatTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];

/// Day header of the history: `Hoy`, `Ayer`, else `mié 28/10/2026`.
String formatDayLabel(DateTime day, DateTime now) {
  final d = DateTime(day.year, day.month, day.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Hoy';
  if (diff == 1) return 'Ayer';
  return '${_weekdays[d.weekday - 1]} ${formatDate(d)}';
}
