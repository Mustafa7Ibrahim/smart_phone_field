import 'package:flutter/material.dart';
import '../models/country_data.dart';
import '../utils/phone_validator.dart';
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

  /// Suffix icon for the input field.
  final Widget? suffixIcon;

  /// Helper text for the input field.
  final String? helperText;

  /// Whether to show error messages.
  final bool showErrorMessages;

  /// The border color when the field has an error.
  final Color? errorBorderColor;

  /// The border color when the field is focused.
  final Color? focusedBorderColor;

  /// The border color when the field is enabled.
  final Color? enabledBorderColor;

  /// The border color when the field is disabled.
  final Color? disabledBorderColor;

  /// Border radius for the input field.
  final double borderRadius;

  /// Border width for the input field.
  final double borderWidth;

  /// Focused border width.
  final double focusedBorderWidth;

  /// Whether the decoration is filled.
  final bool filled;

  /// Fill color for the input field.
  final Color? fillColor;

  /// Content padding for the input field.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether the label should float.
  final bool? floatingLabelBehavior;

  /// Custom label style.
  final TextStyle? labelStyle;

  /// Custom hint style.
  final TextStyle? hintStyle;

  /// Custom error style.
  final TextStyle? errorStyle;

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

  /// Flag display size.
  final double flagSize;

  /// Whether to show the dial code in the country selector.
  final bool showDialCode;

  /// Whether to show the dropdown icon in the country selector.
  final bool showDropdownIcon;

  /// Custom country selector padding.
  final EdgeInsetsGeometry? countrySelectorPadding;

  /// Custom country selector decoration.
  final BoxDecoration? countrySelectorDecoration;

  /// Creates a default phone field delegate.
  const DefaultPhoneFieldDelegate({
    this.onCountryChangedCallback,
    this.onPhoneNumberChangedCallback,
    this.onValidationChangedCallback,
    this.customInputDecoration,
    this.labelText = 'Phone Number',
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.showErrorMessages = true,
    this.errorBorderColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.disabledBorderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.focusedBorderWidth = 2.0,
    this.filled = false,
    this.fillColor,
    this.contentPadding,
    this.floatingLabelBehavior,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.customFormatter,
    this.customValidator,
    this.enableAutoDetection = true,
    this.showCountrySelector = true,
    this.textDirection = TextDirection.ltr,
    this.flagSize = 24.0,
    this.showDialCode = true,
    this.showDropdownIcon = true,
    this.countrySelectorPadding,
    this.countrySelectorDecoration,
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
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: fillColor,
      contentPadding: contentPadding,
      labelStyle: labelStyle,
      hintStyle: hintStyle,
      errorStyle: errorStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          width: borderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: enabledBorderColor ?? colorScheme.outline,
          width: borderWidth,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: disabledBorderColor ??
              colorScheme.outline.withValues(alpha: 0.5),
          width: borderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: focusedBorderColor ?? colorScheme.primary,
          width: focusedBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: errorBorderColor ?? colorScheme.error,
          width: borderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: errorBorderColor ?? colorScheme.error,
          width: focusedBorderWidth,
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
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: countrySelectorPadding ??
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: countrySelectorDecoration ??
            BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCountry != null) ...[
              Text(
                selectedCountry.flag,
                style: TextStyle(fontSize: flagSize),
              ),
              if (showDialCode) ...[
                const SizedBox(width: 8),
                Text(
                  selectedCountry.dialCode,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
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
            if (showDropdownIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
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

    // Use libphonenumber for automatic formatting
    if (input.isNotEmpty && country != null) {
      final formatted = PhoneValidator.formatAsYouType(input, country: country);
      // Only return formatted if it's different from input
      if (formatted != input) {
        return formatted;
      }
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

    // Use libphonenumber for enhanced validation
    if (phoneNumber.isNotEmpty) {
      final isValid = country != null
          ? PhoneValidator.validateLocal(phoneNumber, country)
          : PhoneValidator.validateInternational(phoneNumber);

      if (!isValid) {
        return 'Please enter a valid phone number';
      }
    }

    // Return null to indicate validation passed
    return null;
  }
}
