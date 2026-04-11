# Changelog

## 0.6.0

- Upgraded the package to `google_maps_apis` and re-exported Places types from the main package import.
- Updated SDK constraints for modern Dart and Flutter releases.
- Added a widget test baseline covering overlay mode, fullscreen mode, form integration, and field rendering.
- Hardened autocomplete request handling to ignore stale responses and surface transport failures through `onError`.
- Added `httpClient` and `proxyBaseUrl` support to `PlacesAutocompleteField` and `PlacesAutocompleteFormField` so inline widgets match `PlacesAutocomplete.show`.
- Fixed controller ownership and disposal edge cases in the inline and form field widgets.
- Refreshed README examples to match the 0.6.0 API and document proxy/custom-client support on field widgets.

## 0.4.0

New features:

- Add `textStyle` and `borderRadius` fields to `PlacesAutocompleteField()`.
- Add `resultTextStyle` to `PlacesAutocompleteWidget()`.

Other improvements:

- Migrate from `flutter_lints` to `lint` and apply all suggestions.
- Update `rxdart` to the latest version.

## 0.3.2

- Update `google_api_headers` to 1.2.0.

## 0.3.1

- Fix the null-pointer crash.
- Upgrade the example app to null safety.
- Apply Flutter lint recommendations.
- Upgrade dependencies.

## 0.3.0

- Update packages.
- Upgrade to null safety.
- Upgrade and migrate the Android project to AndroidX.
- Replace deprecated `autovalidate` with `autovalidateMode` in `PlacesAutocompleteFormField`.
- Remove deprecated methods and add `decoration` support for fullscreen and overlay widgets.

## 0.2.8

- Fix pub.dev complaints.
- Remove insecure links.
- Replace deprecated `autovalidate` bool with `AutovalidateMode`.
- Format with `dartfmt`.

## 0.2.7

- Add expected label behavior to `PlacesAutocompleteField`.
- Auto-select text.
- Add support for app-restricted API keys.
- Replace deprecated `ancestorStateOfType` usage.
- Update the `rxdart` version in `pubspec.yaml`.

## 0.2.6

- Fix errors when selecting a place.
- Fix the case where `controller.text` was not updated correctly.
- Fix the issue where `_queryBehavior` tried to emit after the widget was closed.

## 0.2.5

- Update `rxdart` to 0.24.0.
- Update `google_maps_webservice` to 0.0.16.

## 0.2.4

- Add Flutter web support.
- Update `rxdart`.
- Add `overlayBorderRadius`.
- Add `startText`.

## 0.2.3

- Update `rxdart` and `google_maps_webservice`.

## 0.2.0

- Improve the text theme for text input.
- Allow proxy URLs with `proxyBaseUrl` and custom HTTP clients with `httpClient`.

## 0.1.4

- Rename `footer` to `logo` for clarity.

## 0.1.3

- Update `rxdart`.

## 0.1.2

- Fix dark mode.

## 0.1.1

- Fix icon quality.
- Fix input borders when using a custom theme.

## 0.1.0

- Update the SDK and fix warnings.

## 0.0.5

- Fix `radius` handling.

## 0.0.4

- Open widgets so consumers can build custom UI.
- Add the `onError` callback.

## 0.0.3

- Add padding for overlay mode on iOS.

## 0.0.2

- Update `google_maps_webservice` to `^0.0.3`.
- Fix placeholder positioning.
- Fix keyboard clipping on overlay.

## 0.0.1

- Initial version.
