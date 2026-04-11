import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

const kGoogleApiKey = "API_KEY";

void main() {
  runApp(const RoutesWidget());
}

final customTheme = ThemeData(
  brightness: Brightness.dark,
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4.00)),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12.50, horizontal: 10.00),
  ),
);

class RoutesWidget extends StatelessWidget {
  const RoutesWidget({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "flutter_google_places example",
    darkTheme: customTheme,
    themeMode: ThemeMode.dark,
    routes: {
      "/": (_) => const MyApp(),
      "/search": (_) => CustomSearchScaffold(),
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class MyAppState extends State<MyApp> {
  Mode? _mode = Mode.overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(title: const Text("flutter_google_places")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildDropdownMenu(),
            ElevatedButton(
              onPressed: _handlePressButton,
              child: const Text("Open autocomplete"),
            ),
            ElevatedButton(
              child: const Text("Custom"),
              onPressed: () {
                Navigator.of(context).pushNamed("/search");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() => DropdownButton(
    value: _mode,
    items: const <DropdownMenuItem<Mode>>[
      DropdownMenuItem<Mode>(value: Mode.overlay, child: Text("Overlay")),
      DropdownMenuItem<Mode>(value: Mode.fullscreen, child: Text("Fullscreen")),
    ],
    onChanged: (dynamic m) {
      setState(() {
        _mode = m;
      });
    },
  );

  void onError(PlacesAutocompleteResponse response) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(response.errorMessage!)));
  }

  Future<void> _handlePressButton() async {
    final Prediction? prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: _mode!,
      language: "fr",
      decoration: InputDecoration(
        hintText: 'Search',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
      components: [Component(Component.country, "fr")],
    );

    if (mounted) {
      displayPrediction(prediction, context);
    }
  }
}

Future<void> displayPrediction(Prediction? p, BuildContext context) async {
  if (p != null) {
    // get detail (lat/lng)
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
    final geometry = detail.result?.geometry;
    if (geometry == null) return;
    final lat = geometry.location.lat;
    final lng = geometry.location.lng;

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${p.description} - $lat/$lng")));
  }
}

class CustomSearchScaffold extends PlacesAutocompleteWidget {
  CustomSearchScaffold({super.key})
    : super(
        apiKey: kGoogleApiKey,
        sessionToken: Uuid().generateV4(),
        language: "en",
        components: [Component(Component.country, "uk")],
      );

  @override
  CustomSearchScaffoldState createState() => CustomSearchScaffoldState();
}

class CustomSearchScaffoldState extends PlacesAutocompleteState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: searchScaffoldKey,
      appBar: AppBar(title: const AppBarPlacesAutoCompleteTextField()),
      body: PlacesAutocompleteResult(
        onTap: (prediction) {
          displayPrediction(prediction, context);
        },
        logo: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [FlutterLogo()],
        ),
      ),
    );
  }

  @override
  void onResponseError(PlacesAutocompleteResponse res) {
    super.onResponseError(res);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(res.errorMessage!)));
  }

  @override
  void onResponse(PlacesAutocompleteResponse? res) {
    super.onResponse(res);
    if (res != null && (res.predictions?.isNotEmpty ?? false)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Got answer")));
    }
  }
}

class Uuid {
  final Random _random = Random();

  String generateV4() {
    // Generate xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx / 8-4-4-4-12.
    final int special = 8 + _random.nextInt(4);

    return '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}-'
        '${_bitsDigits(16, 4)}-'
        '4${_bitsDigits(12, 3)}-'
        '${_printDigits(special, 1)}${_bitsDigits(12, 3)}-'
        '${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}${_bitsDigits(16, 4)}';
  }

  String _bitsDigits(int bitCount, int digitCount) =>
      _printDigits(_generateBits(bitCount), digitCount);

  int _generateBits(int bitCount) => _random.nextInt(1 << bitCount);

  String _printDigits(int value, int count) =>
      value.toRadixString(16).padLeft(count, '0');
}
