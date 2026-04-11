import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Client _fakePlacesClient() {
  return MockClient((request) async {
    if (request.url.path.endsWith('/autocomplete/json')) {
      return http.Response(
        jsonEncode({
          'status': 'OK',
          'predictions': [
            {'description': 'Test Place', 'place_id': 'place-1'},
          ],
        }),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }

    return http.Response(
      jsonEncode({'status': 'ZERO_RESULTS', 'predictions': []}),
      200,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

class _AutocompleteFlowHarness extends StatefulWidget {
  const _AutocompleteFlowHarness({required this.mode});

  final Mode mode;

  @override
  State<_AutocompleteFlowHarness> createState() =>
      _AutocompleteFlowHarnessState();
}

class _AutocompleteFlowHarnessState extends State<_AutocompleteFlowHarness> {
  Prediction? _selected;

  Future<void> _openAutocomplete(BuildContext context) async {
    final prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: 'test-key',
      mode: widget.mode,
      httpClient: _fakePlacesClient(),
      onError: (_) {},
    );

    if (!mounted) return;

    setState(() {
      _selected = prediction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (innerContext) {
          return Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _openAutocomplete(innerContext),
                  child: const Text('Open autocomplete'),
                ),
                Text(
                  'Selected: ${_selected?.description ?? 'No selection yet'}',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PlacesAutocompleteField renders controller text', (
    tester,
  ) async {
    final controller = TextEditingController(text: '221B Baker Street');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PlacesAutocompleteField(
            apiKey: 'test-key',
            controller: controller,
            inputDecoration: const InputDecoration(),
          ),
        ),
      ),
    );

    expect(find.text('221B Baker Street'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('PlacesAutocompleteFormField syncs controller and validation', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Initial value');
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: PlacesAutocompleteFormField(
              apiKey: 'test-key',
              controller: controller,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Initial value'), findsOneWidget);
    expect(formKey.currentState!.validate(), isTrue);

    controller.text = '';
    await tester.pump();

    expect(formKey.currentState!.validate(), isFalse);

    controller.dispose();
  });

  testWidgets('PlacesAutocomplete overlay flow shows and selects prediction', (
    tester,
  ) async {
    await tester.pumpWidget(const _AutocompleteFlowHarness(mode: Mode.overlay));

    await tester.tap(find.text('Open autocomplete'));
    await tester.pumpAndSettle();

    expect(find.byType(PoweredByGoogleImage), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Test Place'), findsOneWidget);

    await tester.tap(find.text('Test Place'));
    await tester.pumpAndSettle();

    expect(find.text('Selected: Test Place'), findsOneWidget);
  });

  testWidgets(
    'PlacesAutocomplete fullscreen flow uses app bar search field and selects prediction',
    (tester) async {
      await tester.pumpWidget(
        const _AutocompleteFlowHarness(mode: Mode.fullscreen),
      );

      await tester.tap(find.text('Open autocomplete'));
      await tester.pumpAndSettle();

      expect(find.byType(AppBarPlacesAutoCompleteTextField), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);

      await tester.enterText(find.byType(TextField).last, 'Test');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Test Place'), findsOneWidget);

      await tester.tap(find.text('Test Place'));
      await tester.pumpAndSettle();

      expect(find.text('Selected: Test Place'), findsOneWidget);
    },
  );
}
