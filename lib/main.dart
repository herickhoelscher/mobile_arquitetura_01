import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_client.dart';
import 'core/session/session_manager.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/datasources/product_local_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/viewmodels/product_viewmodel.dart';
import 'features/splash/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = AppHttpClient();
    final sessionManager = SessionManager();

    final authDatasource = AuthRemoteDatasource(httpClient: httpClient);
    final remoteDatasource = ProductRemoteDatasource(httpClient: httpClient);
    final localDatasource = ProductLocalDatasource();
    final repository = ProductRepositoryImpl(
      remoteDatasource: remoteDatasource,
      localDatasource: localDatasource,
    );

    return MultiProvider(
      providers: [
        Provider<SessionManager>.value(value: sessionManager),
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(
            datasource: authDatasource,
            session: sessionManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductViewModel(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'DummyStore',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
