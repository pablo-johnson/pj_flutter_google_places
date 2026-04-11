import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.BaseClient _fakePlacesClient() {
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

http.BaseClient _throwingPlacesClient() {
  return MockClient((request) {
    throw Exception('network down');
  });
}

http.BaseClient _staleAwarePlacesClient() {
  return MockClient((request) async {
    final input = request.url.queryParameters['input'];
    if (input == 'A') {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      return http.Response(
        jsonEncode({
          'status': 'OK',
          'predictions': [
            {'description': 'Alpha Place', 'place_id': 'place-alpha'},
          ],
        }),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    }

    return http.Response(
      jsonEncode({
        'status': 'OK',
        'predictions': [
          {'description': 'Beta Place', 'place_id': 'place-beta'},
        ],
      }),
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

class _AutocompleteErrorHarness extends StatefulWidget {
  const _AutocompleteErrorHarness();

  @override
  State<_AutocompleteErrorHarness> createState() =>
      _AutocompleteErrorHarnessState();
}

class _AutocompleteErrorHarnessState extends State<_AutocompleteErrorHarness> {
  String _error = 'No error';

  Future<void> _openAutocomplete(BuildContext context) async {
    await PlacesAutocomplete.show(
      context: context,
      apiKey: 'test-key',
      mode: Mode.overlay,
      httpClient: _throwingPlacesClient(),
      onError: (response) {
        if (!mounted) return;
        setState(() {
          _error = '${response.status.name}: ${response.errorMessage}';
        });
      },
    );
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
                Text(_error),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlacesAutocompleteFieldHarness extends StatefulWidget {
  const _PlacesAutocompleteFieldHarness();

  @override
  State<_PlacesAutocompleteFieldHarness> createState() =>
      _PlacesAutocompleteFieldHarnessState();
}

class _PlacesAutocompleteFieldHarnessState
    extends State<_PlacesAutocompleteFieldHarness> {
  final TextEditingController _controller = TextEditingController();
  String _selected = 'No selection yet';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            PlacesAutocompleteField(
              apiKey: 'test-key',
              controller: _controller,
              httpClient: _fakePlacesClient(),
              onSelected: (prediction) {
                setState(() {
                  _selected = prediction.description ?? 'Missing description';
                });
              },
            ),
            Text('Selected: $_selected'),
          ],
        ),
      ),
    );
  }
}

class _StaleResponseHarness extends StatelessWidget {
  const _StaleResponseHarness();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: PlacesAutocompleteWidget(
          apiKey: 'test-key',
          mode: Mode.overlay,
          httpClient: _staleAwarePlacesClient(),
        ),
      ),
    );
  }
}

class _ControllerSwitchingFieldHarness extends StatefulWidget {
  const _ControllerSwitchingFieldHarness();

  @override
  State<_ControllerSwitchingFieldHarness> createState() =>
      _ControllerSwitchingFieldHarnessState();
}

class _ControllerSwitchingFieldHarnessState
    extends State<_ControllerSwitchingFieldHarness> {
  TextEditingController? _controller = TextEditingController(
    text: 'External value',
  );

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _removeController() {
    final controller = _controller;
    setState(() {
      _controller = null;
    });
    controller?.dispose();
  }

  void _replaceController() {
    final previous = _controller;
    final replacement = TextEditingController(text: 'Replacement seed');
    setState(() {
      _controller = replacement;
    });
    previous?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            ElevatedButton(
              onPressed: _removeController,
              child: const Text('Remove controller'),
            ),
            ElevatedButton(
              onPressed: _replaceController,
              child: const Text('Replace controller'),
            ),
            PlacesAutocompleteField(
              apiKey: 'test-key',
              controller: _controller,
            ),
          ],
        ),
      ),
    );
  }
}

class _FormResetHarness extends StatefulWidget {
  const _FormResetHarness({required this.withController});

  final bool withController;

