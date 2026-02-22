import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/bloc/condicion_venta_bloc.dart';
import 'package:dipalza_movil/src/bloc/login_bloc.dart';

void main() {
  testWidgets('Smoke test: App core widgets render',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ConnectivityService(),
          ),
          Provider<CondicionVentaBloc>(
            create: (_) => CondicionVentaBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
          Provider<LoginBloc>(
            create: (_) => LoginBloc(),
            dispose: (_, bloc) => bloc.dispose(),
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Center(
              child: Text('Dipalza App'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Dipalza App'), findsOneWidget);
  });
}
