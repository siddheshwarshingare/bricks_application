import 'package:bricks_application/models/daily_report_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/repositories/worker_payment_repository.dart';
import 'package:rxdart/rxdart.dart';

class DailyReportRepository {
  final ProductionRepository productionRepository = ProductionRepository();
  final SaleRepository saleRepository = SaleRepository();
  final PaymentRepository paymentRepository = PaymentRepository();
  final CustomerRepository customerRepository = CustomerRepository();
  final WorkerPaymentRepository workerPaymentRepository =
      WorkerPaymentRepository();

  Stream<DailyReportModel> getTodayReport(String factoryId) {
    return Rx.combineLatest7<
      double,
      double,
      double,
      double,
      double,
      double,
      double,
      DailyReportModel
    >(
      productionRepository.todayProduction(factoryId),
      saleRepository.todayBricksSold(factoryId),
      saleRepository.todaySales(factoryId),
      paymentRepository.todayCollection(factoryId),
      workerPaymentRepository.todaySalaryExpense(factoryId),
      Stream.value(0.0), // Material expense (for now)
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
        return DailyReportModel(
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