  @override
  State<_FormResetHarness> createState() => _FormResetHarnessState();
}

class _FormResetHarnessState extends State<_FormResetHarness> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'Initial external');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _mutateValue() {
    if (widget.withController) {
      _controller.text = 'Changed external';
    }
  }

  void _resetForm() {
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _mutateValue,
                child: const Text('Mutate value'),
              ),
              ElevatedButton(
                onPressed: _resetForm,
                child: const Text('Reset form'),
              ),
              PlacesAutocompleteFormField(
                apiKey: 'test-key',
                controller: widget.withController ? _controller : null,
                httpClient: _fakePlacesClient(),
                initialValue: widget.withController ? null : 'Initial internal',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
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

  testWidgets('PlacesAutocompleteField updates controller and onSelected', (
    tester,
  ) async {
    await tester.pumpWidget(const _PlacesAutocompleteFieldHarness());

    await tester.tap(find.byType(PlacesAutocompleteField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Test Place'));
    await tester.pumpAndSettle();

    expect(find.text('Test Place'), findsOneWidget);
    expect(find.text('Selected: Test Place'), findsOneWidget);
  });

  testWidgets('PlacesAutocomplete reports transport failures via onError', (
    tester,
  ) async {
    await tester.pumpWidget(const _AutocompleteErrorHarness());

    await tester.tap(find.text('Open autocomplete'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.textContaining('unknownError:'), findsOneWidget);
    expect(find.textContaining('network down'), findsOneWidget);
  });

  testWidgets('PlacesAutocomplete ignores stale responses', (tester) async {
    await tester.pumpWidget(const _StaleResponseHarness());

    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump(const Duration(milliseconds: 350));

    await tester.enterText(find.byType(TextField), 'AB');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.text('Beta Place'), findsOneWidget);
    expect(find.text('Alpha Place'), findsNothing);
  });

  testWidgets(
    'PlacesAutocompleteField preserves text when switching from external to internal controller',
    (tester) async {
      await tester.pumpWidget(const _ControllerSwitchingFieldHarness());

      expect(find.text('External value'), findsOneWidget);

      await tester.tap(find.text('Remove controller'));
      await tester.pump();

      expect(find.text('External value'), findsOneWidget);
      expect(find.text('Search'), findsNothing);
    },
  );

  testWidgets(
    'PlacesAutocompleteField preserves text when replacing the external controller',
    (tester) async {
      await tester.pumpWidget(const _ControllerSwitchingFieldHarness());

      expect(find.text('External value'), findsOneWidget);

      await tester.tap(find.text('Replace controller'));
      await tester.pump();

      expect(find.text('External value'), findsOneWidget);
      expect(find.text('Replacement seed'), findsNothing);
    },
  );

  testWidgets(
    'PlacesAutocompleteFormField reset restores the initial internal value',
    (tester) async {
      await tester.pumpWidget(const _FormResetHarness(withController: false));

      expect(find.text('Initial internal'), findsOneWidget);

      await tester.tap(find.byType(PlacesAutocompleteField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Place'));
      await tester.pumpAndSettle();

      expect(find.text('Test Place'), findsOneWidget);

      await tester.tap(find.text('Reset form'));
      await tester.pump();

      expect(find.text('Initial internal'), findsOneWidget);
      expect(find.text('Test Place'), findsNothing);
    },
  );

  testWidgets(
    'PlacesAutocompleteFormField reset restores the external controller value',
    (tester) async {
      await tester.pumpWidget(const _FormResetHarness(withController: true));

      expect(find.text('Initial external'), findsOneWidget);

      await tester.tap(find.text('Mutate value'));
      await tester.pump();

      expect(find.text('Changed external'), findsOneWidget);

      await tester.tap(find.text('Reset form'));
      await tester.pump();

      expect(find.text('Initial external'), findsOneWidget);
      expect(find.text('Changed external'), findsNothing);
    },
  );

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
