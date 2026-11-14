import 'form_submit_stub.dart'
    if (dart.library.js_interop) 'form_submit_web.dart'
    if (dart.library.io) 'form_submit_io.dart';

class FormSubmitHelper {
  static void submit({
    required String actionUrl,
    required Map<String, String> fields,
  }) {
    submitFormBackground(actionUrl: actionUrl, fields: fields);
  }
}
