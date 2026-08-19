String generateInvoiceNo() {
  return "INV-${DateTime.now().millisecondsSinceEpoch}";
}
