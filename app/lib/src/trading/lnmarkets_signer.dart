import 'dart:convert';

import 'package:crypto/crypto.dart';

String signLnMarketsRequest({
  required String timestamp,
  required String method,
  required String path,
  required String params,
  required String secret,
}) {
  final message = buildLnMarketsSignaturePayload(
    timestamp: timestamp,
    method: method,
    path: path,
    params: params,
  );
  final hmac = Hmac(sha256, utf8.encode(secret));
  final digest = hmac.convert(utf8.encode(message));
  return base64.encode(digest.bytes);
}

String buildLnMarketsSignaturePayload({
  required String timestamp,
  required String method,
  required String path,
  required String params,
}) =>
    '$timestamp${method.toLowerCase()}$path$params';
