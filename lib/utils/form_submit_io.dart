import 'package:http/http.dart' as http;

void submitFormBackground({
  required String actionUrl,
  required Map<String, String> fields,
}) {
  http.post(
    Uri.parse(actionUrl),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Origin': 'https://ibrahimuzuner.github.io',
      'Referer': 'https://ibrahimuzuner.github.io/sinav-kocum-app/',
    },
    body: fields,
  ).catchError((_) => http.Response('', 500));
}
