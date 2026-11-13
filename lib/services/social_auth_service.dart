import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialAuthAccount {
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? id;
  final bool isGoogle;

  const SocialAuthAccount({
    required this.email,
    this.displayName,
    this.photoUrl,
    this.id,
    required this.isGoogle,
  });
}

/// Google ve Apple ile yerel (native) hesap çekme servisi
class SocialAuthService {
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      try {
        await GoogleSignIn.instance.initialize();
      } catch (e) {
        debugPrint('GoogleSignIn.initialize: $e');
      }
      _initialized = true;
    }
  }

  /// Telefondaki açık Google hesabını doğrudan çeker
  static Future<SocialAuthAccount?> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      // Önceki oturumu temizle
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );

      return SocialAuthAccount(
        email: account.email.trim().toLowerCase(),
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        id: account.id,
        isGoogle: true,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        debugPrint('Kullanıcı Google girişini iptal etti.');
        return null;
      }
      debugPrint('GoogleSignInException: ${e.code} - ${e.description}');
      rethrow;
    } catch (e) {
      debugPrint('SocialAuthService: Google Sign-In native hatası: $e');
      rethrow;
    }
  }

  /// iOS telefondaki Apple Kimliğini doğrudan çeker
  static Future<SocialAuthAccount?> signInWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw UnsupportedError('Apple ile Giriş bu cihazda desteklenmiyor.');
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String? displayName;
      if (credential.givenName != null || credential.familyName != null) {
        displayName = '${credential.givenName ?? ""} ${credential.familyName ?? ""}'.trim();
      }

      final email = credential.email != null && credential.email!.isNotEmpty
          ? credential.email!.trim().toLowerCase()
          : '${credential.userIdentifier}@privaterelay.appleid.com';

      return SocialAuthAccount(
        email: email,
        displayName: displayName,
        id: credential.userIdentifier,
        isGoogle: false,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        debugPrint('Kullanıcı Apple girişini iptal etti.');
        return null;
      }
      debugPrint('SignInWithAppleAuthorizationException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('SocialAuthService: Apple Sign-In native hatası: $e');
      rethrow;
    }
  }
}
