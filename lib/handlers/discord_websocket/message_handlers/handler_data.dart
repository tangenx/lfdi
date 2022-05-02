import 'dart:convert';

class GatewayHandlerData {
  final Map? data;
  final String? error;
  final int operationCode;

  GatewayHandlerData({
    required this.operationCode,
    required this.error,
    required this.data,
  });

  @override
  String toString() {
    return jsonEncode({
      'operationCode': operationCode,
      'error': error,
      'data': data,
    });
  }
}
