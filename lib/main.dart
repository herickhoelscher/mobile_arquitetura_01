import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/http_client.dart';
import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/datasources/product_local_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/presentation/pages/product_list_page.dart';
import 'features/products/presentation/viewmodels/product_viewmodel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final httpClient = AppHttpClient();
    final remoteDatasource = ProductRemoteDatasource(httpClient: httpClient);
    final localDatasource = ProductLocalDatasource();
    final repository = ProductRepositoryImpl(
      remoteDatasource: remoteDatasource,
      localDatasource: localDatasource,
    );

    return ChangeNotifierProvider(
      create: (_) => ProductViewModel(repository: repository),
      child: MaterialApp(
        title: 'Mobile Arquitetura 02',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const ProductListPage(),
      ),
    );
  }
}
