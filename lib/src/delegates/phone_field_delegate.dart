import 'package:flutter/material.dart';
import '../models/country_data.dart';

/// Delegate protocol for customizing the phone text field appearance and behavior.
///
/// This follows the delegate pattern to allow full customization while
/// maintaining separation of concerns and following SOLID principles.
///
/// Example:
/// ```dart
/// class MyPhoneFieldDelegate implements PhoneFieldDelegate {
///   @override
///   InputDecoration buildInputDecoration(
///     BuildContext context,
///     CountryData? selectedCountry,
///     bool hasError,
///   ) {
///     return InputDecoration(
///       labelText: 'Phone Number',
///       prefixIcon: selectedCountry != null
///         ? Text(selectedCountry.flag)
///         : null,
///     );
///   }
///
///   @override
///   void onCountryChanged(CountryData? country) {
///     print('Country changed to: ${country?.name}');
///   }
/// }
/// ```
abstract class PhoneFieldDelegate {
  /// Builds the input decoration for the text field.
  ///
  /// - [context]: Build context for accessing theme data
  /// - [selectedCountry]: Currently selected or detected country
  /// - [hasError]: Whether the current input has a validation error
  InputDecoration buildInputDecoration(
    BuildContext context,
    CountryData? selectedCountry,
    bool hasError,
  );

  /// Builds the country selector widget (typically shows flag + dial code).
  ///
  /// This widget is usually placed as a prefix in the text field.
  /// Return null to hide the country selector.
  Widget? buildCountrySelector(
    BuildContext context,
    CountryData? selectedCountry,
    VoidCallback onTap,
  );

  /// Called when the country changes (either by detection or manual selection).
  void onCountryChanged(CountryData? oldCountry, CountryData? newCountry);

  /// Called when the phone number text changes.
  void onPhoneNumberChanged(String phoneNumber);

  /// Called when validation state changes.
  void onValidationChanged(bool isValid, String? errorMessage);

  /// Formats the phone number as the user types.
  ///
  /// Return null to use default formatting, or return a formatted string
  /// to apply custom formatting.
  String? formatPhoneNumber(String input, CountryData? country);

  /// Validates the phone number and returns an error message if invalid.
  ///
  /// Return null if the number is valid.
  String? validatePhoneNumber(String phoneNumber, CountryData? country);

  /// Whether to enable auto-detection of country from phone number.
  bool get enableAutoDetection => true;

  /// Whether to show the country selector button.
  bool get showCountrySelector => true;

  /// The text direction for the phone number input.
  TextDirection get textDirection => TextDirection.ltr;
}
