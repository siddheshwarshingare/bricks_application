import 'package:bricks_application/models/ledger_model.dart';
import 'package:bricks_application/models/payment_model.dart';
import 'package:bricks_application/models/sale_model.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';

class LedgerRepository {
  final SaleRepository saleRepository = SaleRepository();
  final PaymentRepository paymentRepository = PaymentRepository();

  /// Customer Ledger
  Stream<List<LedgerModel>> getCustomerLedger(
    String factoryId,
    String customerId,
    double openingBalance,
  ) {
    return saleRepository.getCustomerSales(factoryId, customerId).asyncMap((
      sales,
    ) async {
      final payments = await paymentRepository
          .getCustomerPayments(factoryId, customerId)
          .first;

      List<LedgerModel> ledger = [];

      /// Convert Sales -> Ledger
      for (SaleModel sale in sales) {
        ledger.add(
          LedgerModel(
            id: sale.id,
            type: "Sale",
            date: sale.saleDate.toDate(),
            debit: sale.totalAmount,
            credit: 0,
            balance: 0,
            description: sale.brickType,
          ),
        );
      }

      /// Convert Payments -> Ledger
      for (PaymentModel payment in payments) {
        ledger.add(
          LedgerModel(
            id: payment.id,
            type: "Payment",
            date: payment.paymentDate.toDate(),
            debit: 0,
            credit: payment.amount,
            balance: 0,
            description: payment.paymentMethod,
          ),
        );
      }

      /// Sort by Date
      ledger.sort((a, b) => a.date.compareTo(b.date));

      /// Calculate Running Balance
      double balance = openingBalance;

      for (int i = 0; i < ledger.length; i++) {
        if (ledger[i].type == "Sale") {
          balance += ledger[i].debit;
        } else {
          balance -= ledger[i].credit;
        }

        ledger[i] = ledger[i].copyWith(balance: balance);
      }

      return ledger;
    });
  }
}
