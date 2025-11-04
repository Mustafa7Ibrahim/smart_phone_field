import 'package:flutter/material.dart';
import '../models/country_data.dart';
import '../utils/phone_validator.dart';

/// Controller for managing the state of the phone text field.
///
/// This class follows the Single Responsibility Principle by handling
/// only the state management and business logic for the phone field.
///
/// Example:
/// ```dart
/// final controller = PhoneFieldController();
///
/// // Listen to country changes
/// controller.addListener(() {
///   print('Selected country: ${controller.selectedCountry?.name}');
/// });
///
/// // Manually set a country
/// controller.setCountry(usCountry);
///
/// // Get the complete phone number
/// final fullNumber = controller.fullPhoneNumber;
/// ```
class PhoneFieldController extends ChangeNotifier {
  /// The text editing controller for the phone number input.
  final TextEditingController textController;

  /// The currently selected or detected country.
  CountryData? _selectedCountry;

  /// Whether auto-detection is enabled.
  bool _autoDetectionEnabled;

  /// The current validation state.
  bool _isValid = false;

  /// The current error message (if any).
  String? _errorMessage;

  /// Creates a phone field controller.
  ///
  /// - [initialCountry]: The initial country to select
  /// - [initialPhoneNumber]: The initial phone number to display
  /// - [autoDetectionEnabled]: Whether to enable auto-detection (default: true)
  PhoneFieldController({
    CountryData? initialCountry,
    String? initialPhoneNumber,
    bool autoDetectionEnabled = true,
  })  : _selectedCountry = initialCountry,
        _autoDetectionEnabled = autoDetectionEnabled,
        textController = TextEditingController(text: initialPhoneNumber) {
    // Set up listener for text changes
    textController.addListener(_onTextChanged);

    // If initial phone number is provided, try to detect country
    if (initialPhoneNumber != null &&
        initialPhoneNumber.isNotEmpty &&
        autoDetectionEnabled &&
        initialCountry == null) {
      _detectCountryFromNumber(initialPhoneNumber);
    }
  }

  /// Gets the currently selected country.
  CountryData? get selectedCountry => _selectedCountry;

  /// Gets whether the current phone number is valid.
  bool get isValid => _isValid;

  /// Gets the current error message.
  String? get errorMessage => _errorMessage;

  /// Gets whether auto-detection is enabled.
  bool get autoDetectionEnabled => _autoDetectionEnabled;

  /// Gets the current phone number text.
  String get phoneNumber => textController.text;

  /// Gets the full phone number with country code.
  ///
  /// Returns the complete international format if a country is selected,
  /// otherwise returns the text as-is.
  String get fullPhoneNumber {
    if (_selectedCountry == null) {
      return textController.text;
    }

    final text = textController.text.trim();
    if (text.isEmpty) return '';

    // If the number already starts with the dial code, return as-is
    if (text.startsWith(_selectedCountry!.dialCode)) {
      return text;
    }

    // If it starts with +, assume it's already international format
    if (text.startsWith('+')) {
      return text;
    }

    // Otherwise, prepend the dial code
    return '${_selectedCountry!.dialCode}$text';
  }

  /// Manually sets the selected country.
  ///
  /// This will notify listeners and update the validation state.
  void setCountry(CountryData? country) {
    if (_selectedCountry != country) {
      final oldCountry = _selectedCountry;
      _selectedCountry = country;
      _validateCurrentNumber();
      notifyListeners();

      // This could be used by delegates to handle country changes
      _onCountryChanged(oldCountry, country);
    }
  }

  /// Enables or disables auto-detection.
  void setAutoDetectionEnabled(bool enabled) {
    if (_autoDetectionEnabled != enabled) {
      _autoDetectionEnabled = enabled;
      if (enabled && textController.text.isNotEmpty) {
        _detectCountryFromNumber(textController.text);
      }
      notifyListeners();
    }
  }

  /// Sets the phone number programmatically.
  void setPhoneNumber(String phoneNumber) {
    textController.text = phoneNumber;
    // The text controller listener will handle detection and validation
  }

  /// Clears the phone number and resets state.
  void clear() {
    textController.clear();
    _selectedCountry = null;
    _isValid = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Validates the current phone number.
  ///
  /// Returns true if the number is valid, false otherwise.
  bool validate() {
    _validateCurrentNumber();
    return _isValid;
  }

  /// Handles text changes in the text field.
  void _onTextChanged() {
    final text = textController.text;

    // Auto-detect country if enabled
    if (_autoDetectionEnabled && text.isNotEmpty) {
      _detectCountryFromNumber(text);
    }

    // Validate the current number
    _validateCurrentNumber();
  }

  /// Detects the country from the phone number.
  void _detectCountryFromNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return;

    final detectedCountry = PhoneValidator.detectCountry(phoneNumber);

    if (detectedCountry != null && detectedCountry != _selectedCountry) {
      final oldCountry = _selectedCountry;
      _selectedCountry = detectedCountry;
      _onCountryChanged(oldCountry, detectedCountry);
      notifyListeners();
    }
  }

  /// Validates the current phone number.
  void _validateCurrentNumber() {
    final text = textController.text.trim();

    if (text.isEmpty) {
      _isValid = false;
      _errorMessage = null;
      return;
    }

    if (_selectedCountry != null) {
      // Validate international format
      _isValid = PhoneValidator.validateInternational(fullPhoneNumber);
      _errorMessage =
          _isValid ? null : 'Invalid phone number for ${_selectedCountry!.name}';
    } else {
      // No country selected, just check if it looks like a phone number
      final hasOnlyDigitsAndPlus = RegExp(r'^[\d\+\s\-\(\)]+$').hasMatch(text);
      _isValid = hasOnlyDigitsAndPlus && text.length >= 8;
      _errorMessage = _isValid ? null : 'Invalid phone number format';
    }
  }

  /// Called when the country changes.
  void _onCountryChanged(CountryData? oldCountry, CountryData? newCountry) {
    // This is a hook for subclasses or delegates to handle country changes
    // The actual delegate callback will be handled by the widget
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.dispose();
  }
}
