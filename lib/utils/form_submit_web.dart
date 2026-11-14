// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

void submitFormBackground({
  required String actionUrl,
  required Map<String, String> fields,
}) {
  try {
    const iframeId = 'hidden_form_submit_iframe';
    var iframe = web.document.getElementById(iframeId) as web.HTMLIFrameElement?;
    if (iframe == null) {
      iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.id = iframeId;
      iframe.name = iframeId;
      iframe.style.display = 'none';
      web.document.body?.appendChild(iframe);
    }

    final form = web.document.createElement('form') as web.HTMLFormElement;
    form.action = actionUrl;
    form.method = 'POST';
    form.target = iframeId;
    form.style.display = 'none';

    fields.forEach((k, v) {
      final input = web.document.createElement('input') as web.HTMLInputElement;
      input.type = 'hidden';
      input.name = k;
      input.value = v;
      form.appendChild(input);
    });

    web.document.body?.appendChild(form);
    form.submit();
  } catch (_) {}
}
