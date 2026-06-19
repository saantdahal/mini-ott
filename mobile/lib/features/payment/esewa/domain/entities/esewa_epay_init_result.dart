class EsewaEpayInitResult {
  final String paymentId;
  final String totalAmount;
  final String productName;
  final String productCode;
  final String signature;
  final String signedFieldNames;
  final String successUrl;
  final String failureUrl;
  final String gatewayUrl;
  final String gatewayActionUrl;

  const EsewaEpayInitResult({
    required this.paymentId,
    required this.totalAmount,
    required this.productName,
    required this.productCode,
    required this.signature,
    required this.signedFieldNames,
    required this.successUrl,
    required this.failureUrl,
    required this.gatewayUrl,
    required this.gatewayActionUrl,
  });
}
