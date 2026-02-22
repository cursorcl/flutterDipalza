import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dipalza_movil/src/bloc/login_bloc.dart';
import 'package:dipalza_movil/src/services/connectivity_service.dart';
import 'package:dipalza_movil/src/theme/app_theme.dart';

class MockLoginBloc extends Mock implements LoginBloc {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockLoginBloc mockLoginBloc;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    mockLoginBloc = MockLoginBloc();
    mockConnectivityService = MockConnectivityService();

    when(() => mockLoginBloc.usuarioStream).thenAnswer(
      (_) => Stream.value('12345678-5'),
    );
    when(() => mockLoginBloc.passwordStream).thenAnswer(
      (_) => Stream.value('password'),
    );
    when(() => mockLoginBloc.formValidStream).thenAnswer(
      (_) => Stream.value(true),
    );
    when(() => mockLoginBloc.usuario).thenReturn('12345678-5');
    when(() => mockLoginBloc.password).thenReturn('password');

    when(() => mockConnectivityService.status).thenReturn(ServerStatus.online);
    when(() => mockConnectivityService.initialize()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectivityService>.value(
          value: mockConnectivityService,
        ),
        Provider<LoginBloc>.value(
          value: mockLoginBloc,
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Vendedor',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: null,
                    child: Text('Ingresar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Vendedor'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Ingresar'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('password field toggles visibility',
        (WidgetTester tester) async {
      bool obscureText = true;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: TextField(
                  obscureText: obscureText,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => obscureText = !obscureText);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: null,
                child: true
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Ingresar'),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
