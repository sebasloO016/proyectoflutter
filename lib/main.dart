import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scanner_app_new/features/auth/presentation/auth_controller.dart';
import 'package:barcode_scanner_app_new/features/auth/presentation/login_page.dart';
import 'package:barcode_scanner_app_new/features/auth/presentation/register_page.dart';
import 'package:barcode_scanner_app_new/features/inventory/presentation/dashboard_page.dart';
import 'package:barcode_scanner_app_new/features/inventory/presentation/add_item_page.dart';
import 'package:barcode_scanner_app_new/core/network/api_client.dart';
import 'package:barcode_scanner_app_new/features/auth/data/auth_repository.dart';
import 'package:barcode_scanner_app_new/core/network/api_service.dart';
import 'package:barcode_scanner_app_new/features/auditoria/presentation/qr_scanner_info_page.dart';
import 'package:barcode_scanner_app_new/features/auditoria/presentation/qr_scanner_audit_page.dart';
import 'package:barcode_scanner_app_new/features/maintenance/presentation/maintenance_page.dart';
import 'package:barcode_scanner_app_new/features/maintenance/presentation/add_maintenance_page.dart';
import 'package:barcode_scanner_app_new/features/reports/presentation/reports_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(
      baseUrl:
          'http://192.168.137.1:5000'); //se cambia segun la ip, en esta linea de codigo se da acceso a la api
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(baseUrl: 'http://192.168.137.1:5000'),
        ),
        ProxyProvider<ApiClient, AuthRepository>(
          update: (_, apiClient, __) => AuthRepository(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(
              authRepository: AuthRepository(
                  apiClient: ApiClient(baseUrl: 'http://192.168.137.1:5000'))),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/dashboard': (context) => DashboardPage(apiService: apiService),
          '/addItem': (context) => AddItemPage(apiService: apiService),
          '/qrScannerAudit': (context) =>
              QRScannerAuditPage(apiService: apiService),
          '/qrScannerInfo': (context) =>
              QRScannerInfoPage(apiService: apiService),
          '/maintenance': (context) => MaintenancePage(apiService: apiService),
          '/addMaintenance': (context) =>
              AddMaintenancePage(apiService: apiService),
          '/reports': (context) => ReportDashboard(),
        },
      ),
    );
  }
}



/**


/**BARCODE_SCANNER_APP_NEW
 * lib/
├── main.dart
├── core/
│   ├── constants/
│   │   └── app_colors.dart
│   │   └── app_styles.dart
│   │   └── app_strings.dart
│   ├── utils/
│   │   └── qr_scanner_util.dart
│   │   └── validators.dart
│   └── network/
│       ├── api_client.dart
│       └── api_endpoints.dart
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── auth_model.dart
│   │   └── presentation/
│   │       ├── login_page.dart
│   │       └── auth_controller.dart
│   ├── inventory/
│   │   ├── data/
│   │   │   └── inventory_repository.dart
│   │   ├── domain/
│   │   │   └── inventory_model.dart
│   │   └── presentation/
│   │       ├── inventory_page.dart
│   │       ├── add_item_page.dart
│   │       └── inventory_controller.dart
│   ├── maintenance/
│   │   ├── data/
│   │   │   └── maintenance_repository.dart
│   │   ├── domain/
│   │   │   └── maintenance_model.dart
│   │   └── presentation/
│   │       ├── maintenance_page.dart
│   │       └── maintenance_controller.dart
│   ├── notifications/
│   │   ├── data/
│   │   │   └── notifications_repository.dart
│   │   ├── domain/
│   │   │   └── notifications_model.dart
│   │   └── presentation/
│   │       ├── notifications_page.dart
│   │       └── notifications_controller.dart
│   └── reports/
│       ├── data/
│       │   └── reports_repository.dart
│       ├── domain/
│       │   └── reports_model.dart
│       └── presentation/
│           ├── reports_page.dart
│           └── reports_controller.dart
├── widgets/
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── error_widget.dart
└── config/
    ├── app_routes.dart
    ├── app_theme.dart
    └── dependency_injection.dart
**/*/