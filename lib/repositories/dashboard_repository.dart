import 'package:bricks_application/enums/dashboard_filter.dart';
import 'package:bricks_application/models/dashboard_model.dart';
import 'package:bricks_application/repositories/customer_repository.dart';
import 'package:bricks_application/repositories/payment_repository.dart';
import 'package:bricks_application/repositories/production_repository.dart';
import 'package:bricks_application/repositories/sale_repository.dart';
import 'package:rxdart/rxdart.dart';

class DashboardRepository {
  final ProductionRepository productionRepository = ProductionRepository();
  final SaleRepository saleRepository = SaleRepository();
  final PaymentRepository paymentRepository = PaymentRepository();
  final CustomerRepository customerRepository = CustomerRepository();
  late Stream<double> pendingStream;
  Stream<DashboardModel> getDashboardData(
    String factoryId,
    DashboardFilter filter,
  ) {
    late Stream<double> productionStream;
    late Stream<double> salesStream;
    late Stream<double> collectionStream;
    late Stream<double> salesQuantityStream;

    switch (filter) {
      case DashboardFilter.today:
        productionStream = productionRepository.todayProduction(factoryId);

        salesStream = saleRepository.todaySales(factoryId);

        collectionStream = paymentRepository.todayCollection(factoryId);

        salesQuantityStream = saleRepository.todayBricksSold(factoryId);

        pendingStream = saleRepository.todayPending(factoryId);

        break;

      case DashboardFilter.thisWeek:
        productionStream = productionRepository.weekProduction(factoryId);

        salesStream = saleRepository.weekSales(factoryId);

        collectionStream = paymentRepository.weekCollection(factoryId);

        salesQuantityStream = saleRepository.weekBricksSold(factoryId);

        pendingStream = saleRepository.weekPending(factoryId);

        break;

      case DashboardFilter.thisMonth:
        productionStream = productionRepository.monthProduction(factoryId);

        salesStream = saleRepository.monthSales(factoryId);

        collectionStream = paymentRepository.monthCollection(factoryId);

        salesQuantityStream = saleRepository.monthBricksSold(factoryId);

        pendingStream = saleRepository.monthPending(factoryId);

        break;

      case DashboardFilter.yesterday:
      case DashboardFilter.lastWeek:
      case DashboardFilter.lastMonth:
      case DashboardFilter.last3Months:
      case DashboardFilter.last6Months:
      case DashboardFilter.thisYear:
      case DashboardFilter.custom:
        productionStream = productionRepository.monthProduction(factoryId);

        salesStream = saleRepository.monthSales(factoryId);

        collectionStream = paymentRepository.monthCollection(factoryId);

        salesQuantityStream = saleRepository.monthBricksSold(factoryId);

        pendingStream = saleRepository.monthPending(factoryId);

        break;
    }
    //final pendingStream = customerRepository.totalPendingAmount(factoryId);

    final customerStream = customerRepository.totalCustomers(factoryId);

    return Rx.combineLatest6<
      double,
      double,
      double,
      double,
      double,
      int,
      DashboardModel
    >(
      productionStream,
      salesStream,
      collectionStream,
      salesQuantityStream,
      pendingStream,
      customerStream,
      (production, sales, collection, salesQuantity, pending, customers) {
        return DashboardModel(
          production: production,
          sales: sales,
          salesQuantity: salesQuantity,
          collection: collection,
          pending: pending,
          customers: customers,
          workers: 0,
          materials: 0,
        );
      },
    );
  }
}
