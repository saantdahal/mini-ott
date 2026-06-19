class KhaltiCheckoutSession {
  final String paymentUrl;
  final String purchaseOrderId;
  final int amountPaisa;
  final String packageName;

  const KhaltiCheckoutSession({
    required this.paymentUrl,
    required this.purchaseOrderId,
    required this.amountPaisa,
    required this.packageName,
  });
}
