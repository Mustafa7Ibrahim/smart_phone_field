import 'package:flutter/material.dart';
import '../models/country_data.dart';
import 'phone_field_delegate.dart';

/// Default implementation of [PhoneFieldDelegate] with Material Design styling.
///
/// This provides a sensible default appearance and behavior that can be used
/// out-of-the-box or extended for custom implementations.
///
/// Example:
/// ```dart
/// // Use with custom callbacks
/// final delegate = DefaultPhoneFieldDelegate(
///   onCountryChanged: (old, new) => print('Country: ${new?.name}'),
///   labelText: 'Phone Number',
///   hintText: 'Enter your phone number',
/// );
/// ```
class DefaultPhoneFieldDelegate implements PhoneFieldDelegate {
  /// Callback invoked when country changes.
  final void Function(CountryData? oldCountry, CountryData? newCountry)?
      onCountryChangedCallback;

  /// Callback invoked when phone number changes.
  final void Function(String phoneNumber)? onPhoneNumberChangedCallback;

  /// Callback invoked when validation state changes.
  final void Function(bool isValid, String? errorMessage)?
      onValidationChangedCallback;

  /// Custom input decoration to use (overrides default).
  final InputDecoration? customInputDecoration;

  /// Label text for the input field.
  final String? labelText;

  /// Hint text for the input field.
  final String? hintText;

  /// Prefix icon for the input field.
  final Widget? prefixIcon;

  /// Whether to show error messages.
  final bool showErrorMessages;

  /// The border color when the field has an error.
  final Color? errorBorderColor;

  /// The border color when the field is focused.
  final Color? focusedBorderColor;

  /// Custom formatter function.
  final String? Function(String input, CountryData? country)? customFormatter;

  /// Custom validator function.
  final String? Function(String phoneNumber, CountryData? country)?
      customValidator;

  /// Whether to enable auto-detection.
  @override
  final bool enableAutoDetection;

  /// Whether to show the country selector.
  @override
  final bool showCountrySelector;

  /// Text direction for input.
  @override
  final TextDirection textDirection;

  /// Creates a default phone field delegate.
  const DefaultPhoneFieldDelegate({
    this.onCountryChangedCallback,
    this.onPhoneNumberChangedCallback,
    this.onValidationChangedCallback,
    this.customInputDecoration,
    this.labelText = 'Phone Number',
    this.hintText,
    this.prefixIcon,
    this.showErrorMessages = true,
    this.errorBorderColor,
    this.focusedBorderColor,
    this.customFormatter,
    this.customValidator,
    this.enableAutoDetection = true,
    this.showCountrySelector = true,
    this.textDirection = TextDirection.ltr,
  });

  @override
  InputDecoration buildInputDecoration(
    BuildContext context,
    CountryData? selectedCountry,
    bool hasError,
  ) {
    // If custom decoration is provided, use it
    if (customInputDecoration != null) {
      return customInputDecoration!;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText ?? 'Enter phone number',
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: colorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: focusedBorderColor ?? colorScheme.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorBorderColor ?? colorScheme.error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorBorderColor ?? colorScheme.error,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget? buildCountrySelector(
    BuildContext context,
    CountryData? selectedCountry,
    VoidCallback onTap,
  ) {
    if (!showCountrySelector) return null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCountry != null) ...[
              Text(
                selectedCountry.flag,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                selectedCountry.dialCode,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ] else ...[
              Icon(
                Icons.public,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '+',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onCountryChanged(CountryData? oldCountry, CountryData? newCountry) {
    onCountryChangedCallback?.call(oldCountry, newCountry);
  }

  @override
  void onPhoneNumberChanged(String phoneNumber) {
    onPhoneNumberChangedCallback?.call(phoneNumber);
  }

  @override
  void onValidationChanged(bool isValid, String? errorMessage) {
    onValidationChangedCallback?.call(isValid, errorMessage);
  }

  @override
  String? formatPhoneNumber(String input, CountryData? country) {
    // Use custom formatter if provided
    if (customFormatter != null) {
      return customFormatter!(input, country);
    }

    // Return null to use default formatting (no formatting)
    return null;
  }

  @override
  String? validatePhoneNumber(String phoneNumber, CountryData? country) {
    // Use custom validator if provided
    if (customValidator != null) {
      return customValidator!(phoneNumber, country);
    }

    // Return null to use default validation (handled by controller)
    return null;
  }
}
