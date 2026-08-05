import 'package:bricks_application/models/weekly_report_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/repositories/worker_payment_repository.dart';
import 'package:rxdart/rxdart.dart';

class WeeklyReportRepository {
  final ProductionRepository productionRepository = ProductionRepository();
  final SaleRepository saleRepository = SaleRepository();
  final PaymentRepository paymentRepository = PaymentRepository();
  final CustomerRepository customerRepository = CustomerRepository();
  final WorkerPaymentRepository workerPaymentRepository =
      WorkerPaymentRepository();

  Stream<WeeklyReportModel> getWeeklyReport(String factoryId) {
    return Rx.combineLatest7<
      double,
      double,
      double,
      double,
      double,
      double,
      double,
      WeeklyReportModel
    >(
      productionRepository.weekProduction(factoryId),
      saleRepository.weekBricksSold(factoryId),
      saleRepository.weekSales(factoryId),
      paymentRepository.weekCollection(factoryId),
      workerPaymentRepository.weekSalaryExpense(factoryId),
      Stream.value(0.0), // Material Expense (implement later)
      customerRepository.totalPendingAmount(factoryId),
      (
        production,
        bricksSold,
        sales,
        collection,
        salaryExpense,
        materialExpense,
        pending,
      ) {
        return WeeklyReportModel(
          production: production,
          bricksSold: bricksSold,
          sales: sales,
          collection: collection,
          salaryExpense: salaryExpense,
          materialExpense: materialExpense,
          pending: pending,
        );
      },
    );
  }
}
