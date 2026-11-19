/// Uygulama genelinde standart ve sıkı e-posta doğrulama sınıfı.
/// `@gmail.com` gibi kullanıcı adı girilmemiş veya sahte e-posta formatlarını engeller.
class EmailValidator {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// E-posta formatının geçerli ve gerçek bir yapıya sahip olup olmadığını doğrular
  static bool isValid(String? email) {
    if (email == null) return false;
    final trimmed = email.trim().toLowerCase();

    // Minimum 'a@b.co' uzunluğu 6 karakterdir
    if (trimmed.length < 6) return false;

    // Başında ya da sonunda @ olamaz (@gmail.com veya user@ gibi)
    if (trimmed.startsWith('@') || trimmed.endsWith('@')) return false;

    // Tam olarak bir adet @ işareti olmalıdır
    final atCount = '@'.allMatches(trimmed).length;
    if (atCount != 1) return false;

    // İki nokta ardışık olamaz (..)
    if (trimmed.contains('..')) return false;

    final parts = trimmed.split('@');
    if (parts.length != 2) return false;

    final localPart = parts[0];
    final domainPart = parts[1];

    if (localPart.isEmpty || domainPart.isEmpty) return false;

    // Kullanıcı adı kısmı nokta ile başlayamaz/bitemez
    if (localPart.startsWith('.') || localPart.endsWith('.')) return false;

    // Alan adı kısmı nokta veya tire ile başlayamaz/bitemez
    if (domainPart.startsWith('.') || domainPart.endsWith('.')) return false;
    if (domainPart.startsWith('-') || domainPart.endsWith('-')) return false;

    // Alan adında en az bir nokta olmalıdır (.com, .net vb.)
    if (!domainPart.contains('.')) return false;

    final domainSegments = domainPart.split('.');
    if (domainSegments.any((seg) => seg.isEmpty)) return false;

    // TLD (en sondaki uzantı örn: com, tr, net) en az 2 harfli ve sadece harflerden oluşmalıdır
    final tld = domainSegments.last;
    if (tld.length < 2 || !RegExp(r'^[a-zA-Z]+$').hasMatch(tld)) return false;

    // Genel regex uyumu
    if (!_emailRegExp.hasMatch(trimmed)) return false;

    return true;
  }

  /// Form alanları için FormFieldValidator
  static String? validate(String? value, {String? customEmptyMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customEmptyMessage ?? 'Lütfen e-posta adresinizi girin';
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('@')) {
      return 'Lütfen e-postanızın kullanıcı adını yazın (örn: ad.soyad$trimmed)';
    }
    if (!isValid(trimmed)) {
      return 'Geçerli ve gerçek bir e-posta adresi girin (örn: ad@gmail.com)';
    }
    return null;
  }
}
