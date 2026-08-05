import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/monthly_report_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:bricks_application/repositories/worker_payment_repository.dart';
import 'package:rxdart/rxdart.dart';

class MonthlyReportRepository {
  final ProductionRepository productionRepository = ProductionRepository();
  final SaleRepository saleRepository = SaleRepository();
  final PaymentRepository paymentRepository = PaymentRepository();
  final CustomerRepository customerRepository = CustomerRepository();
  final WorkerPaymentRepository workerPaymentRepository =
      WorkerPaymentRepository();

  Stream<MonthlyReportModel> getReport(
    String factoryId,
    DashboardFilter filter,
  ) {
    switch (filter) {
      case DashboardFilter.today:
        return getDailyReport(factoryId);

      case DashboardFilter.thisWeek:
        return getWeeklyReport(factoryId);

      case DashboardFilter.thisMonth:
        return getMonthlyReport(factoryId);

      default:
        return getMonthlyReport(factoryId);
    }
  }

  Stream<MonthlyReportModel> getWeeklyReport(String factoryId) {
    return Rx.combineLatest7<
      double,
      double,
      double,
      double,
      double,
      double,
      double,
      MonthlyReportModel
    >(
      productionRepository.weekProduction(factoryId),
      saleRepository.weekBricksSold(factoryId),
      saleRepository.weekSales(factoryId),
      paymentRepository.weekCollection(factoryId),
      workerPaymentRepository.weekSalaryExpense(factoryId),
      Stream.value(0.0), // Material Expense
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
        return MonthlyReportModel(
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

  Stream<MonthlyReportModel> getDailyReport(String factoryId) {
    return Rx.combineLatest7<
      double,
      double,
      double,
      double,
      double,
      double,
      double,
      MonthlyReportModel
    >(
      productionRepository.todayProduction(factoryId),
      saleRepository.todayBricksSold(factoryId),
      saleRepository.todaySales(factoryId),
      paymentRepository.todayCollection(factoryId),
      workerPaymentRepository.todaySalaryExpense(factoryId),
      Stream.value(0.0), // Material Expense
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
        return MonthlyReportModel(
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

  Stream<MonthlyReportModel> getMonthlyReport(String factoryId) {
    return Rx.combineLatest7<
      double,
      double,
      double,
      double,
      double,
      double,
      double,
      MonthlyReportModel
    >(
      productionRepository.monthProduction(factoryId),
      saleRepository.monthBricksSold(factoryId),
      saleRepository.monthSales(factoryId),
      paymentRepository.monthCollection(factoryId),
      workerPaymentRepository.monthSalaryExpense(factoryId),
      Stream.value(0.0), // Material Expense
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
        return MonthlyReportModel(
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
