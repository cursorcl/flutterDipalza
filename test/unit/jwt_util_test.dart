import 'package:flutter_test/flutter_test.dart';
import 'package:dipalza_movil/src/utils/jwt_util.dart';
import 'dart:convert';

void main() {
  group('JWT Utils', () {
    String createToken(DateTime expiry) {
      final header = base64Encode(utf8.encode('{"alg":"HS256"}'));
      final payload = base64Encode(
          utf8.encode('{"exp":${expiry.millisecondsSinceEpoch ~/ 1000}}'));
      final signature = base64Encode(utf8.encode('signature'));
      return '$header.$payload.$signature';
    }

    test('returns true for expired token', () {
      final expiredToken =
          createToken(DateTime.now().subtract(const Duration(hours: 1)));
      expect(isJwtExpired(expiredToken), true);
    });

    test('returns false for valid token', () {
      final validToken =
          createToken(DateTime.now().add(const Duration(hours: 1)));
      expect(isJwtExpired(validToken), false);
    });

    test('returns true for invalid token format', () {
      expect(isJwtExpired('invalid'), true);
      expect(isJwtExpired('only.two.parts'), true);
      expect(isJwtExpired(''), true);
    });

    test('returns true when exp is missing', () {
      final header = base64Encode(utf8.encode('{"alg":"HS256"}'));
      final payload = base64Encode(utf8.encode('{}'));
      final signature = base64Encode(utf8.encode('signature'));
      final token = '$header.$payload.$signature';
      expect(isJwtExpired(token), true);
    });

    test('handles skew parameter', () {
      final almostExpired =
          createToken(DateTime.now().add(const Duration(seconds: 20)));
      expect(
          isJwtExpired(almostExpired, skew: const Duration(seconds: 30)), true);
      expect(isJwtExpired(almostExpired, skew: const Duration(seconds: 10)),
          false);
    });
  });
}
