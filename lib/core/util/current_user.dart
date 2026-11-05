/// Who is using the app right now (the email of the signed-in account), read
/// when a document is registered so it records its author. Null without an
/// account. Inject a fixed one in tests.
typedef CurrentUser = String? Function();

String? noUser() => null;
