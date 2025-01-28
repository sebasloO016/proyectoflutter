//app_routes.dart

import 'package:flutter/material.dart';
import 'package:barcode_scanner_app_new/features/inventory/presentation/dashboard_page.dart';
import 'package:barcode_scanner_app_new/features/auth/presentation/login_page.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';
import 'package:barcode_scanner_app_new/features/inventory/presentation/add_item_page.dart';
import 'package:barcode_scanner_app_new/features/auditoria/presentation/qr_scanner_audit_page.dart';
import 'package:barcode_scanner_app_new/features/auditoria/presentation/qr_scanner_info_page.dart ';
import 'package:barcode_scanner_app_new/features/maintenance/presentation/maintenance_page.dart';
import 'package:barcode_scanner_app_new/features/maintenance/presentation/add_maintenance_page.dart';
import 'package:barcode_scanner_app_new/features/reports/presentation/reports_page.dart';

class AppRoutes {
  static const String dashboard = '/dashboard';
  static const String login = '/login';
  static const String addItem = '/addItem';
  static const String qrScannerAudit = '/qrScannerAudit';
  static const String qrScannerInfo = '/qrScannerInfo';
  static const String maintenance = '/maintenance';
  static const String addMaintenance = '/addMaintenance';
  static const String register = '/reports';
  // Agrega más rutas aquí según sea necesario

  static Map<String, WidgetBuilder> getRoutes(ApiService apiService) {
    return {
      '/addItem': (context) => AddItemPage(apiService: apiService),
      '/dashboard': (context) => DashboardPage(apiService: apiService),
      '/login': (context) => LoginPage(),
      '/qrScannerAudit': (context) =>
          QRScannerAuditPage(apiService: apiService),
      '/qrScannerInfo': (context) => QRScannerInfoPage(apiService: apiService),
      '/maintenance': (context) => MaintenancePage(apiService: apiService),
      '/addMaintenance': (context) =>
          AddMaintenancePage(apiService: apiService),
      '/reports': (context) => ReportDashboard(),
    };
  }
}
