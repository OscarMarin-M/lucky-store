import 'package:uuid/uuid.dart';

/// Source of "now"; inject a fixed one in tests.
typedef Clock = DateTime Function();

const _uuid = Uuid();

/// New UUID v4 for entity ids.
String newId() => _uuid.v4();
