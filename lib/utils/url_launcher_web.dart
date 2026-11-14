// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

void launchUrlString(String url) {
  web.window.open(url, '_blank');
}
