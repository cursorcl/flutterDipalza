import 'dart:convert';

String _padBase64(String s) {
  var out = s.replaceAll('-', '+').replaceAll('_', '/');
  switch (out.length % 4) {
    case 0: break;
    case 2: out += '=='; break;
    case 3: out += '='; break;
    default: throw const FormatException('Base64URL inválido');
  }
  return out;
}

Map<String, dynamic> _jwtPayload(String token) {
  final parts = token.split('.');
  if (parts.length != 3) { throw const FormatException('JWT inválido'); }
  final payload = utf8.decode(base64.decode(_padBase64(parts[1])));
  return json.decode(payload) as Map<String, dynamic>;
}

bool isJwtExpired(String token, {Duration skew = const Duration(seconds: 30)}) {
  try {
    final payload = _jwtPayload(token);
    final exp = payload['exp'];
    if (exp is! int) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry.subtract(skew));
  } catch (_) {
    return true; // ante error, trátalo como vencido
  }
}
