# flutter_google_places 

[![Flutter Community: flutter_google_places](https://fluttercommunity.dev/_github/header/flutter_google_places)](https://github.com/fluttercommunity/community)

[![Pub](https://img.shields.io/pub/v/flutter_google_places.svg)](https://pub.dartlang.org/packages/flutter_google_places)

A Flutter package providing Google Places autocomplete widgets with no wrapper complexity. Built on top of [google_maps_webservice](https://github.com/lejard-h/google_maps_webservice) and directly implements the official [Google Maps Web Services API](https://developers.google.com/maps/web-services/).

## Features

✨ **Two Display Modes**: Fullscreen or overlay presentation
🎨 **Customizable UI**: Theme, text styles, border radius, and decorations
🌍 **Location Filtering**: Filter by location, radius, country, and language
🔍 **Smart Search**: Debounced input with session token support
📱 **Flutter 3.35+**: Built for the latest Flutter SDK with modern APIs
🔒 **Proxy Support**: Optional proxy configuration for API key security

## Requirements

- Flutter SDK: `>=3.35.5`
- Dart SDK: `>=3.8.0 <4.0.0`
- **Google Maps API Key** with Places API enabled
- **Billing enabled** on your Google Cloud account (even for free tier usage)

> ⚠️ According to [Google's requirements](https://stackoverflow.com/a/52545293), you must enable billing on your Google Cloud account to use the Places API, even if you stay within the free quota.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_google_places: ^0.5.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

const kGoogleApiKey = "YOUR_API_KEY";

// Show autocomplete in overlay mode
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  mode: Mode.overlay,
  language: "en",
  components: [Component(Component.country, "us")],
);

// Get place details
if (p != null) {
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);
  final lat = detail.result.geometry!.location.lat;
  final lng = detail.result.geometry!.location.lng;
}
```

### Display Modes

#### Overlay Mode (Default)
```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  mode: Mode.overlay, // Popup overlay
);
```

#### Fullscreen Mode
```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  mode: Mode.fullscreen, // Full page
);
```

#### Fullscreen Mode
```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  mode: Mode.fullscreen, // Full page
);
```

## Advanced Configuration

### Filtering by Location and Radius

```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  location: Location(lat: 37.7749, lng: -122.4194), // San Francisco
  radius: 5000, // 5km radius
  strictbounds: false, // If true, only returns results within radius
);
```

### Filtering by Country and Type

```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  components: [
    Component(Component.country, "us"),
    Component(Component.country, "ca"),
  ],
  types: ["establishment"], // Only businesses
  language: "en",
);
```

### Custom Styling

```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  mode: Mode.overlay,
  decoration: InputDecoration(
    hintText: 'Search location',
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
  ),
  textStyle: TextStyle(
    fontSize: 18.0,
    color: Colors.black87,
  ),
  resultTextStyle: TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  ),
  overlayBorderRadius: BorderRadius.circular(12),
);
```

### Using a Proxy (Recommended for Production)

For security, avoid storing API keys in your app. Use a proxy server:

```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: "", // Not required with proxy
  proxyBaseUrl: "https://your-proxy-server.com",
  httpClient: YourCustomClient(), // Optional: for authentication
);
```

### Session Tokens (Cost Optimization)

Use session tokens to group autocomplete requests with place details for billing:

```dart
String sessionToken = Uuid().v4();

Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  sessionToken: sessionToken,
);
```

### Debounce Configuration

Control search delay to reduce API calls:

```dart
Prediction? p = await PlacesAutocomplete.show(
  context: context,
  apiKey: kGoogleApiKey,
  debounce: 500, // 500ms delay (default: 300ms)
);
```

## PlacesAutocompleteField Widget

For inline autocomplete in forms:

```dart
PlacesAutocompleteField(
  apiKey: kGoogleApiKey,
  hint: 'Enter address',
  language: 'en',
  components: [Component(Component.country, 'us')],
  textStyle: TextStyle(fontSize: 16),
  borderRadius: BorderRadius.circular(8),
  onSelected: (prediction) {
    print('Selected: ${prediction.description}');
  },
)
```

## PlacesAutocompleteFormField Widget

For form validation support:

```dart
PlacesAutocompleteFormField(
  apiKey: kGoogleApiKey,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please select a location';
    }
    return null;
  },
  onSaved: (prediction) {
    // Save prediction
  },
)
```

## API Reference

### PlacesAutocomplete.show Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `context` | `BuildContext` | **Required** - Build context |
| `apiKey` | `String` | **Required** - Google Maps API key (unless using proxy) |
| `mode` | `Mode` | Display mode: `Mode.overlay` or `Mode.fullscreen` |
| `hint` | `String?` | Hint text for search input |
| `startText` | `String?` | Initial text in search field |
| `location` | `Location?` | Bias results to this location |
| `radius` | `num?` | Radius in meters around location |
| `strictbounds` | `bool?` | Restrict results to radius |
| `language` | `String?` | Language code (e.g., "en", "es") |
| `sessionToken` | `String?` | Session token for billing optimization |
| `offset` | `num?` | Character position for prediction |
| `types` | `List<String>?` | Place types filter |
| `components` | `List<Component>?` | Country/region filters |
| `region` | `String?` | Region code bias |
| `decoration` | `InputDecoration?` | Custom input decoration |
| `textStyle` | `TextStyle?` | Text style for input |
| `resultTextStyle` | `TextStyle?` | Text style for results |
| `overlayBorderRadius` | `BorderRadius?` | Border radius for overlay |
| `logo` | `Widget?` | Custom logo widget |
| `debounce` | `int` | Debounce delay in milliseconds |
| `proxyBaseUrl` | `String?` | Proxy server URL |
| `httpClient` | `BaseClient?` | Custom HTTP client |
| `onError` | `ValueChanged?` | Error callback |

## Screenshots 
<div style="text-align: center"><table><tr>
    <td style="text-align: center">
<img src="https://raw.githubusercontent.com/fluttercommunity/flutter_google_places/master/flutter_01.png" height="400">
</td>
<td style="text-align: center">
<img src="https://raw.githubusercontent.com/fluttercommunity/flutter_google_places/master/flutter_02.png" height="400">
</td>
</tr>
</table>
</div>

## Screenshots

<div style="text-align: center"><table><tr>
    <td style="text-align: center">
<img src="https://raw.githubusercontent.com/fluttercommunity/flutter_google_places/master/flutter_01.png" height="400">
</td>
<td style="text-align: center">
<img src="https://raw.githubusercontent.com/fluttercommunity/flutter_google_places/master/flutter_02.png" height="400">
</td>
</tr>
</table>
</div>

## Getting Your Google API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Places API** and **Maps SDK for Android/iOS**
4. Create credentials (API key)
5. **Enable billing** (required even for free tier)
6. Restrict your API key (recommended):
   - Application restrictions (iOS/Android apps)
   - API restrictions (Places API, Maps SDK)

## Common Issues

### Billing Not Enabled
**Error**: "This API project is not authorized to use this API"  
**Solution**: Enable billing in Google Cloud Console

### Invalid API Key
**Error**: "The provided API key is invalid"  
**Solution**: Check that your API key is correct and Places API is enabled

### No Results
**Solution**: Verify your location/radius settings and component filters

### CORS Issues (Web)
**Solution**: Use a proxy server to handle API requests

## Example App

View the complete Flutter app in the [`example`](example/) directory to see all features in action.

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

This package is maintained by the [Flutter Community](https://github.com/fluttercommunity).

Built with [google_maps_webservice](https://github.com/lejard-h/google_maps_webservice) by [@lejard-h](https://github.com/lejard-h).

## Support

- 📚 [Google Places API Documentation](https://developers.google.com/maps/documentation/places/web-service/overview)
- 💬 [GitHub Issues](https://github.com/fluttercommunity/flutter_google_places/issues)
- 🐛 Found a bug? Please file an issue!

---

Made with ❤️ by the Flutter Community
