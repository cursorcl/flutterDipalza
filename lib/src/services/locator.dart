// lib/src/locator.dart

import 'package:dipalza_movil/src/bloc/condicion_venta_bloc.dart';
import 'package:get_it/get_it.dart';

import 'api_client.dart';

final locator = GetIt.instance;

// Esta función se encargará de registrar todas nuestras dependencias.
void setupLocator() {
  locator.registerLazySingleton<ApiClient>(() => ApiClient());
  // Así se registra un "Lazy Singleton".
  // Significa que la instancia de CondicionVentaBloc se creará
  // solo la primera vez que se solicite.
  locator.registerLazySingleton(() => CondicionVentaBloc());

  // Si en el futuro quieres registrar VentaProvider también, lo harías aquí:
  // locator.registerLazySingleton(() => VentaProvider());
}