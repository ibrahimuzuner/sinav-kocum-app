import 'url_launcher_stub.dart'
    if (dart.library.js_interop) 'url_launcher_web.dart'
    if (dart.library.io) 'url_launcher_io.dart';

class UrlLauncherHelper {
  static void launch(String url) {
    launchUrlString(url);
  }

  static void openMail({
    required String to,
    String? subject,
    String? body,
  }) {
    final query = <String, String>{};
    if (subject != null && subject.isNotEmpty) query['subject'] = subject;
    if (body != null && body.isNotEmpty) query['body'] = body;
    final uri = Uri(scheme: 'mailto', path: to, queryParameters: query.isNotEmpty ? query : null);
    launchUrlString(uri.toString());
  }

  static void openGmailWeb({
    required String to,
    String? subject,
    String? body,
  }) {
    final su = subject != null ? Uri.encodeComponent(subject) : '';
    final b = body != null ? Uri.encodeComponent(body) : '';
    final url = 'https://mail.google.com/mail/?view=cm&fs=1&to=$to&su=$su&body=$b';
    launchUrlString(url);
  }
}
